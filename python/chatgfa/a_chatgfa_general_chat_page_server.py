import logging
import os
import subprocess
import sys
import traceback
from datetime import datetime
from pathlib import Path

import spacy
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_caching import Cache
from flask_cors import CORS
from fuzzywuzzy import process
from google.cloud import firestore
from openai import OpenAI

# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configure Flask-Caching
app.config['CACHE_TYPE'] = 'SimpleCache'
app.config['CACHE_DEFAULT_TIMEOUT'] = 300  # Cache timeout in seconds
cache = Cache(app)

# Set up logging
logging.basicConfig(level=logging.INFO)

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Initialize Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'
db = firestore.Client(project=FIRESTORE_PROJECT_ID)


# Function to format date with day suffix
def format_date_with_suffix(date_obj):
    day = date_obj.day
    if 10 <= day <= 20:  # Special case for 11th, 12th, 13th, etc.
        suffix = 'th'
    else:
        suffix = {1: 'st', 2: 'nd', 3: 'rd'}.get(day % 10, 'th')

    return date_obj.strftime(f"%A {day}{suffix}, %B %Y")


# Helper function: Fetch and cache AboutClub data
@cache.cached(timeout=300, key_prefix="about_club_{club_id}")
def get_about_club(club_id):
    try:
        about_club_ref = db.collection('clubs').document(club_id).collection('AboutClub').document(
            'about_club_page')
        about_club_data = about_club_ref.get().to_dict()
        return about_club_data
    except Exception as e:
        logging.error(f"Error fetching AboutClub data: {e}")
        return None


# Helper function: Fetch and cache PlayersTable data
@cache.cached(timeout=300, key_prefix="players_data_{club_id}")
def get_players_data(club_id):
    try:
        players_table_ref = db.collection('clubs').document(club_id).collection('PllayersTable')
        player_docs = players_table_ref.stream()
        players_data = [player_doc.to_dict() for player_doc in player_docs]
        return players_data
    except Exception as e:
        logging.error(f"Error fetching PlayersTable data: {e}")
        return []


# Helper function: Fetch and cache Captains data
@cache.cached(timeout=300, key_prefix="captains_data_{club_id}")
def get_captains_data(club_id):
    try:
        captains_ref = db.collection('clubs').document(club_id).collection('Captains')
        captains_docs = captains_ref.stream()
        captains_data = [doc.to_dict() for doc in captains_docs]
        return captains_data
    except Exception as e:
        logging.error(f"Error fetching Captains data: {e}")
        return []


# Helper function: Fetch and cache ClubSponsors data
@cache.cached(timeout=300, key_prefix="club_sponsors_{club_id}")
def get_club_sponsors(club_id):
    try:
        sponsors_ref = db.collection('clubs').document(club_id).collection('ClubSponsors')
        sponsor_docs = sponsors_ref.stream()
        sponsors_data = [doc.to_dict() for doc in sponsor_docs]
        return sponsors_data
    except Exception as e:
        logging.error(f"Error fetching ClubSponsors data: {e}")
        return []


# Helper function: Fetch and cache Coaches data
@cache.cached(timeout=300, key_prefix="coaches_data_{club_id}")
def get_coaches_data(club_id):
    try:
        coaches_ref = db.collection('clubs').document(club_id).collection('Coaches')
        coach_docs = coaches_ref.stream()
        coaches_data = [doc.to_dict() for doc in coach_docs]
        return coaches_data
    except Exception as e:
        logging.error(f"Error fetching Coaches data: {e}")
        return []


@cache.cached(timeout=300, key_prefix="management_data_{club_id}")
def get_management_data(club_id):
    try:
        management_ref = db.collection('clubs').document(club_id).collection('ManagementBody')
        management_docs = management_ref.stream()
        management_data = [doc.to_dict() for doc in management_docs]
        return management_data
    except Exception as e:
        logging.error(f"Error fetching management data: {e}")
        return []


@cache.cached(timeout=300, key_prefix="coaches_monthly_comments_{club_id}")
def get_coaches_monthly_comments(club_id):
    try:
        comments_ref = db.collection('clubs').document(club_id).collection('CoachesMonthlyComments')
        comments_docs = comments_ref.stream()
        comments_data = [doc.to_dict() for doc in comments_docs]
        return comments_data
    except Exception as e:
        logging.error(f"Error fetching CoachesMonthlyComments data: {e}")
        return []


@cache.cached(timeout=300, key_prefix="founders_monthly_comments_{club_id}")
def get_founders_monthly_comments(club_id):
    try:
        comments_ref = db.collection('clubs').document(club_id).collection(
            'FoundersMonthlyComments')
        comments_docs = comments_ref.stream()
        comments_data = [doc.to_dict() for doc in comments_docs]
        return comments_data
    except Exception as e:
        logging.error(f"Error fetching FoundersMonthlyComments data: {e}")
        return []


