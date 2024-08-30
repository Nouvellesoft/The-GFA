from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from bs4 import BeautifulSoup
from datetime import datetime
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

# Change this to the desired club identifier
club_identifier = 'patriciafc'


def get_upcoming_match_links(club_id):
    try:
        upcoming_matches_doc_ref = db.collection('clubs').document(club_id).collection(
            'ScrapedMatchesLinks').document('upcoming_matches_links')
        upcoming_matches_doc = upcoming_matches_doc_ref.get()

        if not upcoming_matches_doc.exists:
            print(f"No upcoming matches document found for club_id: {club_id}")
            return []

        doc_data = upcoming_matches_doc.to_dict()

        match_urls = []
        for key, value in doc_data.items():
            if key.startswith('sc_link_') and isinstance(value, str) and value.strip():
                match_urls.append(value.strip())

        return match_urls

    except Exception as fetch_exc:
        print(f"Error fetching upcoming match links: {fetch_exc}")
        return []


# Get URLs from Firestore
upcoming_match_urls = get_upcoming_match_links(club_identifier)

if not upcoming_match_urls:
    print(f"No upcoming match links found for club_id: {club_identifier}")
    sys.exit(1)

# Auto-incrementing ID
id_counter = 1
max_fixtures = 150

# List of acronyms that should remain fully capitalized
acronyms = ['FISSC', 'AFC', 'FC', 'OBS', 'ST', '1ST']  # Add more acronyms to this list as needed


def format_text(text):
    # Remove leading/trailing whitespaces and replace multiple spaces with a single space
    text = text.strip()
    text = re.sub(r'\s+', ' ', text)

    # List of special terms to preserve
    special_terms = ["F.C", "A.C", "S.C", "C.F", "U.F"]

    # Function to preserve special terms in the text
    def preserve_special_terms(texting):
        for term in special_terms:
            texting = texting.replace(term, f"{{{term}}}")
        return texting

    # Function to revert special terms after formatting
    def revert_special_terms(texting):
        for term in special_terms:
            texting = texting.replace(f"{{{term}}}", term)
        return texting

    # Preserve special terms before formatting
    text = preserve_special_terms(text)

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

    # Revert special terms to their original formatting
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


def get_teams_from_firestore(club_id):
    try:
        teams_collection = (db.collection('clubs')
                            .document(club_id).collection('MatchDayBannerForClub'))
        docs = teams_collection.stream()
        teams_names = []
        for doc in docs:
            data = doc.to_dict()
            team_name = clean_whitespace(data.get('team_name', ''))
            teams_names.append({
                'team_name': format_text(team_name),
            })
        return teams_names
    except Exception as exc:
        print(f"Error fetching team names from Firestore: {exc}")
        return []


teams = get_teams_from_firestore(club_identifier)
team_names = [team['team_name'].lower() for team in teams]  # List of team names for comparison

for match_url in upcoming_match_urls:
    try:
        driver.get(match_url)

        WebDriverWait(driver, 10).until(ec.presence_of_element_located((By.TAG_NAME, "table")))

        html = driver.page_source

        soup = BeautifulSoup(html, 'html.parser')

        fixtures_table = soup.find('table')

        if fixtures_table:
            rows = fixtures_table.find_all('tr')[1:]

            for row in rows:
                if id_counter > max_fixtures:
                    break

                columns = row.find_all('td')
                if len(columns) >= 10:
                    match_type = columns[0].text.strip()
                    date_time = columns[1].text.strip()
                    home_team = format_text(columns[2].text)
                    away_team = format_text(columns[6].text)
                    venue = columns[7].text.strip()
                    competition = columns[8].text.strip()

                    venue = format_text(venue)
                    competition = format_text(competition)
                    match_type = format_text(match_type)

                    venue = check_parenthesis_balance(venue)
                    home_team = add_space_after_parenthesis(home_team)
                    away_team = add_space_after_parenthesis(away_team)

                    if home_team.lower() in team_names or away_team.lower() in team_names:
                        date_time = ' '.join(date_time.split())

                        if ' ' in date_time:
                            match_date_str, match_time_str = date_time.split(' ', 1)
                        else:
                            match_date_str = date_time
                            match_time_str = ""

                        try:
                            match_datetime = (
                                datetime.strptime(f"{match_date_str} "
                                                  f"{match_time_str}", "%d/%m/%y %H:%M"))
                        except ValueError:
                            print(f"Date parsing error for match: "
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

                        try:
                            doc_ref = (db.collection('clubs').document(club_identifier)
                            .collection('UpcomingMatcheees').document(
                                f"match_{id_counter}"))
                            doc_ref.set(match_data)
                            print(f"Data successfully written to Firestore: {match_data}")
                        except Exception as e:
                            print(f"Error writing data to Firestore: {e}")

                        id_counter += 1

        else:
            print(f"No fixtures found on the page for URL: {match_url}")

    except Exception as e:
        print(f"Error processing URL {match_url}: {e}")
        continue

    if id_counter > max_fixtures:
        break

driver.quit()
