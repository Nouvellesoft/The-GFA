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
except Exception as init_exc:
    print(f"Error initializing Firestore client: {init_exc}")
    sys.exit(1)

# Setup Selenium options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no GUI)

# Path to chromedriver (adjust this to match your setup)
service = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=service, options=chrome_options)

# Fetch club_id and URLs dynamically
club_identifier = 'patriciafc'


# Function to fetch the URLs from the 'past_matches_links' subcollection
def get_past_match_links(club_id):
    try:
        past_matches_doc_ref = db.collection('clubs').document(club_id).collection(
            'ScrapedMatchesLinks').document('past_matches_links')
        past_matches_doc = past_matches_doc_ref.get()

        if not past_matches_doc.exists:
            print(f"No past matches document found for club_id: {club_id}")
            return []

        doc_data = past_matches_doc.to_dict()

        match_urls = []
        for key, value in doc_data.items():
            if key.startswith('sc_link_') and isinstance(value, str) and value.strip():
                match_urls.append(value.strip())

        return match_urls

    except Exception as fetch_exc:
        print(f"Error fetching past match links: {fetch_exc}")
        return []


past_match_urls = get_past_match_links(club_identifier)

if not past_match_urls:
    print(f"No past match links found for club_id: {club_identifier}")
    sys.exit(1)

# Auto-incrementing ID
id_counter = 1
max_matches = 250  # Set the limit to 250 matches

# List of acronyms that should remain fully capitalized
acronyms = ['FISSC', 'AFC', 'FC', 'OBS', 'ST', '1ST']  # Add more acronyms to this list as needed


def format_text(text):
    # Remove leading/trailing whitespaces and replace multiple spaces with a single space
    text = text.strip()
    text = re.sub(r'\s+', ' ', text)

    # Capitalize text after parentheses
    def capitalize_after_parentheses(match):
        return match.group(1) + match.group(2).capitalize()

    # Regex to find text after parentheses and capitalize it
    text = re.sub(r'(\(.*?\))\s*(\w)', capitalize_after_parentheses, text)

    # Capitalize first letter of each word unless it's an acronym
    def capitalize_acronyms(word):
        match = re.match(r'\b\w+\b', word)
        if match:
            word = match.group()
            return word.upper() if word.upper() in acronyms else word.capitalize()
        return word

    # Split text by '/' and process each part separately
    parts = [part.strip() for part in text.split('/')]
    capitalized_parts = []

    for part in parts:
        # Capitalize each word or acronym
        words = part.split()
        capitalized_words = [capitalize_acronyms(word) for word in words]
        capitalized_parts.append(' '.join(capitalized_words))

    # Join the parts with '/' ensuring no extra spaces around slashes
    formatted_text = '/'.join(capitalized_parts)

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


def get_teams_from_firestore(club_id):
    try:
        teams_collection = db.collection('clubs').document(club_id).collection(
            'MatchDayBannerForClub')
        docs = teams_collection.stream()
        team_names = []
        for doc in docs:
            data = doc.to_dict()
            team_name = clean_whitespace(data.get('team_name', ''))
            team_names.append({
                'team_name': format_text(team_name),
            })
        return team_names
    except Exception as fetch_exc:
        print(f"Error fetching team names from Firestore: {fetch_exc}")
        return []


# Fetch team names from Firestore
teams = get_teams_from_firestore(club_identifier)
team_names_lower = [team['team_name'].lower() for team in teams]

# Loop through each URL
for match_url in past_match_urls:
    try:
        driver.get(match_url)

        # Wait for the table to be present
        WebDriverWait(driver, 10).until(
            ec.presence_of_element_located((By.CSS_SELECTOR, ".results-table-2"))
        )

        # Get the page source after JavaScript has loaded
        html = driver.page_source

        # Parse the HTML content of the page
        soup = BeautifulSoup(html, 'html.parser')

        # Find the table containing the past matches
        matches_table = soup.find('div', class_='results-table-2')

        if matches_table:
            # Extract rows from the table
            rows = matches_table.find_all('div', class_='flex middle')

            for row in rows:
                if id_counter > max_matches:
                    break

                columns = row.find_all('div')

                # Extract columns
                if len(columns) >= 8:
                    match_type = columns[1].text.strip()  # Match type (e.g., 'L', 'TCC')
                    date_time = clean_whitespace(columns[2].text.strip())
                    home_team = format_text(columns[3].text)
                    score = clean_whitespace(columns[6].text.strip())
                    away_team = format_text(columns[7].text)
                    competition = format_text(columns[10].text)

                    # Check and correct ")x" to ") x"
                    home_team = add_space_after_parenthesis(home_team)
                    away_team = add_space_after_parenthesis(away_team)

                    # Initialize variables for scores
                    ht_score = ""
                    at_score = ""
                    ultimate_score = ""

                    # Handle special cases
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

                    if (home_team.lower() in team_names_lower
                            or away_team.lower() in team_names_lower):
                        match_data = {
                            'away_team': away_team,
                            'home_team': home_team,
                            'id': id_counter,
                            'match_date': date_time,
                            'ht_score': ht_score,
                            'at_score': at_score,
                            'ultimate_score': ultimate_score,
                            'goalscorers': '',
                            # Placeholder if you don't have goalscorer information
                            'assists_by': '',  # Placeholder if you don't have assists information
                            'competition': competition,
                        }

                        try:
                            doc_ref = (db.collection('clubs').document(club_identifier)
                                       .collection('PastMatcheees').document(f"match_{id_counter}"))
                            doc_ref.set(match_data)
                            print(f"Data successfully written to Firestore: {match_data}")
                        except Exception as write_exc:
                            print(f"Error writing data to Firestore: {write_exc}")

                        id_counter += 1
        else:
            print(f"No past matches found on the page for URL: {match_url}")

    except Exception as e:
        print(f"Error processing URL {match_url}: {e}")
        continue

    if id_counter > max_matches:
        break

# Close the WebDriver
driver.quit()
