from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

# Setup Selenium options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run in headless mode (no GUI)

# Path to chromedriver (not necessary to specify if chromedriver is in PATH)
service = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=service, options=chrome_options)

# Define the URL of the team's fixtures
url = 'https://fulltime.thefa.com/displayTeam.html?id=701181330'

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

# Print the entire HTML for debugging
print(soup.prettify())

# Find the table containing the fixtures
fixtures_table = soup.find('table')  # Adjust based on inspected HTML

if fixtures_table:
    # Extract rows from the table
    rows = fixtures_table.find_all('tr')[1:]  # Skip the header row

    for row in rows:
        columns = row.find_all('td')
        if len(columns) >= 4:
            match_date = columns[0].text.strip()
            match_time = columns[1].text.strip()
            home_team = columns[2].text.strip()
            away_team = columns[3].text.strip()

            print(f"Date: {match_date}, "
                  f"Time: {match_time}, "
                  f"Home: {home_team}, "
                  f"Away: {away_team}")
else:
    print("No fixtures found on the page.")

# Close the WebDriver
driver.quit()
