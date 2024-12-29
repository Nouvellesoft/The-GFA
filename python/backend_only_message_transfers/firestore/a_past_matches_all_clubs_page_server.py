from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from bs4 import BeautifulSoup
from google.cloud import firestore
import re
import sys

# Setup Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'
try:
    db = firestore.Client(project=FIRESTORE_PROJECT_ID)
except Exception as e:
    print(f"Error initializing Firestore client: {e}")
    sys.exit(1)

# Setup Selenium options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no GUI)

# Path to chromedriver (adjust this to match your setup)
service = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=service, options=chrome_options)

# Constants
MAX_MATCHES = 50
BATCH_SIZE = 500

# List of acronyms to capitalize
ACRONYMS = ["FISSC", "FC", "F.C", 'AFC', 'ST', 'OBS']


def get_all_club_ids():
    try:
        clubs = db.collection('clubs').stream()
        return [club.id for club in clubs]
    except Exception as ex:
        print(f"Error fetching club IDs: {ex}")
        return []


def get_past_matches_all_clubs_links(club_id):
    try:
        past_matches_all_clubs_links_doc_ref = db.collection('clubs').document(club_id).collection(
            'ScrapedMatchesLinks').document('past_matches_all_clubs_links')
        past_matches_all_clubs_links_doc = past_matches_all_clubs_links_doc_ref.get()

        if not past_matches_all_clubs_links_doc.exists:
            print(f"No past matches document found for club_id: {club_id}")
            return []

        doc_data = past_matches_all_clubs_links_doc.to_dict()
        match_urls = [value.strip() for key, value in doc_data.items() if
                      key.startswith('sc_link_') and isinstance(value, str) and value.strip()]
        return match_urls

    except Exception as fetch_exc:
        print(f"Error fetching past match links: {fetch_exc}")
        return []


def clean_whitespace(text):
    return re.sub(r'\s+', ' ', text.strip())


def capitalize_word(word):
    return word.upper() if word.upper() in ACRONYMS else word.capitalize()


def capitalize_after_parentheses(text):
    def capitalize_text(texting):
        return ' '.join([capitalize_word(word) for word in texting.split()])

    parts = re.split(r'(\s*\(.*?\)\s*)', text)
    formatted_parts = []

    for i, part in enumerate(parts):
        if i % 2 == 0:  # Even indexes are outside parentheses
            formatted_parts.append(capitalize_text(part))
        else:  # Odd indexes are inside parentheses
            formatted_parts.append(part)  # Keep parentheses as they are

    return ''.join(formatted_parts)


def clean_and_capitalize(text):
    text = clean_whitespace(text)
    parts = re.split(r'\s*/\s*', text)
    capitalized_parts = []

    for part in parts:
        capitalized_parts.append(capitalize_after_parentheses(part))

    return '/'.join(capitalized_parts)


def add_space_after_parenthesis(text):
    return re.sub(r'\)([a-zA-Z])', r') \1', text)


def check_parenthesis_balance(text):
    opening_parenthesis_count = text.count('(')
    closing_parenthesis_count = text.count(')')

    if opening_parenthesis_count > closing_parenthesis_count:
        text += ')'

    return text


def process_club(club_id):
    past_matches_all_club_links_urls = get_past_matches_all_clubs_links(club_id)

    if not past_matches_all_club_links_urls:
        print(f"No past match links found for club_id: {club_id}")
        return

    id_counter = 1
    batch = db.batch()
    matches_processed = 0

    for url in past_matches_all_club_links_urls:
        driver.get(url)

        WebDriverWait(driver, 10).until(
            ec.presence_of_element_located((By.CSS_SELECTOR, ".results-table-2"))
        )

        html = driver.page_source
        soup = BeautifulSoup(html, 'html.parser')
        matches_table = soup.find('div', class_='results-table-2')

        if matches_table:
            rows = matches_table.find_all('div', class_='flex middle')

            for row in rows:
                if matches_processed >= MAX_MATCHES:
                    break

                columns = row.find_all('div')

                if len(columns) >= 8:
                    # match_type = columns[1].text.strip()
                    date_time = columns[2].text.strip()
                    home_team = clean_and_capitalize(columns[3].text)
                    score = columns[6].text.strip()
                    away_team = clean_and_capitalize(columns[7].text)
                    competition = clean_and_capitalize(columns[10].text)

                    home_team = add_space_after_parenthesis(home_team)
                    away_team = add_space_after_parenthesis(away_team)

                    date_time = ' '.join(date_time.split())

                    ht_score = ""
                    at_score = ""
                    ultimate_score = ""

                    if 'Void' in score:
                        ultimate_score = "(Void)"
                        ht_score = "V" if "V" in score.split('-')[0] else ""
                        at_score = "V" if "V" in score.split('-')[1] else ""
                    elif 'Pens' in score:
                        penalty_match = re.search(r'(\(Pens \d+-\d+\))', score)
                        if penalty_match:
                            ultimate_score = penalty_match.group(1)
                        regular_score = re.search(r'(\d+)\s*-\s*(\d+)', score)
                        if regular_score:
                            ht_score = regular_score.group(1)
                            at_score = regular_score.group(2)
                    elif 'AET' in score:
                        ultimate_score = "(AET)"
                        regular_score = re.search(r'(\d+)\s*-\s*(\d+)', score)
                        if regular_score:
                            ht_score = regular_score.group(1)
                            at_score = regular_score.group(2)
                    else:
                        score_parts = score.split(' - ')
                        if len(score_parts) == 2:
                            ht_score, at_score = score_parts
                            ht_match = re.search(r'\(HT (\d+-\d+)\)', at_score)
                            if ht_match:
                                ultimate_score = f"(HT {ht_match.group(1)})"
                                at_score = at_score.split('\n')[0].strip()
                        else:
                            print(f"Unexpected score format: {score}")
                            continue

                    ht_score = ht_score.strip()
                    at_score = at_score.strip()

                    if ht_score.lower() == 'v':
                        ht_score = 'V'
                    if at_score.lower() == 'v':
                        at_score = 'V'

                    match_data = {
                        'away_team': away_team,
                        'away_team_icon': 'https://example.com/away_team_icon.jpg',
                        'home_team': home_team,
                        'home_team_icon': 'https://example.com/home_team_icon.jpg',
                        'id': id_counter,
                        'match_date': date_time,
                        'ht_score': ht_score,
                        'at_score': at_score,
                        'ultimate_score': ultimate_score,
                        'goalscorers': '',
                        'assists_by': '',
                        'competition': competition,
                    }

                    doc_ref = (db.collection('clubs').document(club_id)
                               .collection('PastMatchesForAllClubs')
                               .document(f"match_{id_counter}"))
                    batch.set(doc_ref, match_data)

                    id_counter += 1
                    matches_processed += 1

                    if matches_processed % BATCH_SIZE == 0:
                        batch.commit()
                        batch = db.batch()
                        print(
                            f"Committed batch for {club_id}. "
                            f"Processed {matches_processed} matches.")

                if matches_processed >= MAX_MATCHES:
                    break
        else:
            print(f"No past matches found on the page for URL: {url}")

        if matches_processed >= MAX_MATCHES:
            break

    # Commit any remaining matches in the batch
    if matches_processed % BATCH_SIZE != 0:
        batch.commit()
        print(f"Final batch commit for {club_id}. Total processed: {matches_processed} matches.")


def main():
    club_ids = get_all_club_ids()
    for club_id in club_ids:
        print(f"Processing club: {club_id}")
        process_club(club_id)

    # Close the WebDriver
    driver.quit()


if __name__ == "__main__":
    main()
