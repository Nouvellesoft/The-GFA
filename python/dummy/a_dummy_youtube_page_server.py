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


# Helper function: Fetch FutureMatches data
def get_future_matches(club_id):
    try:
        future_matches_ref = db.collection('clubs').document(club_id).collection('FutureMatches')
        future_matches_docs = future_matches_ref.stream()
        future_matches_data = [match_doc.to_dict() for match_doc in future_matches_docs]
        return future_matches_data
    except Exception as e:
        print(f"DEBUG: Error fetching FutureMatches data: {str(e)}")
        return []


# Helper function: Fetch PastMatches data
def get_past_matches(club_id):
    try:
        past_matches_ref = db.collection('clubs').document(club_id).collection('PastMatches')
        past_matches_docs = past_matches_ref.stream()
        past_matches_data = [match_doc.to_dict() for match_doc in past_matches_docs]
        return past_matches_data
    except Exception as e:
        print(f"DEBUG: Error fetching PastMatches data: {str(e)}")
        return []


# Helper function: Fetch AboutClub data
def get_about_club(club_id):
    try:
        about_club_ref = db.collection('clubs').document(club_id).collection('AboutClub').document(
            'about_club_page')
        about_club_data = about_club_ref.get().to_dict()
        return about_club_data
    except Exception as e:
        print(f"DEBUG: Error fetching AboutClub data: {str(e)}")
        return None


# Helper function: Fetch Players data (including PlayersTable and team collections)
def get_players_data(club_id):
    try:
        players_data = []

        # Fetch data from PlayersTable collection
        players_table_ref = db.collection('clubs').document(club_id).collection('PllayersTable')
        player_docs = players_table_ref.stream()
        players_data.extend([player_doc.to_dict() for player_doc in player_docs])

        # Fetch data from all the team player collections
        team_collections = [
            'FirstTeamClassPlayers',
            'SecondTeamClassPlayers',
            'ThirdTeamClassPlayers',
            'FourthTeamClassPlayers',
            'SixthTeamClassPlayers'
        ]

        for collection in team_collections:
            players_table_ref = db.collection('clubs').document(club_id).collection(collection)
            player_docs = players_table_ref.stream()
            players_data.extend([player_doc.to_dict() for player_doc in player_docs])

        return players_data
    except Exception as e:
        print(f"DEBUG: Error fetching Players data: {str(e)}")
        return []


# Helper function: Fetch Captains data
def get_captains_data(club_id):
    try:
        captains_ref = db.collection('clubs').document(club_id).collection('Captains')
        captain_docs = captains_ref.stream()
        captains_data = [captain_doc.to_dict() for captain_doc in captain_docs]
        return captains_data
    except Exception as e:
        print(f"DEBUG: Error fetching Captains data: {str(e)}")
        return []


# Helper function: Fetch ClubSponsors data
def get_club_sponsors_data(club_id):
    try:
        sponsors_ref = db.collection('clubs').document(club_id).collection('ClubSponsors')
        sponsor_docs = sponsors_ref.stream()
        sponsors_data = [sponsor_doc.to_dict() for sponsor_doc in sponsor_docs]
        return sponsors_data
    except Exception as e:
        print(f"DEBUG: Error fetching ClubSponsors data: {str(e)}")
        return []


# Helper function: Fetch Coaches data
def get_coaches_data(club_id):
    try:
        coaches_ref = db.collection('clubs').document(club_id).collection('Coaches')
        coach_docs = coaches_ref.stream()
        coaches_data = [coach_doc.to_dict() for coach_doc in coach_docs]
        return coaches_data
    except Exception as e:
        print(f"DEBUG: Error fetching Coaches data: {str(e)}")
        return []


# Helper function: Fetch the latest comment from the founder
def get_latest_founder_comment(club_id):
    try:
        founders_ref = db.collection('clubs').document(club_id).collection(
            'FoundersMonthlyComments')
        founder_comments = founders_ref.order_by("date",
                                                 direction=firestore.Query.DESCENDING).limit(
            1).stream()
        for comment in founder_comments:
            return comment.to_dict()
        return None
    except Exception as e:
        print(f"DEBUG: Error fetching founder comment: {str(e)}")
        return None


# Helper function: Fetch the latest comment from the coach
def get_latest_coach_comment(club_id):
    try:
        coaches_ref = db.collection('clubs').document(club_id).collection('CoachesMonthlyComments')
        coach_comments = coaches_ref.order_by("date", direction=firestore.Query.DESCENDING).limit(
            1).stream()
        for comment in coach_comments:
            return comment.to_dict()
        return None
    except Exception as e:
        print(f"DEBUG: Error fetching coach comment: {str(e)}")
        return None


# Helper function: Match and retrieve player data
def get_player_info(players_data, player_name):
    best_match = process.extractOne(player_name, [p.get("player_name", "") for p in players_data],
                                    score_cutoff=70)
    return next((p for p in players_data if p.get("player_name") == best_match[0]),
                None) if best_match else None


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

        # Fetch AboutClub and Players data (including PlayersTable and new team collections)
        about_club_data = get_about_club(club_id)
        players_data = get_players_data(club_id)
        captains_data = get_captains_data(club_id)
        sponsors_data = get_club_sponsors_data(club_id)
        coaches_data = get_coaches_data(club_id)
        future_matches_data = get_future_matches(club_id)
        past_matches_data = get_past_matches(club_id)

        if not about_club_data:
            about_club_data = {}

        # Handle founder's comment query
        if "founder" in input_text.lower() and "comment" in input_text.lower():
            latest_comment = get_latest_founder_comment(club_id)
            if latest_comment:
                return jsonify({
                    "message": f"Founder {latest_comment['name']}'s comment for {latest_comment['date']} was: {latest_comment['comment']}"
                })
            return jsonify({"message": "Could not find any comment from the founder."})

        # Handle coach's comment query
        if "coach" in input_text.lower() and "comment" in input_text.lower():
            latest_comment = get_latest_coach_comment(club_id)
            if latest_comment:
                return jsonify({
                    "message": f"Coach {latest_comment['name']}'s comment for {latest_comment['date']} was: {latest_comment['comment']}"
                })
            return jsonify({"message": "Could not find any comment from the coach."})

        # Handle FutureMatches and PastMatches
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

        # Combine club info and top performers for OpenAI context
        combined_context = {
            "club_info": about_club_data,
            "top_performers": sorted(players_data, key=lambda x: x.get('goals_scored', 0),
                                     reverse=True)[:3],
            "captains_info": captains_data,
            "sponsors_info": sponsors_data,
            "coaches_info": coaches_data
        }

        # Call OpenAI's chat completions API with context
        openai_response = client.completions.create(
            model="gpt-4",
            prompt=f"Answer the following question based on the given club information: {input_text}.\n\nClub info:\n{combined_context}",
            max_tokens=150
        )
        return jsonify({"response": openai_response['choices'][0]['message']['content']})

    except Exception as e:
        print(f"DEBUG: Error during chat processing: {str(e)}")
        traceback.print_exc()
        return jsonify({"error": "An error occurred while processing your request."}), 500


if __name__ == '__main__':
    app.run(debug=True)
