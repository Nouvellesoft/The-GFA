import traceback

from fuzzywuzzy import process
import spacy
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_cors import CORS
from google.cloud import firestore
from openai import OpenAI

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize OpenAI client
client = OpenAI(api_key='sk-GFTuZzkvMOyU6oJCvDAl5b-V4wx_gJP7nlPJGJZTIyT3BlbkFJCb3wPfhUjA'
                        'jkwzuW2s4H6iIBsydv41ouQvVLNKynAA')

# Initialize Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'
db = firestore.Client(project=FIRESTORE_PROJECT_ID)

# Load the spaCy model
nlp = spacy.load("en_core_web_sm")

# Define possible fields for fuzzy matching
POTENTIAL_FIELDS = [
    "goals_scored", "assists", "matches_played", "player_value",
    "age", "player_name", "preferred_foot", "clean_sheets_gk",
    "matches_started", "matches_benched", "red_card", "yellow_card"
]


# Helper function to find the closest matching field
def find_closest_field(query_field, available_fields):
    closest_match = process.extractOne(query_field, available_fields)
    return closest_match[0] if closest_match and closest_match[1] > 60 else None


# Function to search Firestore for player information
def search_firestore_for_answer(club_id, query):
    try:
        print(f"DEBUG: Starting search with query: '{query}'")
        print(f"DEBUG: Club ID: {club_id}")

        # Analyze query to extract player name using spaCy
        doc = nlp(query)
        target_player = None

        # Extract PERSON entities or fallback to capitalized words as player name
        player_candidates = [ent.text.strip().title() for ent in doc.ents if ent.label_ == "PERSON"]
        target_player = player_candidates[0] if player_candidates else " ".join(
            [token.text for token in doc if token.text[0].isupper()]
        ).title()

        if not target_player or len(target_player.split()) < 2:
            return "Could not identify a player name in the query."

        print(f"DEBUG: Detected player name: {target_player}")

        # Reference to club's player collection
        players_table_ref = db.collection('clubs').document(club_id).collection('PllayersTable')
        player_docs = players_table_ref.stream()

        # Variables to track the best matching player
        best_match_data = None
        highest_confidence = 0

        # Iterate through all player documents for case-insensitive matching
        for player_doc in player_docs:
            player_data = player_doc.to_dict()
            player_name = player_data.get('player_name', '').strip().title()

            # Perform fuzzy matching for case-insensitive search
            match, confidence = process.extractOne(target_player.lower(), [player_name.lower()])
            print(
                f"DEBUG: Comparing '{target_player}' with '{player_name}' - Confidence: {confidence}")

            if confidence > 60 and confidence > highest_confidence:
                best_match_data = player_data
                highest_confidence = confidence
                print(f"DEBUG: Best match found: {player_name} with confidence {confidence}")

        # Check if a matching player was found
        if best_match_data:
            goals_scored = best_match_data.get("goals_scored", 0)
            player_name = best_match_data.get("player_name", "N/A")
            return f"{player_name} has scored {goals_scored} goal(s)."
        else:
            return "No matching information found for the specified player."

    except Exception as e:
        print(f"DEBUG: Exception occurred: {str(e)}")
        print(f"DEBUG: Exception traceback: {traceback.format_exc()}")
        return f"Error retrieving data: {str(e)}"


# Flask endpoint for handling chat requests
@app.route('/general_chat', methods=['POST'])
def general_chat():
    try:
        data = request.json
        input_text = data.get('text')
        club_id = data.get('club_id')

        if not input_text or not club_id:
            return jsonify({"error": "Both 'text' and 'club_id' are required"}), 400

        # Retrieve player information from Firestore
        firestore_answer = search_firestore_for_answer(club_id, input_text)

        if firestore_answer:
            return jsonify({"message": firestore_answer})

        # Fallback to OpenAI for a response if no match found
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant for a football club."},
                {"role": "user", "content": input_text}
            ],
            max_tokens=150
        )

        fallback_response = response.choices[0].message.content.strip()
        return jsonify({"message": fallback_response})

    except Exception as e:
        print(f"DEBUG: Endpoint exception: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