@cache.cached(timeout=300, key_prefix="upcoming_matches_{club_id}")
def get_upcoming_matches(club_id):
    try:
        logging.info(f"Fetching upcoming matches for club_id: {club_id}")
        matches_ref = db.collection('clubs').document(club_id).collection('UpcomingMatches')
        matches_docs = matches_ref.stream()

        if not matches_docs:
            logging.warning(f"No matches found for club_id: {club_id}")
            return []

        upcoming_matches = []
        for match in matches_docs:
            match_data = match.to_dict()
            logging.info(f"Fetched match data: {match_data}")  # Log the fetched data

            # Extract match details
            home_team = match_data.get("home_team", "Unknown")
            away_team = match_data.get("away_team", "Unknown")
            venue = match_data.get("venue", "Unknown")
            competition = match_data.get("competition", "Unknown")
            match_date_str = match_data.get("match_date",
                                            "Date not available")  # Using match_date here

            try:
                # Convert match_date string to datetime object for comparison
                match_date = datetime.strptime(match_date_str,
                                               "%d-%m-%Y %H:%M:%S")  # Adjust to match your format
                # Format the date to the desired string format
                formatted_upcoming_matches_date = format_date_with_suffix(match_date)
            except ValueError:
                # If the date is not in the expected format, skip this match
                continue

            # Ensure required fields exist
            if home_team and away_team and venue and competition and match_date:
                upcoming_matches.append({
                    "home_team": home_team,
                    "away_team": away_team,
                    "venue": venue,
                    "competition": competition,
                    "match_date": formatted_upcoming_matches_date,  # Use the formatted date string
                    "match_date_object": match_date,  # Store the datetime object for sorting
                    "id": match_data.get("id")  # Ensure that the id is captured correctly
                })
            else:
                logging.warning(f"Missing required fields for match ID {match_data.get('id')}")

        # Sort matches by 'id' (ascending)
        upcoming_matches.sort(key=lambda x: x["id"])

        # Limit the response to the next 5 matches
        limited_matches = upcoming_matches[:5]
        logging.info(f"Returning {len(limited_matches)} upcoming matches: {limited_matches}")

        return limited_matches
    except Exception as e:
        logging.error(f"Unexpected error fetching matches for club_id {club_id}: {e}")
        return []


@cache.cached(timeout=300, key_prefix="past_matches_{club_id}")
def get_past_matches(club_id):
    try:
        logging.info(f"Fetching past matches for club_id: {club_id}")
        matches_ref = db.collection('clubs').document(club_id).collection('PastMatches')
        matches_docs = matches_ref.stream()

        if not matches_docs:
            logging.warning(f"No past matches found for club_id: {club_id}")
            return []

        past_matches = []
        for match in matches_docs:
            match_data = match.to_dict()
            logging.info(f"Fetched match data: {match_data}")

            # Extract match details
            home_team = match_data.get("home_team", "Unknown")
            away_team = match_data.get("away_team", "Unknown")
            venue = match_data.get("venue", "Unknown")
            competition = match_data.get("competition", "Unknown")
            match_date_str = match_data.get("match_date", "Date not available")
            ht_score = match_data.get("ht_score", "0")
            at_score = match_data.get("at_score", "0")

            try:
                # Convert match_date string to datetime object for comparison (if needed)
                match_date = datetime.strptime(match_date_str,
                                               "%d/%m/%y %H:%M")  # Adjust format as necessary
                # Format the date to the desired string format
                formatted_past_matches_date = format_date_with_suffix(match_date)
            except ValueError:
                # match_date = "Date not available"
                continue

            # Ensure required fields exist
            if home_team and away_team and venue and competition and match_date:
                past_matches.append({
                    "home_team": home_team,
                    "away_team": away_team,
                    "venue": venue,
                    "competition": competition,
                    "match_date": formatted_past_matches_date,  # Use the formatted date string
                    "match_date_object": match_date,  # Store the datetime object for sorting
                    "ht_score": ht_score,
                    "at_score": at_score,
                    "id": match_data.get("id")  # Ensure that the id is captured correctly
                })
            else:
                logging.warning(f"Missing required fields for match ID {match_data.get('id')}")

        # Sort matches by 'id' (ascending)
        past_matches.sort(key=lambda x: x["id"])

        # Limit the response to the 4 most recent past matches
        return past_matches[:5]

    except Exception as e:
        logging.error(f"Unexpected error fetching past matches for club_id {club_id}: {e}")
        return []


