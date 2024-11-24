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


# Helper function: Fetch data from any collection or document
def fetch_collection_data(collection_ref):
    try:
        docs = collection_ref.stream()
        return [doc.to_dict() for doc in docs]
    except Exception as e:
        print(f"DEBUG: Error fetching data from collection: {str(e)}")
        return []


def fetch_document_data(document_ref):
    try:
        return document_ref.get().to_dict()
    except Exception as e:
        print(f"DEBUG: Error fetching data from document: {str(e)}")
        return None


# Fetch data for specific subcollections
def get_all_subcollection_data(club_id):
    subcollections = {
        "AboutClub": fetch_document_data(
            db.collection('clubs').document(club_id).collection('AboutClub').document('about_club_page')
        ),
        "PlayersTable": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('PllayersTable')
        ),
        "TeamPlayers": {
            team: fetch_collection_data(
                db.collection('clubs').document(club_id).collection(team)
            )
            for team in [
                "FirstTeamClassPlayers", "SecondTeamClassPlayers",
                "ThirdTeamClassPlayers", "FourthTeamClassPlayers",
                "SixthTeamClassPlayers"
            ]
        },
        "Captains": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('Captains')
        ),
        "ClubSponsors": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('ClubSponsors')
        ),
        "Coaches": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('Coaches')
        ),
        "FutureMatches": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('FutureMatches')
        ),
        "PastMatches": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('PastMatches')
        ),
        "FoundersComments": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('FoundersMonthlyComments')
        ),
        "CoachesComments": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('CoachesMonthlyComments')
        ),
    }
    return subcollections


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

        # Fetch all subcollection data
        club_data = get_all_subcollection_data(club_id)
        about_club_data = club_data.get("AboutClub", {})
        players_data = club_data.get("PlayersTable", []) + [
            player for team in club_data.get("TeamPlayers", {}).values() for player in team
        ]
        future_matches_data = club_data.get("FutureMatches", [])
        past_matches_data = club_data.get("PastMatches", [])
        captains_data = club_data.get("Captains", [])
        sponsors_data = club_data.get("ClubSponsors", [])
        coaches_data = club_data.get("Coaches", [])
        founder_comments = club_data.get("FoundersComments", [])
        coach_comments = club_data.get("CoachesComments", [])

        # NLP analysis to detect player queries
        doc = nlp(input_text)
        player_candidates = [ent.text.strip() for ent in doc.ents if ent.label_ == "PERSON"]
        target_player = player_candidates[0] if player_candidates else None

        # Handle various club-specific queries
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
            instagram = about_club_data.get("instagram_handle", "Not available")
            return jsonify({"message": f"The club's Instagram handle is {instagram}."})

        if "facebook" in input_text.lower():
            facebook = about_club_data.get("facebook_handle", "Not available")
            return jsonify({"message": f"The club's Facebook page is {facebook}."})

        # Handle player-specific queries
        if target_player:
            best_player = get_player_info(players_data, target_player)
            if best_player:
                goals = best_player.get("goals_scored", 0)
                assists = best_player.get("assists", 0)
                age = best_player.get("age", "unknown")
                return jsonify({"message": f"{target_player} has {goals} goal(s), {assists} assist(s), and is {age} years old."})

        # Match-related queries
        if "next match" in input_text.lower():
            next_match = future_matches_data[0] if future_matches_data else None
            if next_match:
                return jsonify({
                    "message": f"The next match is {next_match['home_team']} vs {next_match['away_team']} on {next_match['match_date']}."
                })
            return jsonify({"message": "No upcoming matches found."})

        if "last match" in input_text.lower():
            last_match = past_matches_data[0] if past_matches_data else None
            if last_match:
                return jsonify({
                    "message": f"The last match was {last_match['home_team']} vs {last_match['away_team']} on {last_match['match_date']} with a score of {last_match['ht_score']}-{last_match['at_score']}."
                })
            return jsonify({"message": "No past match information available."})

        # General response using OpenAI
        openai_response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are an assistant for a football club."},
                {"role": "user", "content": input_text},
                {"role": "system", "content": f"Here is some context about the club:\n{club_data}"}
            ],
            max_tokens=200,
            temperature=0.7
        )
        return jsonify({"message": openai_response.choices[0].message.content.strip()})

    except Exception as e:
        print(f"DEBUG: Error during chat processing: {str(e)}")
        traceback.print_exc()
        return jsonify({"error": "An error occurred while processing your request."}), 500


if __name__ == "__main__":
    app.run(debug=True)
