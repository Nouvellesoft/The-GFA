from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
from datetime import datetime
from google.cloud import firestore

# Setup Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'  # Replace with your Firestore project ID
db = firestore.Client(project=FIRESTORE_PROJECT_ID)

# Setup Selenium options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no GUI)

# Path to chromedriver (adjust this to match your setup)
service = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=service, options=chrome_options)

# Define the URL for past match results
url = 'https://fulltime.thefa.com/results.html?selectedSeason=548186171&selectedFixtureGroupKey=1_372228853&selectedRelatedFixtureOption=2&selectedClub=&selectedTeam=701181330&selectedDateCode=all&previousSelectedFixtureGroupAgeGroup=&previousSelectedFixtureGroupKey=1_372228853&previousSelectedClub='

# Open the URL
driver.get(url)

# Wait for the table to be present
WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.TAG_NAME, "table"))
)

# Get the page source after JavaScript has loaded
html = driver.page_source

# Parse the HTML content of the page
soup = BeautifulSoup(html, 'html.parser')

# Find the table containing the results
results_table = soup.find('table')

# Auto-incrementing ID
id_counter = 1

if results_table:
    # Extract rows from the table
    rows = results_table.find_all('tr')[1:]  # Skip the header row

    for row in rows:
        columns = row.find_all('td')

        # Extract columns
        if len(columns) >= 5:  # Ensure there are enough columns
            match_type = columns[0].text.strip()  # Match type (e.g., 'L', 'Cup')
            date_time = columns[1].text.strip()
            home_team = columns[2].text.strip()
            score = columns[3].text.strip()
            away_team = columns[4].text.strip()

            # Split score
            if '-' in score:
                home_score, away_score = score.split('-', 1)
            else:
                home_score = away_score = ""

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
                match_datetime = datetime.strptime(f"{match_date_str} {match_time_str}", "%d/%m/%y %H:%M")
            except ValueError:
                match_datetime = datetime.strptime(f"{match_date_str} {match_time_str}", "%d/%m/%y %H:%M")

            # Format date and time
            match_date = match_datetime.strftime("%d/%m/%Y %H:%M:%S")  # Adjust format for Firestore

            # Prepare data to push to Firestore
            match_data = {
                'away_team': away_team,
                'away_team_icon': '',  # Placeholder, add actual URL if available
                'home_team': home_team,
                'home_team_icon': '',  # Placeholder, add actual URL if available
                'id': id_counter,
                'match_date': match_date,
                'at_score': away_score,
                'ht_score': home_score,
                'assists_by': '',  # Empty string as per Firestore structure
                'goalscorers': ''  # Empty string as per Firestore structure
            }

            # Push data to Firestore
            # Adjust the document path as needed
            doc_ref = db.collection('clubs').document('patriciafc').collection('PastMatches').document(f"match_{id_counter}")
            try:
                doc_ref.set(match_data)
                print(f"Data successfully written to Firestore: {match_data}")
            except Exception as e:
                print(f"Error writing data to Firestore: {e}")

            # Print formatted result
            print(f"ID: {id_counter}, Date: {match_date}, Home: {home_team}, "
                  f"Away: {away_team}, Home Score: {home_score}, Away Score: {away_score}")

            id_counter += 1
else:
    print("No results found on the page.")

# Close the WebDriver
driver.quit()