@cache.cached(timeout=300, key_prefix="training_data_{club_id}")
def get_training_data(club_id):
    try:
        training_ref = db.collection('clubs').document(club_id).collection('TrainingDays')
        training_docs = training_ref.stream()
        training_data = [doc.to_dict() for doc in training_docs]
        return training_data
    except Exception as e:
        logging.error(f"Error fetching Training data: {e}")
        return []


# Intent detection - Updated version
def detect_intent(input_text):
    input_text_lower = input_text.lower()
    print(f"Input text (lowercase): {input_text_lower}")

    if ("founder comment" in input_text_lower or "founders comment" in input_text_lower
            or "latest comment by founder" in input_text_lower or "latest comment by manager"
            in input_text_lower or "manager comment" in input_text_lower or "managers comment"
            in input_text_lower):
        return "founder_comment", {"founder_name": extract_manager_name(input_text, [])}

    # Check for coach's latest comment query
    if ("latest comment" in input_text_lower or "coach comments"
            in input_text_lower or "monthly comments" in input_text_lower
            or "comment" in input_text_lower):
        return "coach_comment", {"coach_name": extract_coach_name(input_text, [])}

    if ("training day" in input_text_lower or "training days" in input_text_lower
            or "when is the training" in input_text_lower):
        return "training_days", {}

    # Check for general coach queries
    if "coach" in input_text_lower or "coaches" in input_text_lower:
        return "coaches_info", {}

    # Check for player of the month query
    if "player of the month" in input_text_lower:
        return "top_performers", {}

    # Check for player stats query
    if "stats" in input_text_lower or "info" in input_text_lower:
        return "player_info", {"player_name": extract_player_name(input_text)}

    # Check for club-related queries
    if "founded" in input_text_lower or "history" in input_text_lower:
        return "club_info", {}

    # Check for top performers (top scorer)
    if "who scored the most" in input_text_lower or "top scorer" in input_text_lower:
        return "top_performers", {}

    # Check for player position query
    if ("where" in input_text_lower and "play" in input_text_lower and "position" not in
            input_text_lower):
        return "player_position", {"player_name": extract_player_name(input_text)}

    # Check for captain queries
    if "captain" in input_text_lower:
        return "captains_info", {}

    # Check for sponsorship queries
    if "sponsor" in input_text_lower or "sponsorship" in input_text_lower:
        return "club_sponsors", {}

    if ("upcoming matches" in input_text_lower or "next matches" in input_text_lower
            or "fixture" in input_text_lower):
        return "upcoming_matches", {}

    # Check for past matches
    if ("past match" in input_text_lower or "last match" in input_text_lower
            or "previous match" in input_text_lower or "recent match" in input_text_lower
            or "past matches" in input_text_lower or "scores" in input_text_lower):
        return "past_matches", {}

    # Management Queries
    if any(keyword in input_text_lower for keyword in
           ["who founded", "founder", "management", "manager", "managers"]):
        return "management_info", {}

    # Catch-all player-related queries
    if any(keyword in input_text_lower for keyword in ["goals", "age", "position", "player"]):
        return "player_info", {"player_name": extract_player_name(input_text)}

    return "general_query", {}


def detect_intent_and_field(input_text):
    # This function can use a basic keyword search or more advanced NLP
    fields = [
        "autobio", "best_moment", "captain", "constituent_country", "d_o_b", "dream_fc",
        "email", "facebook", "fav_football_legend", "hobbies", "nickname", "philosophy",
        "phone", "position_playing", "region_from", "ronaldo_or_messi", "team_captaining",
        "twitter", "worst_moment"
    ]

    # Detect the player name (this can be based on an NLP model or entity extraction)
    player_name = extract_player_name(input_text)

    # Detect which field is being requested (if any)
    requested_field = None
    for field in fields:
        if field.lower() in input_text.lower():
            requested_field = field
            break

    return player_name, requested_field


# Helper function: Extract player name

def ensure_spacy_model():
    """
    Attempt to download SpaCy model using subprocess to avoid deployment issues
    """
    try:
        # Try to load the model first
        spacy.load("en_core_web_sm")
        return True
    except OSError:
        try:
            # Use subprocess to download the model
            result = subprocess.run([sys.executable, "-m", "spacy", "download", "en_core_web_sm"],
                                    capture_output=True, text=True)

            # Log the output for debugging
            if result.stdout:
                logging.info(f"SpaCy model download stdout: {result.stdout}")
            if result.stderr:
                logging.warning(f"SpaCy model download stderr: {result.stderr}")

            return result.returncode == 0
        except Exception as e:
            logging.error(f"Failed to download SpaCy model: {e}")
            return False


# Modify your existing SpaCy initialization
nlp = None
try:
    # Attempt to load or download the model
    ensure_spacy_model()
    nlp = spacy.load("en_core_web_sm")
