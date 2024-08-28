import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from bs4 import BeautifulSoup

# Setup Selenium options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no GUI)

# Path to chromedriver (adjust this to match your setup)
service = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=service, options=chrome_options)

# Define the URL of the team's past matches
url = 'https://fulltime.thefa.com/results.html?selectedSeason=548186171&selectedFixtureGroupKey=&selectedRelatedFixtureOption=2&selectedClub=&selectedTeam=&selectedDateCode=all&previousSelectedFixtureGroupAgeGroup=&previousSelectedFixtureGroupKey=1_422082740&previousSelectedClub='

# Limit the number of matches to fetch
MAX_MATCHES = 10
matches_fetched = 0

def extract_match_data(row):
    columns = row.find_all('div')
    if len(columns) >= 8:
        return {
            'match_type': columns[1].text.strip(),
            'date_time': columns[2].text.strip(),
            'home_team': columns[3].text.strip(),
            'score': columns[6].text.strip(),
            'away_team': columns[7].text.strip(),
            'competition': columns[10].text.strip() if len(columns) > 10 else "N/A"
        }
    return None

def extract_lineups(soup):
    home_lineup = [player.get_text(strip=True) for player in
                   soup.select('.home-team .starters .player .name')]
    away_lineup = [player.get_text(strip=True) for player in
                   soup.select('.road-team .starters .player .name')]
    home_subs = [player.get_text(strip=True) for player in
                 soup.select('.home-team .subs .player .name')]
    away_subs = [player.get_text(strip=True) for player in
                 soup.select('.road-team .subs .player .name')]
    return home_lineup, away_lineup, home_subs, away_subs

try:
    # Load the page
    driver.get(url)

    while matches_fetched < MAX_MATCHES:
        # Wait for the table to be present
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".results-table-2"))
        )

        # Get the page source after JavaScript has loaded
        html = driver.page_source
        soup = BeautifulSoup(html, 'html.parser')
        matches_table = soup.find('div', class_='results-table-2')

        if matches_table:
            rows = matches_table.find_all('div', class_='flex middle')
            for row in rows:
                match_data = extract_match_data(row)
                if not match_data:
                    continue

                try:
                    expand_button = row.find('a', class_='expand-fixture')
                    if expand_button:
                        expand_link = expand_button['href']
                        driver.execute_script(f"document.querySelector('a[href=\"{expand_link}\"]').click();")

                        # Wait for 10 seconds
                        time.sleep(10)

                        # Get the updated page source
                        html_detail = driver.page_source
                        soup_detail = BeautifulSoup(html_detail, 'html.parser')

                        home_lineup, away_lineup, home_subs, away_subs = extract_lineups(soup_detail)

                        # Close the expanded view
                        contract_button = soup_detail.find('a', class_='contract-fixture')
                        if contract_button:
                            contract_link = contract_button['href']
                            driver.execute_script(f"document.querySelector('a[href=\"{contract_link}\"]').click();")
                            time.sleep(2)  # Wait for contraction to complete
                    else:
                        print(f"No expand button for match on {match_data['date_time']}.")
                        home_lineup = away_lineup = home_subs = away_subs = []

                except (TimeoutException, NoSuchElementException) as e:
                    print(f"Error loading details for match on {match_data['date_time']}. Error: {e}")
                    home_lineup = away_lineup = home_subs = away_subs = []

                # Print the lineups and match details
                print(f"Match Date and Time: {match_data['date_time']}")
                print(f"Home Team: {match_data['home_team']}")
                print(f"Away Team: {match_data['away_team']}")
                print(f"Score: {match_data['score']}")
                print(f"Competition: {match_data['competition']}")
                print("Home Lineup:", home_lineup)
                print("Away Lineup:", away_lineup)
                print("Home Subs:", home_subs)
                print("Away Subs:", away_subs)
                print("-" * 50)

                matches_fetched += 1
                if matches_fetched >= MAX_MATCHES:
                    break

        else:
            print("No matches table found on the page.")
            break

except Exception as e:
    print(f"An error occurred: {e}")

finally:
    # Close the WebDriver
    driver.quit()