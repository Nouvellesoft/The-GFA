import traceback
from fuzzywuzzy import process
import spacy
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_cors import CORS
from google.cloud import firestore
from openai import OpenAI
from typing import List, Dict, Any
from collections import defaultdict

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


def get_all_subcollection_data(club_id):
    subcollections = {
        "AboutClub": fetch_document_data(
            db.collection('clubs').document(club_id).collection('AboutClub').document(
                'about_club_page')
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
                "FifthTeamClassPlayers", "SixthTeamClassPlayers"
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
        "ClubPopulation": fetch_document_data(
            db.collection('clubs').document(club_id).collection('ClubPopulation').document(
                'population')
        ),
        "TrainingDays": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('TrainingDays')
        ),
        "Achievements": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('AchievementImages')
        ),
        "ManagementBody": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('ManagementBody')
        ),
        "TrialDates": fetch_collection_data(
            db.collection('clubs').document(club_id).collection('TrialDates')
        )
    }
    return subcollections


def get_player_stats(players_data: List[Dict[str, Any]], player_name: str) -> Dict[str, Any]:
    """Get comprehensive player statistics."""
    best_match = process.extractOne(player_name, [p.get("player_name", "") for p in players_data],
                                    score_cutoff=70)
    if not best_match:
        return None

    player = next((p for p in players_data if p.get("player_name") == best_match[0]), None)
    if player:
        return {
            "name": player.get("player_name"),
            "position": player.get("player_position"),
            "age": player.get("age"),
            "nationality": player.get("nationality"),
            "matches_played": player.get("matches_played", 0),
            "matches_started": player.get("matches_started", 0),
            "matches_benched": player.get("matches_benched", 0),
            "goals": player.get("goals_scored", 0),
            "assists": player.get("assists", 0),
            "clean_sheets": player.get("clean_sheets_gk", 0),
            "goals_conceded": player.get("goals_conceded_gk_def", 0),
            "yellow_cards": player.get("yellow_card", 0),
            "red_cards": player.get("red_card", 0),
            "motm": player.get("man_of_the_match_cum", 0),
            "potm": player.get("potm_cum", 0),
            "value": player.get("player_value", 0)
        }
    return None


def get_team_stats(players_data: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Calculate team-wide statistics."""
    stats = {
        "total_players": len(players_data),
        "total_goals": sum(p.get("goals_scored", 0) for p in players_data),
        "total_assists": sum(p.get("assists", 0) for p in players_data),
        "total_clean_sheets": sum(p.get("clean_sheets_gk", 0) for p in players_data),
        "positions": defaultdict(int),
        "nationalities": defaultdict(int),
        "avg_age": sum(p.get("age", 0) for p in players_data) / len(
            players_data) if players_data else 0
    }

    for player in players_data:
        stats["positions"][player.get("player_position", "Unknown")] += 1
        stats["nationalities"][player.get("nationality", "Unknown")] += 1

    return stats


@app.route('/general_chat', methods=['POST'])
def general_chat():
    try:
        data = request.json
        input_text = data.get('text', '').lower()
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

        # Original queries (keeping existing functionality)
        if "founded" in input_text:
            founding_date = about_club_data.get("founding_date", "Unknown")
            founders = about_club_data.get("founders", "Unknown")
            return jsonify({"message": f"The club was founded on {founding_date} by {founders}."})

        if "mission" in input_text:
            mission_statement = about_club_data.get("mission_statement",
                                                    "Mission statement not available.")
            return jsonify({"message": f"The club's mission is: {mission_statement}"})

        if "core values" in input_text:
            core_values = about_club_data.get("core_values", "No core values listed.")
            return jsonify({"message": f"The club's core values are: {core_values}"})

        if "instagram" in input_text:
            instagram = about_club_data.get("instagram_handle", "Not available")
            return jsonify({"message": f"The club's Instagram handle is {instagram}."})

        if "facebook" in input_text:
            facebook = about_club_data.get("facebook_handle", "Not available")
            return jsonify({"message": f"The club's Facebook page is {facebook}."})

        # Enhanced player queries
        if target_player:
            player_stats = get_player_stats(players_data, target_player)
            if player_stats:
                if "goals" in input_text:
                    return jsonify({
                        "message": f"{player_stats['name']} has scored {player_stats['goals']} goals in {player_stats['matches_played']} matches."})
                elif "assists" in input_text:
                    return jsonify({
                        "message": f"{player_stats['name']} has {player_stats['assists']} assists this season."})
                elif "clean sheets" in input_text:
                    return jsonify({
                        "message": f"{player_stats['name']} has kept {player_stats['clean_sheets']} clean sheets."})
                elif "cards" in input_text:
                    return jsonify({
                        "message": f"{player_stats['name']} has received {player_stats['yellow_cards']} yellow cards and {player_stats['red_cards']} red cards."})
                else:
                    return jsonify({
                        "message": f"Stats for {player_stats['name']}:\n"
                                   f"Position: {player_stats['position']}\n"
                                   f"Age: {player_stats['age']}\n"
                                   f"Matches: {player_stats['matches_played']}\n"
                                   f"Goals: {player_stats['goals']}\n"
                                   f"Assists: {player_stats['assists']}"
                    })

        # Extract only relevant data for context
        if "goals" in input_text and target_player:
            relevant_data = {"players": [{"name": target_player, "goals": player_stats['goals']}]}
        else:
            relevant_data = {"basic_info": about_club_data}

        # Match-related queries (keeping existing functionality)
        if "next match" in input_text:
            next_match = future_matches_data[0] if future_matches_data else None
            if next_match:
                return jsonify({
                    "message": f"The next match is {next_match['home_team']} vs {next_match['away_team']} on {next_match['match_date']}."
                })
            return jsonify({"message": "No upcoming matches found."})

        if "last match" in input_text:
            last_match = past_matches_data[0] if past_matches_data else None
            if last_match:
                return jsonify({
                    "message": f"The last match was {last_match['home_team']} vs {last_match['away_team']} on {last_match['match_date']} with a score of {last_match['ht_score']}-{last_match['at_score']}."
                })
            return jsonify({"message": "No past match information available."})

        # New team statistics queries
        if "squad size" in input_text or "how many players" in input_text:
            team_stats = get_team_stats(players_data)
            return jsonify(
                {"message": f"The squad currently has {team_stats['total_players']} players."})

        if "team goals" in input_text:
            team_stats = get_team_stats(players_data)
            return jsonify(
                {"message": f"The team has scored {team_stats['total_goals']} goals this season."})

        if "average age" in input_text:
            team_stats = get_team_stats(players_data)
            return jsonify(
                {"message": f"The average age of the squad is {team_stats['avg_age']:.1f} years."})

        # New training and trials queries
        if "training days" in input_text or "when is training" in input_text:
            training_days = club_data.get("TrainingDays", [])
            if training_days:
                training_info = ", ".join(
                    [f"{day.get('day')} at {day.get('time')}" for day in training_days])
                return jsonify({"message": f"Training sessions are held on: {training_info}"})

        if "trial" in input_text or "tryout" in input_text:
            trial_dates = club_data.get("TrialDates", [])
            if trial_dates:
                next_trial = trial_dates[0]
                return jsonify({
                    "message": f"Next trial date: {next_trial.get('date')} at {next_trial.get('time')}"
                })

        # Management queries
        if "management" in input_text or "staff" in input_text:
            management = club_data.get("ManagementBody", [])
            if management:
                staff_list = "\n".join([f"- {person.get('name')}: {person.get('role')}"
                                        for person in management])
                return jsonify({"message": f"Management staff:\n{staff_list}"})

        # Fallback to OpenAI
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