except Exception as ex:
    logging.error(f"SpaCy initialization error: {ex}")
    nlp = None


def extract_player_name(input_text):
    global nlp

    # If no model, attempt to download
    if nlp is None:
        ensure_spacy_model()
        try:
            nlp = spacy.load("en_core_web_sm")
        except Exception as e:
            logging.error(f"Failed to load SpaCy model: {e}")
            return fallback_name_extraction(input_text)

    # SpaCy-based name extraction
    doc = nlp(input_text)
    player_candidates = [ent.text.strip() for ent in doc.ents if ent.label_ == "PERSON"]

    logging.info(f"SpaCy detected entities: {player_candidates}")

    return player_candidates[0] if player_candidates else fallback_name_extraction(input_text)


def fallback_name_extraction(input_text):
    import re

    # Look for potential name patterns
    name_patterns = [
        r'\b([A-Z][a-z]+ [A-Z][a-z]+)\b',  # Two capitalized words
        r'\b(Mr\. [A-Z][a-z]+ [A-Z][a-z]+)\b',  # With Mr.
        r'\b([A-Z][a-z]+ [A-Z]\.[A-Z][a-z]+)\b'  # Middle initial
    ]

    for pattern in name_patterns:
        matches = re.findall(pattern, input_text)
        if matches:
            return matches[0]

    # Fallback to first two capitalized words
    words = input_text.split()
    potential_names = [f"{words[i]} {words[i + 1]}"
                       for i in range(len(words) - 1)
                       if words[i][0].isupper() and words[i + 1][0].isupper()]

    return potential_names[0] if potential_names else None


# Helper function to extract coach name from user input
def extract_coach_name(input_text, coaches_data):
    """
    Extract a coach name from the input text based on the available coaches data.

    Args:
        input_text (str): The user's query text.
        coaches_data (list): List of coaches with their details.

    Returns:
        str: The most likely coach name or None if no match is found.
    """
    # List of coach names from the data
    coach_names = [coach.get('name', '') for coach in coaches_data]

    # Use fuzzy matching to find the best match
    best_match = process.extractOne(input_text, coach_names)

    if best_match and best_match[1] > 70:  # Threshold for matching confidence
        return best_match[0]

    return None


def extract_manager_name(input_text, management_data):
    """
    Extract a manager name from the input text based on the available management data.

    Args:
        input_text (str): The user's query text.
        management_data (list): List of management with their details.

    Returns:
        str: The most likely manager name or None if no match is found.
    """
    # List of manager names from the data
    manager_names = [manager.get('name', '') for manager in management_data]

    # Use fuzzy matching to find the best match
    best_match = process.extractOne(input_text, manager_names)

    if best_match and best_match[1] > 70:  # Threshold for matching confidence
        return best_match[0]

    return None


# Helper function: Get player info
def get_player_info(players_data, player_name):
    if not player_name or not players_data:
        return None

    # Normalize input and player names
    player_name_normalized = player_name.lower().strip()

    # First try exact match (case-insensitive)
    exact_match = next(
        (p for p in players_data if p.get("player_name", "").lower() == player_name_normalized),
        None
    )
    if exact_match:
        return exact_match

    # If no exact match, use fuzzy matching with logging
    matches = process.extractBests(
        player_name,
        [p.get("player_name", "") for p in players_data],
        score_cutoff=70,
        limit=3
    )

    logging.info(f"Fuzzy matches for '{player_name}': {matches}")

    if matches:
        best_match = matches[0]
        matched_player = next(
            (p for p in players_data if p.get("player_name") == best_match[0]),
            None
        )
        logging.info(
            f"Selected match: {matched_player.get('player_name') if matched_player else 'None'}")
        return matched_player

    return None


def get_players_full_data(club_id):
    try:
        # List of team collections to check
        team_collections = [
            'FirstTeamClassPlayers',
            'SecondTeamClassPlayers',
            'ThirdTeamClassPlayers',
            'FourthTeamClassPlayers',
            'FifthTeamClassPlayers',
            'SixthTeamClassPlayers'
        ]

        players_data = []

        # Loop through each team collection and get the player data
        for team in team_collections:
            players_ref = db.collection('clubs').document(club_id).collection(team)
            players_docs = players_ref.stream()

            for player in players_docs:
                player_data = player.to_dict()
                players_data.append(player_data)

        return players_data

    except Exception as e:
        logging.error(f"Error fetching players data for club {club_id}: {e}")
        return []


def get_top_performers(players_data):
    # Find the top scorer
    top_scorer = max(players_data, key=lambda x: x.get("goals_scored", 0), default=None)

    # Find all players of the month
    player_of_the_month = [p for p in players_data if
                           p.get("player_of_the_month", "").lower() == "yes"]

    return {
        "top_scorer": top_scorer,
        "player_of_the_month": player_of_the_month
    }


