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
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',

    'https://fulltime.thefa.com/fixtures/2/100.html'
    '?selectedSeason=235213419&selectedFixtureGroupAgeGroup=0'
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',

]

# Auto-incrementing ID
id_counter = 1

# Maximum number of fixtures to process
max_fixtures = 150
processed_fixtures = 0


# Function to capitalize the first letter of each word and remove extra spaces
def format_text(text):
    cleaned_text = re.sub(' +', ' ', text.strip())  # Remove extra spaces
    return cleaned_text.title()  # Capitalize each word


# Function to clean and format team names from Firestore
def clean_team_names(team_name):
    return re.sub(r'\s+', ' ', team_name.strip()).lower()


# Fetch teams from Firestore
def get_teams_from_firestore():
    try:
        teams_collection = db.collection('clubs').document('patriciafc').collection(
            'MatchDayBannerForClub')
        docs = teams_collection.stream()
        teams_names = []
        for doc in docs:
            data = doc.to_dict()
            team_name = clean_team_names(data.get('team_name', ''))
            teams_names.append(team_name)
        return teams_names
    except Exception as exc:
        print(f"Error fetching team names from Firestore: {exc}")
        return []


# Fetch team names from Firestore
teams = get_teams_from_firestore()

# Loop through each URL
for url in urls:
    # Open the URL
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
                match_type = columns[0].text.strip()
                date_time = columns[1].text.strip()
                home_team = columns[2].text.strip()
                away_team = columns[6].text.strip()
                venue = columns[7].text.strip()
                competition = columns[8].text.strip()

                # Clean up the extracted strings
                home_team = format_text(home_team).lower()
                away_team = format_text(away_team).lower()
                venue = format_text(venue)
                competition = format_text(competition)
                match_type = format_text(match_type)

                # Check if either team is in the list of team names
                if home_team in teams or away_team in teams:
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
                        match_datetime = (
                            datetime.strptime(f"{match_date_str} {match_time_str}",
                                              "%d/%m/%y %H:%M"))
                    except ValueError:
                        print(
                            f"Date parsing error for match: "
                            f"{home_team} vs {away_team} on {date_time}")
                        continue  # Skip this entry if date parsing fails

                    # Format date and time
                    match_date = match_datetime.strftime("%d-%m-%Y %H:%M:%S")
                    match_date_three = match_datetime.strftime("%j %H:%M")
                    match_date_two = match_datetime.strftime("%d/%m/%Y %H:%M:%S")
                    match_day_ko = match_datetime.strftime("%A, %I:%M%p")

                    # Prepare data to push to Firestore
                    match_data = {
                        'away_team': away_team.title(),
                        'away_team_icon': 'https://example.com/away_team_icon.jpg',
                        'home_team': home_team.title(),
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
                        doc_ref = db.collection('clubs').document('patriciafc').collection(
                            'UpcomingMatches').document(f"match_{id_counter}")
                        doc_ref.set(match_data)
                        print(f"Data successfully written to Firestore: {match_data}")
                    except Exception as e:
                        print(f"Error writing data to Firestore: {e}")

                    # Increment counters
                    id_counter += 1
                    processed_fixtures += 1

    else:
        print(f"No fixtures found on the page for URL: {url}")

# Close the WebDriver
driver.quit()
