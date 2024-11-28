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

    # Check for captain queries
    if "captain" in input_text_lower:
        return "captains_info", {}

    # Check for sponsorship queries
    if "sponsor" in input_text_lower or "sponsorship" in input_text_lower:
        return "club_sponsors", {}

    # Check for coach queries
    if "coach" in input_text_lower or "coaches" in input_text_lower:
        return "coaches_info", {}

    # **Management Queries**
    if any(keyword in input_text_lower for keyword in
           ["who founded", "founder", "management", "manager", "managers"]):
        return "management_info", {}

    # Catch-all player-related queries (to avoid conflicts with management queries)
    if any(keyword in input_text_lower for keyword in ["goals", "age", "position", "player"]):
        return "player_info", {"player_name": extract_player_name(input_text)}

    return "general_query", {}


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
                f"{coach_info.get('name', 'Unknown Coach')} serves as {coach_info.get('staff_position', 'a coach')}. "
                f"They believe in '{coach_info.get('philosophy', 'N/A')}'.\n"
                f"Contact: {coach_info.get('email', 'N/A')} | {coach_info.get('phone', 'N/A')}."
            )
            return jsonify({"message": response})
        return jsonify({"message": f"No coach found with the name {coach_name}."})

    # If no specific name, list all coaches
    response = "The coaches at the club are:\n"
    for coach in coaches_data:
        response += f"- {coach.get('name', 'Unknown Coach')} ({coach.get('staff_position', 'N/A')})\n"

    return jsonify({"message": response})


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

        about_club_data = get_about_club(club_id) or {}

        # Detect intent
        intent, entities = detect_intent(input_text)
        logging.info(f"Detected intent: {intent} with entities: {entities}")

        if intent == "coaches_info":
            coach_name = extract_coach_name(input_text, get_coaches_data(club_id))
            return handle_coaches_query(get_coaches_data(club_id), coach_name)

        else:
            return handle_general_query(about_club_data, players_data, input_text)

    except Exception as e:
        logging.error(f"Error in general_chat: {e}", exc_info=True)
        traceback.print_exc()
        return jsonify({"error": "An internal error occurred"}), 500


if __name__ == "__main__":
    app.run(debug=True)
