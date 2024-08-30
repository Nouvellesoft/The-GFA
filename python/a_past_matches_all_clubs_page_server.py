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


def get_past_matches_all_clubs_links(club_id):
    try:
        past_matches_all_clubs_links_doc_ref = db.collection('clubs').document(club_id).collection(
            'ScrapedMatchesLinks').document('past_matches_all_clubs_links')
        past_matches_all_clubs_links_doc = past_matches_all_clubs_links_doc_ref.get()

        if not past_matches_all_clubs_links_doc.exists:
            print(f"No upcoming matches document found for club_id: {club_id}")
            return []

        doc_data = past_matches_all_clubs_links_doc.to_dict()
        match_urls = [value.strip() for key, value in doc_data.items() if
                      key.startswith('sc_link_') and isinstance(value, str) and value.strip()]
        return match_urls

    except Exception as fetch_exc:
        print(f"Error fetching upcoming match links: {fetch_exc}")
        return []


past_matches_all_club_links_urls = get_past_matches_all_clubs_links(club_identifier)

if not past_matches_all_club_links_urls:
    print(f"No upcoming match links found for club_id: {club_identifier}")
    sys.exit(1)

# Auto-incrementing ID
id_counter = 1
max_matches = 50  # Set the limit to 50 matches

# List of acronyms to capitalize
acronyms = ["FISSC", "FC", "F.C", 'AFC', 'ST', 'OBS']


def clean_whitespace(text):
    # Remove leading and trailing whitespace and replace multiple spaces with a single space
    return re.sub(r'\s+', ' ', text.strip())


def capitalize_word(word):
    # Capitalize the word if it's an acronym; otherwise, capitalize normally
    return word.upper() if word.upper() in acronyms else word.capitalize()


def capitalize_after_parentheses(text):
    """
    Capitalize text outside parentheses, keeping the text inside parentheses unchanged.
    :param text: The text to format.
    :return: Formatted text.
    """

    def capitalize_text(texting):
        return ' '.join([capitalize_word(word) for word in texting.split()])

    # Split by parentheses and handle each part
    parts = re.split(r'(\s*\(.*?\)\s*)', text)
    formatted_parts = []

    for i, part in enumerate(parts):
        if i % 2 == 0:  # Even indexes are outside parentheses
            formatted_parts.append(capitalize_text(part))
        else:  # Odd indexes are inside parentheses
            formatted_parts.append(part)  # Keep parentheses as they are

    return ''.join(formatted_parts)


def clean_and_capitalize(text):
    """
    Capitalize acronyms, handle special cases for slashes, and remove spaces around slashes.
    :param text: The text to format.
    :return: Formatted text.
    """
    text = clean_whitespace(text)  # Remove leading/trailing whitespace and extra spaces
    text = re.sub(r'\s+', ' ', text)

    # Split text by '/' and handle each part separately
    parts = re.split(r'\s*/\s*', text)
    capitalized_parts = []

    for part in parts:
        capitalized_parts.append(capitalize_after_parentheses(part))

    return '/'.join(capitalized_parts)  # Join parts with '/' without spaces


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
for url in past_matches_all_club_links_urls:
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
                home_team = clean_and_capitalize(columns[3].text)
                score = columns[6].text.strip()
                away_team = clean_and_capitalize(columns[7].text)
                competition = clean_and_capitalize(columns[10].text)

                # Check and correct ")x" to ") x"
                home_team = add_space_after_parenthesis(home_team)
                away_team = add_space_after_parenthesis(away_team)

                # Replace newlines and extra whitespace
                date_time = ' '.join(date_time.split())

                # Initialize variables for scores
                ht_score = ""
                at_score = ""
                ultimate_score = ""

                # Handle special cases for scores
                if 'Void' in score:
                    ultimate_score = "(Void)"
                    ht_score = "V" if "V" in score.split('-')[0] else ""
                    at_score = "V" if "V" in score.split('-')[1] else ""
                elif 'Pens' in score:
                    penalty_match = re.search(r'(\(Pens \d+-\d+\))', score)
                    if penalty_match:
                        ultimate_score = penalty_match.group(1)  # Keep the brackets
                    regular_score = re.search(r'(\d+)\s*-\s*(\d+)', score)
                    if regular_score:
                        ht_score = regular_score.group(1)
                        at_score = regular_score.group(2)
                elif 'AET' in score:
                    ultimate_score = "(AET)"  # Wrapped in brackets
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
                            # Wrapped in brackets
                            ultimate_score = f"(HT {ht_match.group(1)})"
                            # Remove HT score from at_score
                            at_score = at_score.split('\n')[0].strip()
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