# Updated player info handler
def handle_player_info_query(players_data, player_name):
    if not player_name:
        return jsonify({"message": "Please specify a player name."})

    logging.info(f"Searching for player: {player_name}")
    logging.info(f"Total players in database: {len(players_data)}")

    # Search through all players
    best_player = get_player_info(players_data, player_name)

    if best_player:
        player_name = best_player.get("player_name", "Unknown Player")
        goals = best_player.get("goals_scored", 0)
        assists = best_player.get("assists", 0)
        age = best_player.get("age", "Unknown")
        position = best_player.get("player_position", "Unknown")
        nationality = best_player.get("nationality", "Unknown")
        preferred_foot = best_player.get("preferred_foot", "Unknown")
        matches_played = best_player.get("matches_played", 0)
        matches_started = best_player.get("matches_started", 0)
        yellow_card = best_player.get("yellow_card", 0)
        red_card = best_player.get("red_card", 0)

        response_text = (
            f"{player_name} stats are presented below:\n\n"
            f"Age: {age}\n"
            f"Position: {position}\n"
            f"Nationality: {nationality}\n"
            f"Preferred Foot: {preferred_foot}\n"
            f"Matches Played: {matches_played}\n"
            f"Matches Started: {matches_started}\n"
            f"Goals: {goals}\n"
            f"Assists: {assists}\n"
            f"Yellow Card(s): {yellow_card}\n"
            f"Red Card(s): {red_card}"
        )
        logging.info(f"Found player info: {response_text}")
        return jsonify({"message": response_text})

    logging.info(f"No player found matching: {player_name}")
    return jsonify({"message": f"Could not find detailed information for {player_name}."})


def get_player_full_data_by_name(players_data, player_name):
    # Loop through the list of players to find the matching player by name
    for player in players_data:
        if player.get("name") == player_name:
            return player
    return None


def handle_player_full_info_query(players_data, player_name, requested_field=None):
    # Fetch the player data
    player_data = get_player_full_data_by_name(players_data, player_name)

    if player_data:
        # If a specific field is requested, return just that field
        if requested_field:
            # Check if the field exists in the player's data
            field_value = player_data.get(requested_field, "Field not found.")
            return jsonify({requested_field: field_value}), 200
        else:
            # Return all player data if no specific field is requested
            return jsonify({"player_full_info": player_data}), 200
    else:
        return jsonify({"message": f"Player {player_name} not found."}), 404


# Handle club-specific queries
def handle_club_info_query(about_club_data, input_text):
    input_text_lower = input_text.lower()

    if "founded" in input_text.lower():
        founding_date = about_club_data.get("founding_date", "Unknown")
        founders = about_club_data.get("founders", "Unknown")
        return jsonify({"message": f"The club was founded on {founding_date} by {founders}."})

    if "mission" in input_text.lower():
        mission_statement = about_club_data.get("mission_statement",
                                                "Mission statement not available.")
        return jsonify({"message": f"The club's mission: {mission_statement}"})

    if "core values" in input_text.lower():
        core_values = about_club_data.get("core_values", "No core values listed.")
        return jsonify({"message": f"The club's core values are: {core_values}"})

    if "instagram" in input_text.lower():
        instagram = about_club_data.get("instagram_handle", "not available")
        return jsonify({"message": f"The club's Instagram handle is {instagram}."})

    if "facebook" in input_text.lower():
        facebook = about_club_data.get("facebook_handle", "not available")
        return jsonify({"message": f"The club's Facebook page is {facebook}."})

    if "activities" in input_text_lower:
        ext_activities = about_club_data.get("ext_activities", "No activities listed.")
        return jsonify(
            {"message": f"The club organizes the following activities: {ext_activities}"})

    if "training" in input_text_lower:
        training_types = about_club_data.get("training_types", "No training programs listed.")
        return jsonify(
            {"message": f"The club offers the following training programs: {training_types}"})

    if "why" in input_text_lower and "club" in input_text_lower:
        why_club = about_club_data.get("why_club", "No information available.")
        return jsonify({"message": f"Why the club exists: {why_club}"})

    if "social media" in input_text_lower or "handles" in input_text_lower:
        facebook = about_club_data.get("facebook_handle", "not available")
        instagram = about_club_data.get("instagram_handle", "not available")
        twitter = about_club_data.get("twitter_handle", "not available")
        return jsonify({
            "message": f"The club's social media handles are:\nFacebook: "
                       f"{facebook}\nInstagram: {instagram}\nTwitter: {twitter}"})

    return jsonify({"message": "I couldn't find information about that."})


