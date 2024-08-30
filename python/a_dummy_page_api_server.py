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

# List of URLs to process
urls = [
    'https://fulltime.thefa.com/fixtures/1/100.html'
    '?selectedSeason=235213419&selectedFixtureGroupAgeGroup=0'
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',

    'https://fulltime.thefa.com/fixtures/2/100.html'
    '?selectedSeason=235213419&selectedFixtureGroupAgeGroup=0'
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',


]

# Auto-incrementing ID
id_counter = 1
max_fixtures = 150

# Acronyms to be capitalized
acronyms = ['FISSC', 'FC', 'AFC', 'ST', 'OBS', '1ST']


def format_text(input_text):
    """
    Capitalize acronyms, handle capitalization after parentheses, and ensure proper capitalization
    for each segment split by slashes, while removing unnecessary spaces around slashes.
    Special handling for terms like "F.C" to ensure they are not cut off.

    :param input_text: The text to format.
    :return: Formatted text.
    """
    # Remove leading/trailing whitespaces and replace multiple spaces with a single space
    formatted_text = input_text.strip()
    formatted_text = re.sub(r'\s+', ' ', formatted_text)

    # List of special terms to preserve
    special_terms = ["F.C", "A.C", "S.C", "C.F", "U.F"]

    # Function to preserve special terms in the text
    def preserve_special_terms(text):
        for term in special_terms:
            text = text.replace(term, f"{{{term}}}")
        return text

    # Function to revert special terms after formatting
    def revert_special_terms(text):
        for term in special_terms:
            text = text.replace(f"{{{term}}}", term)
        return text

    # Preserve special terms before formatting
    formatted_text = preserve_special_terms(formatted_text)

    # Capitalize text after parentheses
    def capitalize_after_parentheses(match):
        return match.group(1) + match.group(2).capitalize()

    # Regex to find text after parentheses and capitalize it
    formatted_text = re.sub(r'(\(.*?\))\s*(\w)', capitalize_after_parentheses, formatted_text)

    # Capitalize first letter of each word unless it's an acronym
    def capitalize_acronyms(word):
        match = re.match(r'\b\w+\b', word)
        if match:
            word = match.group()
            return word.upper() if word.upper() in acronyms else word.capitalize()
        return word

    # Split text by '/' and process each part separately
    parts = [part.strip() for part in formatted_text.split('/')]
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


def get_teams_from_firestore():
    try:
        teams_collection = (db.collection('clubs')
                            .document('patriciafc').collection('MatchDayBannerForClub'))
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


teams = get_teams_from_firestore()
team_names = [team['team_name'].lower() for team in teams]  # List of team names for comparison


for url in urls:
    driver.get(url)
    (WebDriverWait(driver, 10)
     .until(ec.presence_of_element_located((By.TAG_NAME, "table"))))
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
                        doc_ref = (db.collection('clubs').document('patriciafc')
                                   .collection('UpcomingMatches').document(f"match_{id_counter}"))
                        doc_ref.set(match_data)
                        print(f"Data successfully written to Firestore: {match_data}")
                    except Exception as e:
                        print(f"Error writing data to Firestore: {e}")

                    id_counter += 1

    else:
        print(f"No fixtures found on the page for URL: {url}")

driver.quit()
