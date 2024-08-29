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

# List of URLs to process
urls = [
    'https://fulltime.thefa.com/fixtures/1/100.html'
    '?selectedSeason=235213419&selectedFixtureGroupAgeGroup=0'
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey='
]

# Auto-incrementing ID
id_counter = 1

# Maximum number of fixtures to process
max_fixtures = 50
processed_fixtures = 0

# List of acronyms to capitalize
acronyms = ["FISSC", "FC", 'AFC', 'ST', 'OBS', '1ST']


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


# Function to add a space between a closing parenthesis and a following letter
def add_space_after_parenthesis(text):
    return re.sub(r'\)([a-zA-Z])', r') \1', text)


def check_parenthesis_balance(text):
    """
    Check if the text has an opening parenthesis without a closing one.
    If a closing parenthesis is missing, append it at the end of the text.

    :param text: The text to check.
    :return: Corrected text with balanced parentheses.
    """
    # Count the number of opening and closing parentheses
    opening_parenthesis_count = text.count('(')
    closing_parenthesis_count = text.count(')')

    # If there's an opening parenthesis without a closing one, add the closing parenthesis
    if opening_parenthesis_count > closing_parenthesis_count:
        text += ')'

    return text


# Loop through each URL
for url in urls:
    driver.get(url)

    # Wait for the table to be present
    WebDriverWait(driver, 10).until(
        ec.presence_of_element_located((By.TAG_NAME, "table"))
    )

    # Get the page source after JavaScript has loaded
    html = driver.page_source

    # Parse the HTML content of the page
    soup = BeautifulSoup(html, 'html.parser')

    # Find the table containing the fixtures
    fixtures_table = soup.find('table')

    if fixtures_table:
        # Extract rows from the table
        rows = fixtures_table.find_all('tr')[1:]  # Skip the header row

        for row in rows:
            if processed_fixtures >= max_fixtures:
                break  # Stop if we've processed the maximum number of fixtures

            columns = row.find_all('td')

            # Extract columns
            if len(columns) >= 10:  # Ensure there are enough columns
                match_type = columns[0].text.strip()  # Match type (e.g., 'L', 'TCC')
                date_time = columns[1].text.strip()
                home_team = columns[2].text.strip()
                away_team = columns[6].text.strip()
                venue = columns[7].text.strip()
                competition = columns[8].text.strip()

                # Clean up the extracted strings
                home_team = format_text(home_team)
                away_team = format_text(away_team)
                venue = format_text(venue)
                competition = format_text(competition)
                match_type = format_text(match_type)

                venue = check_parenthesis_balance(venue)  # Check and fix parentheses

                # Check and correct ")x" to ") x"
                home_team = add_space_after_parenthesis(home_team)
                away_team = add_space_after_parenthesis(away_team)

                # Replace newlines and extra whitespace in date_time
                date_time = ' '.join(date_time.split())

                # Split date_time into date and time
                if ' ' in date_time:
                    match_date_str, match_time_str = date_time.split(' ', 1)
                else:
                    match_date_str = date_time
                    match_time_str = ""

                # Convert to datetime object
                try:
                    match_datetime = datetime.strptime(
                        f"{match_date_str} {match_time_str}", "%d/%m/%y %H:%M")
                except ValueError:
                    print(
                        f"Date parsing error for match: {home_team} vs {away_team} on {date_time}")
                    continue  # Skip this entry if date parsing fails

                # Format date and time
                match_date = match_datetime.strftime("%d-%m-%Y %H:%M:%S")
                match_date_three = match_datetime.strftime("%j %H:%M")
                match_date_two = match_datetime.strftime("%d/%m/%Y %H:%M:%S")
                match_day_ko = match_datetime.strftime("%A, %I:%M%p")

                # Prepare data to push to Firestore
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

                # Push data to Firestore
                try:
                    doc_ref = (db.collection('clubs').document('patriciafc')
                               .collection('UpcomingMatchesForAllClubs')
                               .document(f"match_{id_counter}"))
                    doc_ref.set(match_data)
                    print(f"Data successfully written to Firestore: {match_data}")
                except Exception as e:
                    print(f"Error writing data to Firestore: {e}")

                # Print formatted result
                print(f"ID: {id_counter}, Date: {match_date}, Time: {match_time_str}, "
                      f"Date Three: {match_date_three}, Date Two: {match_date_two}, "
                      f"Match Day/KO: {match_day_ko}, Home: {home_team}, Away: {away_team}, "
                      f"Venue: {venue}, Competition: {competition}, Match Type: {match_type}")

                id_counter += 1
                processed_fixtures += 1
    else:
        print(f"No fixtures found on the page for URL: {url}")

# Close the WebDriver
driver.quit()
