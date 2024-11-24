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


# Helper function: Fetch AboutClub data
def get_about_club(club_id):
    try:
        about_club_ref = db.collection('clubs').document(club_id).collection('AboutClub').document('about_club_page')
        about_club_data = about_club_ref.get().to_dict()
        return about_club_data
    except Exception as e:
        print(f"DEBUG: Error fetching AboutClub data: {str(e)}")
        return None


# Helper function: Fetch PllayersTable data
def get_players_data(club_id):
    try:
        players_table_ref = db.collection('clubs').document(club_id).collection('PllayersTable')
        player_docs = players_table_ref.stream()
        players_data = [player_doc.to_dict() for player_doc in player_docs]
        return players_data
    except Exception as e:
        print(f"DEBUG: Error fetching PllayersTable data: {str(e)}")
        return []


# Helper function: Match and retrieve player data
def get_player_info(players_data, player_name):
    best_match = process.extractOne(player_name, [p.get("player_name", "") for p in players_data], score_cutoff=70)
    return next((p for p in players_data if p.get("player_name") == best_match[0]), None) if best_match else None


# Flask endpoint for handling chat requests
@app.route('/general_chat', methods=['POST'])
def general_chat():
    try:
        # Parse request data
        data = request.json
        input_text = data.get('text')
        club_id = data.get('club_id')

        if not input_text or not club_id:
            return jsonify({"error": "Both 'text' and 'club_id' are required"}), 400

        # Fetch AboutClub and PllayersTable data
        about_club_data = get_about_club(club_id)
        players_data = get_players_data(club_id)

        if not about_club_data:
            about_club_data = {}

        # Determine intent: Check for player-specific or club-specific query
        doc = nlp(input_text)
        player_candidates = [ent.text.strip() for ent in doc.ents if ent.label_ == "PERSON"]
        target_player = player_candidates[0] if player_candidates else None

        # Handle club-specific queries directly
        if "founded" in input_text.lower():
            founding_date = about_club_data.get("founding_date", "Unknown")
            founders = about_club_data.get("founders", "Unknown")
            return jsonify({"message": f"The club was founded on {founding_date} by {founders}."})

        if "mission" in input_text.lower():
            mission_statement = about_club_data.get("mission_statement", "Mission statement not available.")
            return jsonify({"message": f"The club's mission is: {mission_statement}"})

        if "core values" in input_text.lower():
            core_values = about_club_data.get("core_values", "No core values listed.")
            return jsonify({"message": f"The club's core values are: {core_values}"})

        if "instagram" in input_text.lower():
            instagram = about_club_data.get("instagram_handle", "not available")
            return jsonify({"message": f"The club's Instagram handle is {instagram}."})

        if "facebook" in input_text.lower():
            facebook = about_club_data.get("facebook_handle", "not available")
            return jsonify({"message": f"The club's Facebook page is {facebook}."})

        # Player-specific query
        if target_player:
            best_player = get_player_info(players_data, target_player)
            if best_player:
                # Prepare player-specific data for response
                player_name = best_player.get("player_name", "Unknown Player")
                goals = best_player.get("goals_scored", 0)
                assists = best_player.get("assists", 0)
                age = best_player.get("age", "unknown")
                response_text = (
                    f"{player_name} has scored {goals} goal(s) and provided {assists} assist(s). "
                    f"They are {age} years old."
                )
                return jsonify({"message": response_text})

            return jsonify({"message": f"Could not find detailed information for {target_player}."})

        # Handle player performance queries like goals, assists, etc.
        if "goals" in input_text.lower():
            player_name = target_player or "Player"
            best_player = get_player_info(players_data, player_name)
            if best_player:
                goals = best_player.get("goals_scored", 0)
                return jsonify({"message": f"{player_name} has scored {goals} goals."})
            return jsonify({"message": f"Could not find information about goals for {player_name}."})

        if "age" in input_text.lower():
            player_name = target_player or "Player"
            best_player = get_player_info(players_data, player_name)
            if best_player:
                age = best_player.get("age", "Unknown")
                return jsonify({"message": f"{player_name} is {age} years old."})
            return jsonify({"message": f"Could not find information about {player_name}'s age."})

        # Combine club info and top performers for OpenAI context
        combined_context = {
            "club_info": about_club_data,
            "top_performers": sorted(players_data, key=lambda x: x.get('goals_scored', 0), reverse=True)[:3]
        }

        # Use OpenAI to generate a response based on retrieved club datacde4
        openai_response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an assistant for a football club."},
                {"role": "user", "content": input_text},
                {"role": "system", "content": f"Here is some context about the club:\n{combined_context}"}
            ],
            max_tokens=200,
            temperature=0.7
        )
        return jsonify({"message": openai_response.choices[0].message.content.strip()})

    except Exception as e:
        print(f"DEBUG: Exception occurred: {str(e)}")
        print(f"DEBUG: Exception traceback: {traceback.format_exc()}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
