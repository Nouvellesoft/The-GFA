from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

# Configure Selenium with the desired options
chrome_options = Options()
chrome_options.add_argument("window-size=1400,1500")
chrome_options.add_argument("disable-dev-shm-usage")
chrome_options.add_argument("disable-gpu")
chrome_options.add_argument("no-sandbox")
chrome_options.add_argument("headless")  # Run in headless mode
chrome_options.add_argument("user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36")

# Initialize the WebDriver
driver = webdriver.Chrome(options=chrome_options)

# Load the page
url = "https://fulltime.thefa.com/results.html?league=776003174&selectedSeason=548186171&selectedDivision=966526807&selectedTeam=&selectedFixtureGroupKey=1_372228853"
driver.get(url)

# Wait until the results table is loaded
driver.implicitly_wait(10)

# Extract the results table
results = driver.find_elements(By.CSS_SELECTOR, ".results-table-2 .tbody .flex.middle")

# Loop through the results and extract the data
for result in results:
    date_time = result.find_element(By.CSS_SELECTOR, ".datetime-col").text
    home_team = result.find_element(By.CSS_SELECTOR, ".home-team-col .team-name").text
    score = result.find_element(By.CSS_SELECTOR, ".score-col").text
    away_team = result.find_element(By.CSS_SELECTOR, ".road-team-col .team-name").text
    competition = result.find_element(By.CSS_SELECTOR, ".fg-col").text

    print(f"Date/Time: {date_time}")
    print(f"Home Team: {home_team}")
    print(f"Score: {score}")
    print(f"Away Team: {away_team}")
    print(f"Competition: {competition}")
    print("-" * 40)

# Close the WebDriver
driver.quit()
