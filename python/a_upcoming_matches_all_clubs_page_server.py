from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from bs4 import BeautifulSoup
from datetime import datetime
from google.cloud import firestore
import sys
import re

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
MAX_FIXTURES = 50
BATCH_SIZE = 500
ACRONYMS = ["FISSC", "FC", 'AFC', 'ST', 'OBS', '1ST']


def get_all_club_ids():
    try:
        clubs = db.collection('clubs').stream()
        return [club.id for club in clubs]
    except Exception as ex:
        print(f"Error fetching club IDs: {ex}")
        return []


def get_upcoming_matches_all_clubs_links(club_id):
    try:
        upcoming_matches_all_clubs_links_doc_ref = (db.collection('clubs')
                                                    .document(club_id).collection(
            'ScrapedMatchesLinks').document('upcoming_matches_all_clubs_links'))
        upcoming_matches_all_clubs_links_doc = upcoming_matches_all_clubs_links_doc_ref.get()

        if not upcoming_matches_all_clubs_links_doc.exists:
            print(f"No upcoming matches document found for club_id: {club_id}")
            return []

        doc_data = upcoming_matches_all_clubs_links_doc.to_dict()
        match_urls = [value.strip() for key, value in doc_data.items() if
                      key.startswith('sc_link_') and isinstance(value, str) and value.strip()]
        return match_urls

    except Exception as fetch_exc:
        print(f"Error fetching upcoming match links: {fetch_exc}")
        return []


def format_text(input_text):
    formatted_text = input_text.strip()
    formatted_text = re.sub(r'\s+', ' ', formatted_text)

    special_terms = ["F.C", "A.C", "S.C", "C.F", "U.F"]

    def preserve_special_terms(text):
        for term in special_terms:
            text = text.replace(term, f"{{{term}}}")
        return text

    def revert_special_terms(text):
        for term in special_terms:
            text = text.replace(f"{{{term}}}", term)
        return text

    formatted_text = preserve_special_terms(formatted_text)

    def capitalize_after_parentheses(match):
        return match.group(1) + match.group(2).capitalize()

    formatted_text = (
        re.sub(r'(\(.*?\))\s*(\w)', capitalize_after_parentheses, formatted_text))

    def capitalize_acronyms(word):
        match = re.match(r'\b\w+\b', word)
        if match:
            word = match.group()
            return word.upper() if word.upper() in ACRONYMS else word.capitalize()
        return word

    parts = [part.strip() for part in formatted_text.split('/')]
    capitalized_parts = \
        [' '.join([capitalize_acronyms(word) for word in part.split()]) for part in parts]
    formatted_text = '/'.join(capitalized_parts)
    formatted_text = revert_special_terms(formatted_text)

    return formatted_text


def add_space_after_parenthesis(text):
    return re.sub(r'\)([a-zA-Z])', r') \1', text)


def check_parenthesis_balance(text):
    opening_parenthesis_count = text.count('(')
    closing_parenthesis_count = text.count(')')
    if opening_parenthesis_count > closing_parenthesis_count:
        text += ')'
    return text


def clean_whitespace(text):
    return re.sub(r'\s+', ' ', text.strip())


def process_club(club_id):
    upcoming_matches_all_clubs_links_urls = get_upcoming_matches_all_clubs_links(club_id)

    if not upcoming_matches_all_clubs_links_urls:
        print(f"No upcoming match links found for club_id: {club_id}")
        return

    id_counter = 1
    batch = db.batch()
    matches_processed = 0

    for url in upcoming_matches_all_clubs_links_urls:
        if not url:
            continue

        try:
            driver.get(url)
            (WebDriverWait(driver, 10)
             .until(ec.presence_of_element_located((By.TAG_NAME, "table"))))
            html = driver.page_source
            soup = BeautifulSoup(html, 'html.parser')
            fixtures_table = soup.find('table')

            if fixtures_table:
                rows = fixtures_table.find_all('tr')[1:]

                for row in rows:
                    if matches_processed >= MAX_FIXTURES:
                        break

                    columns = row.find_all('td')
                    if len(columns) >= 10:
                        match_type = columns[0].text.strip()
                        date_time = columns[1].text.strip()
                        home_team = format_text(columns[2].text)
                        away_team = format_text(columns[6].text)
                        venue = format_text(columns[7].text.strip())
                        competition = format_text(columns[8].text.strip())

                        venue = check_parenthesis_balance(venue)
                        home_team = add_space_after_parenthesis(home_team)
                        away_team = add_space_after_parenthesis(away_team)

                        date_time = ' '.join(date_time.split())

                        if ' ' in date_time:
                            match_date_str, match_time_str = date_time.split(' ', 1)
                        else:
                            match_date_str = date_time
                            match_time_str = ""

                        try:
                            match_datetime = datetime.strptime(
                                f"{match_date_str} {match_time_str}",
                                "%d/%m/%y %H:%M")
                        except ValueError:
                            print(
                                f"Date parsing error for match: "
                                f"{home_team} vs {away_team} on {date_time}")
                            continue

                        match_date = match_datetime.strftime("%d-%m-%Y %H:%M:%S")
                        match_date_three = match_datetime.strftime("%j %H:%M")
                        match_date_two = match_datetime.strftime("%d/%m/%Y %H:%M:%S")
                        match_day_ko = match_datetime.strftime("%A, %I:%M%p")

                        match_data = {
                            'away_team': away_team,
                            'away_team_icon': 'https://example.com/away_team_icon.jpg',
                            'home_team': home_team,
                            'home_team_icon': 'https://example.com/home_team_icon.jpg',
                            'id': id_counter,
                            'match_date': match_date,
                            'match_date_three': match_date_three,
                            'match_date_two': match_date_two,
                            'match_day_ko': match_day_ko,
                            'venue': venue,
                            'competition': competition,
                        }

                        doc_ref = (db.collection('clubs').document(club_id)
                                   .collection('UpcomingMatchesForAllClubs')
                                   .document(f"match_{id_counter}"))
                        batch.set(doc_ref, match_data)

                        matches_processed += 1
                        id_counter += 1

                        if matches_processed % BATCH_SIZE == 0:
                            batch.commit()
                            batch = db.batch()
                            print(
                                f"Committed batch for {club_id}. "
                                f"Processed {matches_processed} matches.")

                        print(f"ID: {id_counter}, Date: {match_date}, Time: {match_time_str}, "
                              f"Date Three: {match_date_three}, Date Two: {match_date_two}, "
                              f"Match Day/KO: {match_day_ko}, Home: {home_team}, "
                              f"Away: {away_team}, Venue: {venue}, "
                              f"Competition: {competition}, Match Type: {match_type}")

                    if matches_processed >= MAX_FIXTURES:
                        break
            else:
                print(f"No fixtures found on the page for URL: {url}")

        except Exception as ex:
            print(f"Error processing URL {url}: {ex}")
            continue

        if matches_processed >= MAX_FIXTURES:
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
