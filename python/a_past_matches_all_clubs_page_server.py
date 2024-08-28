from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from bs4 import BeautifulSoup
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

# List of URLs to fetch data from
urls = [
    'https://fulltime.thefa.com/results/1/50.html'
    '?selectedSeason=548186171&selectedFixtureGroupAgeGroup=0'
    '&previousSelectedFixtureGroupAgeGroup=&selectedFixtureGroupKey=',


]

# Auto-incrementing ID
id_counter = 1
max_matches = 50  # Set the limit to 50 matches


def clean_whitespace(text):
    # Remove leading and trailing whitespace
    text = text.strip()
    # Replace multiple whitespaces with a single space
    return re.sub(r'\s+', ' ', text)


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
                home_team = clean_whitespace(columns[3].text)
                score = columns[6].text.strip()
                away_team = clean_whitespace(columns[7].text)
                competition = clean_whitespace(columns[10].text)

                # Replace newlines and extra whitespace
                date_time = ' '.join(date_time.split())

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
                    # Extract penalty score
                    penalty_match = re.search(r'(\(Pens \d+-\d+\))', score)
                    if penalty_match:
                        ultimate_score = penalty_match.group(1)  # Keep the brackets

                    # Extract regular time score
                    regular_score = re.search(r'(\d+)\s*-\s*(\d+)', score)
                    if regular_score:
                        ht_score = regular_score.group(1)
                        at_score = regular_score.group(2)
                elif 'AET' in score:
                    ultimate_score = "(AET)"  # Wrapped in brackets
                    # Extract regular time score
                    regular_score = re.search(r'(\d+)\s*-\s*(\d+)', score)
                    if regular_score:
                        ht_score = regular_score.group(1)
                        at_score = regular_score.group(2)
                else:
                    # Handle normal score and HT score
                    score_parts = score.split(' - ')
                    if len(score_parts) == 2:
                        ht_score, at_score = score_parts
                        # Check for HT score
                        ht_match = re.search(r'\(HT (\d+-\d+)\)', at_score)
                        if ht_match:
                            ultimate_score = f"(HT {ht_match.group(1)})"  # Wrapped in brackets
                            at_score = at_score.split('\n')[
                                0].strip()  # Remove HT score from at_score
                    else:
                        print(f"Unexpected score format: {score}")
                        continue  # Skip this row and move to the next one

                # Remove any remaining newlines and extra whitespace
                ht_score = ht_score.strip()
                at_score = at_score.strip()

                # Handle standalone 'V' or 'v'
                if ht_score.lower() == 'v':
                    ht_score = 'V'
                if at_score.lower() == 'v':
                    at_score = 'V'

                # Prepare data to push to Firestore
                match_data = {
                    'away_team': away_team,
                    'away_team_icon': 'https://example.com/away_team_icon.jpg',
                    'home_team': home_team,
                    'home_team_icon': 'https://example.com/home_team_icon.jpg',
                    'id': id_counter,
                    'match_date': date_time,
                    'ht_score': ht_score,
                    'at_score': at_score,
                    'ultimate_score': ultimate_score,
                    'goalscorers': '',  # Placeholder if you don't have goalscorer information
                    'assists_by': '',  # Placeholder if you don't have assists information
                    'competition': competition,  # Competition information
                }

                # Push data to Firestore
                try:
                    doc_ref = (db.collection('clubs').document('patriciafc')
                               .collection('PastMatchesForAllClubs')
                               .document(f"match_{id_counter}"))
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