# General query handler
def handle_general_query(about_club_data, players_data, input_text):
    combined_context = {
        "club_info": about_club_data,
        "top_performers": sorted(players_data, key=lambda x: x.get('goals_scored', 0),
                                 reverse=True)[:3]
    }

    openai_response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are an assistant for a football club."},
            {"role": "user", "content": input_text},
            {"role": "system",
             "content": f"Here is some context about the club:\n{combined_context}"}
        ],
        max_tokens=200,
        temperature=0.7
    )
    return jsonify({"message": openai_response.choices[0].message.content.strip()})


def handle_top_performers_query(players_data):
    top_performers = get_top_performers(players_data)

    player_of_the_month = top_performers["player_of_the_month"]
    top_scorer = top_performers["top_scorer"]

    response_message = []

    if "player of the month" in request.json.get('text', '').lower():
        if player_of_the_month:
            for player in player_of_the_month:
                response_message.append(
                    f"{player.get('player_name', 'Unknown')} is the player of the month, "
                    f"some of his current stats includes: \n\n"
                    f"Position: {player.get('player_position', 'Unknown')}\n"
                    f"Goals: {player.get('goals_scored', 0)}\n"
                    f"Assists: {player.get('assists', 0)}\n"
                    f"Matches Played: {player.get('matches_played', 0)}"
                )
        else:
            response_message.append("There are no players of the month currently.")
    else:
        if top_scorer:
            response_message.append(
                f"The top scorer is {top_scorer.get('player_name', 'Unknown')}, "
                f"with {top_scorer.get('goals_scored', 0)} goals."
            )
        if player_of_the_month:
            names = ", ".join(p.get("player_name", "Unknown") for p in player_of_the_month)
            response_message.append(f"The player(s) of the month: {names}.")

    return jsonify({"message": "\n\n".join(response_message)})


# Handle captain-related queries
def handle_captains_query(captains_data):
    if not captains_data:
        return jsonify({"message": "No captains data available."})

    response_message = []
    for captain in captains_data:
        name = captain.get("name", "Unknown Captain")
        team = captain.get("team_captaining", "Unknown Team")
        if team == "First Team":
            response_message.append(f"Captain {name} is leading the First Team.")
        elif team == "Reserve Team":
            response_message.append(f"Captain {name} is leading the Reserve Team.")
        elif team == "Third Team":
            response_message.append(f"Captain {name} is leading the Third Team.")
        else:
            response_message.append(f"Captain {name} is leading the {team}.")

    return jsonify({"message": "\n\n".join(response_message)})


# Handle sponsor-related queries
def handle_club_sponsors_query(sponsors_data, input_text):
    if not sponsors_data:
        return jsonify({"message": "No sponsor data available."})

    response_message = []
    input_text_lower = input_text.lower()

    if "sponsor" in input_text_lower or "sponsors" in input_text_lower:
        sponsor_names = "\n".join([sponsor.get("name", "Unknown") for sponsor in sponsors_data])
        response_message.append(f"The club's sponsors are: \n\n{sponsor_names}.\n")
    # elif "services" in input_text_lower: for sponsor in sponsors_data: name = sponsor.get(
    # "name", "Unknown") services = sponsor.get("our_services", "No services listed.")
    # response_message.append(f"{name} provides the following services: {services}") elif
    # "contact" in input_text_lower or "email" in input_text_lower: for sponsor in sponsors_data:
    # name = sponsor.get("name", "Unknown") email = sponsor.get("email", "No email provided.")
    # phone = sponsor.get("phone", "No phone number provided.") x = sponsor.get("twitter",
    # "No X username provided.") facebook = sponsor.get("facebook", "No facebook username
    # provided.") instagram = sponsor.get("instagram", "No instagram username provided.") website
    # = sponsor.get("website", "No website provided.") response_message.append(f"{name}'s contact
    # details:\nEmail: {email}\nPhone: {phone}\nPhone: {website}\nWebsite: { "
    # "instagram}\nInstagram: {facebook}\nFacebook: {x}")
    else:
        response_message.append(
            "I can provide details about the club's sponsors, their services, or contact "
            "information. Please specify."
        )

    return jsonify({"message": "\n\n".join(response_message)})


def handle_coaches_query(coaches_data, coach_name=None):
    if not coaches_data:
        return jsonify({"message": "No coach data available."})

    if coach_name:
        # Search for the specific coach
        coach_info = next(
            (c for c in coaches_data if c.get("name", "").lower() == coach_name.lower()), None
        )
        if coach_info:
            response = (
                f"{coach_info.get('name', 'Unknown Coach')} serves as "
                f"{coach_info.get('staff_position', 'a coach')}. "
                f"They believe in '{coach_info.get('philosophy', 'N/A')}'.\n"
                f"Contact: {coach_info.get('email', 'N/A')} | {coach_info.get('phone', 'N/A')}."
            )
            return jsonify({"message": response})
        return jsonify({"message": f"No coach found with the name {coach_name}."})

    # If no specific name, list all coaches
    response = "The coaches at the club are:\n"
    for coach in coaches_data:
        response += (f"- {coach.get('name', 'Unknown Coach')} "
                     f"({coach.get('staff_position', 'N/A')})\n")

    return jsonify({"message": response})


