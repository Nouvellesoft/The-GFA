from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from bs4 import BeautifulSoup
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

# List of URLs to fetch data from
urls = [
    'https://fulltime.thefa.com/results/1/50.html?selectedSeason=548186171&'
    'selectedFixtureGroupAgeGroup=0&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',
    # Add more URLs as needed
]

# Auto-incrementing ID
id_counter = 1
max_matches = 50  # Set the limit to 50 matches

# Loop through each URL
for url in urls:
    driver.get(url)

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
            if id_counter > max_matches:  # Stop if we've reached 50 matches
                break

            columns = row.find_all('div')

            # Extract columns
            if len(columns) >= 8:  # Ensure there are enough columns
                match_type = columns[1].text.strip()  # Match type (e.g., 'L', 'TCC')
                date_time = columns[2].text.strip()
                home_team = columns[3].text.strip()
                score = columns[6].text.strip()
                away_team = columns[7].text.strip()
                competition = columns[10].text.strip()

                # Replace newlines and extra whitespace
                date_time = ' '.join(date_time.split())

                # Initialize variables for scores
                ht_score = ""
                at_score = ""
                ultimate_score = ""

                # Handle special cases
                if 'Void' in score:
                    ultimate_score = "Void"
                elif '(Pens' in score:
                    # Handle penalty cases
                    normal_score, penalty_score = score.split(' (Pens ')
                    ht_score, at_score = normal_score.split(' - ')
                    ultimate_score = f"(Pens {penalty_score.strip(')')})"
                else:
                    # Handle normal score
                    ht_score, at_score = score.split(' - ')

                # Prepare data to push to Firestore
                match_data = {
                    'away_team': away_team,
                    'away_team_icon': 'https://example.com/away_team_icon.jpg',
                    'home_team': home_team,
                    'home_team_icon': 'https://example.com/home_team_icon.jpg',
                    'id': id_counter,
                    'match_date': date_time,
                    'ht_score': ht_score,  # Home team score
                    'at_score': at_score,  # Away team score
                    'ultimate_score': ultimate_score,  # Penalty or Void
                    'goalscorers': '',  # Placeholder if you don't have goalscorer information
                    'assists_by': '',  # Placeholder if you don't have assists information
                    'competition': competition,  # Competition information
                }

                # Push data to Firestore
                try:
                    doc_ref = (db.collection('clubs').document('patriciafc')
                               .collection('PastMatchees').document(f"match_{id_counter}"))
                    doc_ref.set(match_data)
                    print(f"Data successfully written to Firestore: {match_data}")
                except Exception as e:
                    print(f"Error writing data to Firestore: {e}")

                id_counter += 1
    else:
        print(f"No past matches found on the page for URL: {url}")

    if id_counter > max_matches:  # Stop the outer loop if we've reached 50 matches
        break

# Close the WebDriver
driver.quit()
