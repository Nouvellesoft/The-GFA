import traceback
from fuzzywuzzy import process
import spacy
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
from google.cloud import firestore
from openai import OpenAI
from dotenv import load_dotenv
from flask_caching import Cache
from datetime import datetime

# Load environment variables
load_dotenv()

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
client = OpenAI(api_key='sk-GFTuZzkvMOyU6oJCvDAl5b-V4wx_gJP7nlPJGJZTIyT3BlbkFJCb3wPfhUjA'
                        'jkwzuW2s4H6iIBsydv41ouQvVLNKynAA')

# Initialize Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'
db = firestore.Client(project=FIRESTORE_PROJECT_ID)

# Load spaCy model
nlp = spacy.load("en_core_web_sm")


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

            # Extract and validate match details
            home_team = match_data.get("home_team", "Unknown")
            away_team = match_data.get("away_team", "Unknown")
            venue = match_data.get("venue", "Unknown")
            competition = match_data.get("competition", "Unknown")
            match_date_ko = match_data.get("match_date_ko", "Date not available")  # Original date string

            try:
                # Convert match_date_ko string to datetime object for comparison
                match_date = datetime.strptime(match_date_ko, "%d-%m-%Y %H:%M:%S")  # Adjust the format if necessary
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
                    "match_date_ko": match_date_ko,  # Keep the original date format for user display
                    "match_date": match_date  # Store the datetime object for sorting
                })

        # Sort matches by 'match_date' (ascending)
        upcoming_matches.sort(key=lambda x: x["match_date"])

        # Limit the response to the next 5 matches
        limited_matches = upcoming_matches[:5]
        logging.info(f"Returning {len(limited_matches)} upcoming matches: {limited_matches}")

        return limited_matches
    except Exception as e:
        logging.error(f"Unexpected error fetching matches for club_id {club_id}: {e}")
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
    if "where" in input_text_lower and "play" in input_text_lower and "position" not in input_text_lower:
        return "player_position", {"player_name": extract_player_name(input_text)}

    # Check for captain queries
    if "captain" in input_text_lower:
        return "captains_info", {}

    # Check for sponsorship queries
    if "sponsor" in input_text_lower or "sponsorship" in input_text_lower:
        return "club_sponsors", {}

    if "upcoming matches" in input_text_lower or "next matches" in input_text_lower or "fixture" in input_text_lower:
        return "upcoming_matches", {}

    # Management Queries
    if any(keyword in input_text_lower for keyword in
           ["who founded", "founder", "management", "manager", "managers"]):
        return "management_info", {}

    # Catch-all player-related queries
    if any(keyword in input_text_lower for keyword in ["goals", "age", "position", "player"]):
        return "player_info", {"player_name": extract_player_name(input_text)}

    return "general_query", {}


def handle_upcoming_matches_query(upcoming_matches_data):
    if not upcoming_matches_data:
        return jsonify({"message": "No upcoming matches found for this club."}), 404

    # Current date for comparison
    current_date = datetime.now()

    # List to store match details
    matches_response = []

    # Iterate over the matches
    for idx, match in enumerate(upcoming_matches_data, start=1):
        # Fetch match details
        home_team = match.get("home_team", "Unknown")
        away_team = match.get("away_team", "Unknown")
        match_date_ko = match.get("match_date", "Date not available")  # Original date string
        venue = match.get("venue", "")
        competition = match.get("competition", "")

        try:
            # Convert match_date string to datetime object for comparison
            match_date = datetime.strptime(match_date_ko, "%d-%m-%Y %H:%M:%S")  # Adjust the format
        except ValueError:
            # If the date is not in the expected format, skip this match
            continue

        # If the match is in the future, add it to the response
        if match_date > current_date:
            match_info = f"Match {idx}: {home_team} vs {away_team} - {match_date_ko}"
            if venue:
                match_info += f" at {venue}"
            if competition:
                match_info += f" ({competition})"

            # Add match details including parsed date for sorting
            matches_response.append({
                "match_info": match_info,
                "match_date": match_date  # For sorting, we store datetime
            })

    # Sort the matches by date (ascending)
    matches_response.sort(key=lambda x: x["match_date"])

    # Limit the response to the next 5 matches
    limited_matches = matches_response[:5]

    # Construct the final response, including match_date_ko for the user
    final_response = [match["match_info"] for match in limited_matches]

    # Join the matches into a single string with line breaks
    return jsonify({"message": "\n\n".join(final_response)})


# Flask endpoint for handling chat requests
@app.route('/general_chat', methods=['POST'])
def general_chat():
    try:
        data = request.json
        input_text = data.get('text')
        club_id = data.get('club_id')

        if not input_text or not club_id:
            return jsonify({"error": "Both 'text' and 'club_id' are required"}), 400

        # Fetch all player data
        players_data = get_players_data(club_id)
        about_club_data = get_about_club(club_id) or {}
        captains_data = get_captains_data(club_id)
        upcoming_matches_data = get_upcoming_matches(club_id)
        sponsors_data = get_club_sponsors(club_id)

        # Detect intent
        intent, entities = detect_intent(input_text)
        logging.info(f"Detected intent: {intent} with entities: {entities}")

        # Detect intent and requested field (if any)
        name, requested_field = detect_intent_and_field(input_text)
        logging.info(f"Detected player: {name} and field: {requested_field}")

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


if __name__ == "__main__":
    app.run(debug=True)