def handle_management_query(management_data, manager_name=None):
    if not management_data:
        return jsonify({"message": "No manager data available."})

    if manager_name:
        # Search for the specific manager
        manager_info = next(
            (c for c in management_data if c.get("name", "").lower() == manager_name.lower()), None
        )
        if manager_info:
            response = (
                f"{manager_info.get('name', 'Unknown Manager')} "
                f"serves as {manager_info.get('staff_position', 'a manager')}. "
                f"They believe in '{manager_info.get('philosophy', 'N/A')}'.\n"
                f"Contact: {manager_info.get('email', 'N/A')} | "
                f"{manager_info.get('phone', 'N/A')}."
            )
            return jsonify({"message": response})
        return jsonify({"message": f"No manager found with the name {manager_name}."})

    # If no specific name, list all management
    response = "The Managers at the club are:\n"
    for manager in management_data:
        response += (f"- {manager.get('name', 'Unknown Manager')} "
                     f"({manager.get('staff_position', 'N/A')})\n")

    return jsonify({"message": response})


def handle_coach_comment_query(coach_name, club_id):
    try:
        comments_data = get_coaches_monthly_comments(club_id)

        # Filter comments for the specified coach
        coach_comments = [comment for comment in comments_data if
                          comment.get('name', '').lower() == coach_name.lower()]

        if not coach_comments:
            return jsonify({"message": f"No comments found for Coach {coach_name}."})

        # Sort by date to get the latest comment
        coach_comments_sorted = sorted(coach_comments, key=lambda x: x.get('date', ''),
                                       reverse=True)
        latest_comment = coach_comments_sorted[0]

        response = (
            f"Coach {latest_comment.get('name', 'Unknown Coach')} "
            f"commented in {latest_comment.get('date', 'Unknown Date')}: "
            f"\"{latest_comment.get('comment', 'No comment available')}\""
        )
        return jsonify({"message": response})
    except Exception as e:
        logging.error(f"Error handling coach comment query: {e}")
        return jsonify({"error": "An error occurred while processing the request."}), 500


def handle_founder_comment_query(founder_name, club_id):
    try:
        comments_data = get_founders_monthly_comments(club_id)

        # Filter comments for the specified founder
        founder_comments = [comment for comment in comments_data if
                            comment.get('name', '').lower() == founder_name.lower()]

        if not founder_comments:
            return jsonify({"message": f"No comments found for Founder {founder_name}."})

        # Sort by date to get the latest comment
        founder_comments_sorted = sorted(founder_comments, key=lambda x: x.get('date', ''),
                                         reverse=True)
        latest_comment = founder_comments_sorted[0]

        response = (
            f"Founder {latest_comment.get('name', 'Unknown Founder')} "
            f"commented in {latest_comment.get('date', 'Unknown Date')}: "
            f"\"{latest_comment.get('comment', 'No comment available')}\""
        )
        return jsonify({"message": response})
    except Exception as e:
        logging.error(f"Error handling founder comment query: {e}")
        return jsonify({"error": "An error occurred while processing the request."}), 500


def handle_upcoming_matches_query(upcoming_matches_data):
    if not upcoming_matches_data:
        return jsonify({"message": "No upcoming matches found for this club."}), 404

    # Create a list to hold the match details
    matches_response = ["The next 4 upcoming matches are:\n"]

    for idx, match in enumerate(upcoming_matches_data, start=1):
        # Fetch match details
        home_team = match.get("home_team", "Unknown")
        away_team = match.get("away_team", "Unknown")
        match_date = match.get("match_date", "Date not available")  # This is now formatted
        venue = match.get("venue", "")
        competition = match.get("competition", "")

        # Construct the match info with numbering
        match_info = f"Match {idx}: {home_team} vs {away_team} on {match_date}"
        if venue:
            match_info += f" at {venue}"
        if competition:
            match_info += f" ({competition})"

        # Append the match info to the list
        matches_response.append(match_info)

    # Join all match details into a single string with line breaks
    return jsonify({"message": "\n\n".join(matches_response)})


