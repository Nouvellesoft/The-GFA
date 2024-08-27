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

# Define the URL of the team's fixtures
url = 'https://fulltime.thefa.com/displayTeam.html?id=701181330'

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

# Auto-incrementing ID
id_counter = 1

if fixtures_table:
    # Extract rows from the table
    rows = fixtures_table.find_all('tr')[1:]  # Skip the header row

    for row in rows:
        columns = row.find_all('td')

        # Extract columns
        if len(columns) >= 8:  # Ensure there are enough columns
            match_type = columns[0].text.strip()  # Match type (e.g., 'L', 'TCC')
            date_time = columns[1].text.strip()
            home_team = columns[2].text.strip()
            away_team = columns[6].text.strip()
            venue = columns[7].text.strip()

            # Replace newlines and extra whitespace
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
                try:
                    match_datetime = datetime.strptime(
                        f"{match_date_str} {match_time_str}", "%d/%m/%y %H:%M")
                except Exception as e:
                    print(f"Date parsing error: {e}")
                    continue  # Skip this entry if date parsing fails

            # Format date and time
            match_date = match_datetime.strftime("%d-%m-%Y %H:%M:%S")
            match_date_three = match_datetime.strftime("%j %H:%M")
            match_date_two = match_datetime.strftime("%d/%m/%Y %H:%M:%S")
            match_day_ko = match_datetime.strftime("%A, %I:%M%p")

            # Prepare data to push to Firestore
            match_data = {
                'away_team': away_team,
                'away_team_icon': 'https://example.com/away_team_icon.jpg',  # Example URL
                'home_team': home_team,
                'home_team_icon': 'https://example.com/home_team_icon.jpg',  # Example URL
                'id': id_counter,
                'match_date': match_date,
                'match_date_three': match_date_three,
                'match_date_two': match_date_two,
                'match_day_ko': match_day_ko,
                'venue': venue
            }

            # Push data to Firestore
            try:
                doc_ref = (db.collection('clubs').document('patriciafc')
                           .collection('UpcomingMatches').document(f"match_{id_counter}"))
                doc_ref.set(match_data)
                print(f"Data successfully written to Firestore: {match_data}")
            except Exception as e:
                print(f"Error writing data to Firestore: {e}")

            # Print formatted result
            print(f"ID: {id_counter}, Date: {match_date}, Time: {match_time_str}, "
                  f"Date Three: {match_date_three}, Date Two: {match_date_two}, "
                  f"Match Day/KO: {match_day_ko}, Home: {home_team}, "
                  f"Away: {away_team}, Venue: {venue}")

            id_counter += 1
else:
    print("No fixtures found on the page.")

# Close the WebDriver
driver.quit()
