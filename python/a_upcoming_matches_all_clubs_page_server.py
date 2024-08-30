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

# Use the desired club identifier here
club_identifier = 'patriciafc'


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


upcoming_matches_all_clubs_links_urls = get_upcoming_matches_all_clubs_links(club_identifier)

if not upcoming_matches_all_clubs_links_urls:
    print(f"No upcoming match links found for club_id: {club_identifier}")
    sys.exit(1)

# Auto-incrementing ID
id_counter = 1
max_fixtures = 50
acronyms = ["FISSC", "FC", 'AFC', 'ST', 'OBS', '1ST']


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

    formatted_text = re.sub(r'(\(.*?\))\s*(\w)', capitalize_after_parentheses, formatted_text)

    def capitalize_acronyms(word):
        match = re.match(r'\b\w+\b', word)
        if match:
            word = match.group()
            return word.upper() if word.upper() in acronyms else word.capitalize()
        return word

    parts = [part.strip() for part in formatted_text.split('/')]
    capitalized_parts = [' '.join([capitalize_acronyms(word) for word in part.split()]) for part in
                         parts]
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


for url in upcoming_matches_all_clubs_links_urls:
    if not url:
        continue

    try:
        driver.get(url)
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

                    try:
                        doc_ref = db.collection('clubs').document(club_identifier).collection(
                            'UpcomingMatchesForAllClubs').document(f"match_{id_counter}")
                        doc_ref.set(match_data)
                        print(f"Data successfully written to Firestore: {match_data}")
                    except Exception as e:
                        print(f"Error writing data to Firestore: {e}")

                    print(f"ID: {id_counter}, Date: {match_date}, Time: {match_time_str}, "
                          f"Date Three: {match_date_three}, Date Two: {match_date_two}, "
                          f"Match Day/KO: {match_day_ko}, Home: {home_team}, Away: {away_team}, "
                          f"Venue: {venue}, Competition: {competition}, Match Type: {match_type}")

                    id_counter += 1
        else:
            print(f"No fixtures found on the page for URL: {url}")

    except Exception as e:
        print(f"Error processing URL {url}: {e}")
        continue

    if id_counter > max_fixtures:
        break

driver.quit()