def handle_past_matches_query(past_matches_data):
    if not past_matches_data:
        return jsonify({"message": "No past matches found for this club."}), 404

    matches_response = ["The past 4 previous matches are:\n"]

    for idx, match in enumerate(past_matches_data, start=1):
        # Fetch match details
        home_team = match.get("home_team", "Unknown")
        away_team = match.get("away_team", "Unknown")
        match_date = match.get("match_date", "Date not available")
        # venue = match.get("venue", "")
        competition = match.get("competition", "")
        home_score = match.get("ht_score", "N/A")
        away_score = match.get("at_score", "N/A")

        # Format the match info
        match_info = (f"Match {idx}: {home_team} vs {away_team} - "
                      f"[{home_score} - {away_score}] on {match_date}")
        # if venue:
        #     match_info += f" at {venue}"
        if competition:
            match_info += f" ({competition})"

        matches_response.append(match_info)

    return jsonify({"message": "\n\n".join(matches_response)})


def handle_training_days_query(training_data):
    if not training_data:
        return jsonify({"message": "No training days information available for this club."}), 404

    # Initialize a list to collect training information
    response_message = ["The club's training day(s) are:\n"]

    # Loop through the training data (assuming you may have multiple entries)
    for training in training_data:
        day = training.get("day", "Unknown")
        from_time = training.get("from_time", "Unknown")
        to_time = training.get("to_time", "Unknown")
        location = training.get("location", "Unknown")
        post_code = training.get("post_code", "Unknown")

        # Construct the training schedule message for this entry
        training_info = (
            f"{day} from [{from_time} to {to_time}].\n"
            f"Location: {location}, {post_code}."
        )

        # Add this training info to the response list
        response_message.append(training_info)

    # Join all the training information into one response (if multiple training entries exist)
    return jsonify({"message": "\n\n".join(response_message)})


# Cloud Functions entry point
def general_chat(requesting):
    """
    Cloud Function entry point for general_chat.
    """
    try:
        request_json = requesting.get_json(silent=True)
        if not request_json:
            return jsonify({"error": "Invalid JSON payload"}), 400

        input_text = request_json.get('text')
        club_id = request_json.get('club_id')

        if not input_text or not club_id:
            return jsonify({"error": "Both 'text' and 'club_id' are required"}), 400

        # Fetch all player data
        players_data = get_players_data(club_id)
        about_club_data = get_about_club(club_id) or {}
        captains_data = get_captains_data(club_id)
        upcoming_matches_data = get_upcoming_matches(club_id)
        past_matches_data = get_past_matches(club_id)
        training_data = get_training_data(club_id)
        sponsors_data = get_club_sponsors(club_id)

        # Detect intent
        intent, entities = detect_intent(input_text)
        logging.info(f"Detected intent: {intent} with entities: {entities}")

        # Detect intent and requested field (if any)
        name, requested_field = detect_intent_and_field(input_text)
        # logging.info(f"Detected player: {name} and field: {requested_field}")

        if intent == "player_info":
            player_name = entities.get("player_name")
            logging.info(f"Processing player info request for: {player_name}")
            return handle_player_info_query(players_data, player_name)
        elif intent == "player_full_info":
            player_name = entities.get("player_name")
            logging.info(f"Processing player info request for: {player_name}")
            return handle_player_full_info_query(players_data, name, requested_field)
        elif intent == "upcoming_matches":
            return handle_upcoming_matches_query(upcoming_matches_data)
        elif intent == "past_matches":
            return handle_past_matches_query(past_matches_data)
        if intent == "training_days":
            return handle_training_days_query(training_data)
        elif intent == "club_info":
            return handle_club_info_query(about_club_data, input_text)
        elif intent == "top_performers":
            return handle_top_performers_query(players_data)
        elif intent == "captains_info":
            return handle_captains_query(captains_data)
        elif intent == "club_sponsors":
            return handle_club_sponsors_query(sponsors_data, input_text)
        if intent == "coaches_info":
            coach_name = extract_coach_name(input_text, get_coaches_data(club_id))
            return handle_coaches_query(get_coaches_data(club_id), coach_name)
        elif intent == "management_info":
            manager_name = extract_manager_name(input_text, get_management_data(club_id))
            return handle_management_query(get_management_data(club_id), manager_name)
        elif intent == "coach_comment":
            coach_name = entities.get('coach_name')
            if not coach_name:
                coach_name = extract_coach_name(input_text, get_coaches_data(club_id))
            return handle_coach_comment_query(coach_name, club_id)
        elif intent == "founder_comment":
            founder_name = entities.get('founder_name')
            if not founder_name:
                founder_name = extract_manager_name(input_text, get_management_data(club_id))
            return handle_founder_comment_query(founder_name, club_id)
        else:
            return handle_general_query(about_club_data, players_data, input_text)

    except Exception as e:
        logging.error(f"Error in general_chat: {e}", exc_info=True)
        traceback.print_exc()
        return jsonify({"error": "An internal error occurred"}), 500
