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


# Helper function: Extract player name
def extract_player_name(input_text):
    # First try spaCy NER
    doc = nlp(input_text)
    player_candidates = [ent.text.strip() for ent in doc.ents if ent.label_ == "PERSON"]
    logging.info(f"spaCy detected entities: {player_candidates}")

    if player_candidates:
        # Log the selected name
        logging.info(f"Using spaCy detected name: {player_candidates[0]}")
        return player_candidates[0]

    # Enhanced fallback: Look for name patterns
    words = input_text.split()
    potential_names = []

    # Look for consecutive capitalized words
    for i in range(len(words) - 1):
        if words[i][0].isupper() and words[i + 1][0].isupper():
            name = f"{words[i]} {words[i + 1]}"
            potential_names.append(name)

    # Look for "stats for [Name]" pattern
    if "stats for" in input_text.lower():
        stats_index = input_text.lower().index("stats for") + 9
        remaining_text = input_text[stats_index:].strip()
        words = remaining_text.split()
        if len(words) >= 2:
            potential_names.append(f"{words[0]} {words[1]}")

    logging.info(f"Potential names found: {potential_names}")

    return potential_names[0] if potential_names else None


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


# Intent detection - Updated version
def detect_intent(input_text):
    input_text_lower = input_text.lower()

    # Check for player of the month query first
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

    # Check for any player-related query
    if any(keyword in input_text_lower for keyword in
           ["goals", "age", "position", "player", "name"]):
        return "player_info", {"player_name": extract_player_name(input_text)}

    return "general_query", {}


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
            "message": f"The club's social media handles are:\nFacebook: {facebook}\nInstagram: {instagram}\nTwitter: {twitter}"})

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
                    f"{player.get('player_name', 'Unknown')} is the player of the month, some of his current stats includes: \n\n"
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

        logging.info(f"Retrieved {len(players_data)} players from database")

        # Detect intent
        intent, entities = detect_intent(input_text)
        logging.info(f"Detected intent: {intent} with entities: {entities}")

        if intent == "player_info":
            player_name = entities.get("player_name")
            logging.info(f"Processing player info request for: {player_name}")
            return handle_player_info_query(players_data, player_name)
        elif intent == "club_info":
            return handle_club_info_query(about_club_data, input_text)
        elif intent == "top_performers":
            return handle_top_performers_query(players_data)
        else:
            return handle_general_query(about_club_data, players_data, input_text)

    except Exception as e:
        logging.error(f"Error in general_chat: {e}", exc_info=True)
        traceback.print_exc()
        return jsonify({"error": "An internal error occurred"}), 500


if __name__ == "__main__":
    app.run(debug=True)
