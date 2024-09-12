import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
from dotenv import load_dotenv
from google.cloud import firestore
from fuzzywuzzy import fuzz

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

# Memory for assist and goal data
assist_memory = {}
goal_memory = {}


def clean_input(input_text):
    confirmation_words = ['yes', 'no', 'yup', 'yeah', 'yep', 'nope']
    parts = input_text.split(',')
    for part in parts:
        part_cleaned = part.strip().lower()
        if part_cleaned not in confirmation_words:
            return part.strip()  # Return cleaned player name
    return input_text.strip()


@app.route('/parse', methods=['POST'])
def parse_message():
    data = request.json
    input_text = data.get('text')
    club_id = data.get('club_id')

    if not club_id:
        return jsonify({"error": "club_id is required"}), 400

    try:
        # Use OpenAI to extract goal and assist
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system",
                 "content": "You are a sports assistant specialized in parsing goal and assist information."},
                {"role": "user",
                 "content": f"Extract the goal scorer and assist provider from this text: '{input_text}'. Format the result as JSON with 'goal_scorer' and 'assist_provider' fields. If either is not mentioned, use null. Always distinguish between the goal scorer and assist provider."}
            ],
            max_tokens=150
        )

        parsed_data = json.loads(response.choices[0].message.content.strip())

        goal_scorer = parsed_data.get('goal_scorer')
        assist_provider = parsed_data.get('assist_provider')

        # Update Firestore and get result messages
        update_result = update_firestore(club_id, goal_scorer, assist_provider)

        # Check if there are any issues (multiple matches or no matches)
        if "Multiple players found" in update_result or "No player found" in update_result:
            return jsonify({"message": update_result})

        return jsonify({
                           "message": f"Goal by {goal_scorer}, assist by {assist_provider} recorded. {update_result}"})

    except json.JSONDecodeError:
        return jsonify({"error": "Failed to parse OpenAI response"}), 500
    except Exception as e:
        app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500


def update_firestore(club_id, goal_scorer, assist_provider):
    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    def find_matching_players(name):
        name = name.lower()
        name_parts = name.split()
        matching_players = []

        all_players = players_ref.get()
        for player in all_players:
            player_data = player.to_dict()
            player_name = player_data['player_name'].lower()

            # Check for exact match
            if name == player_name:
                return [player]

            # Check for partial matches
            if any(part in player_name for part in name_parts):
                matching_players.append(player)

            # Fuzzy matching
            if fuzz.partial_ratio(name, player_name) > 80:
                matching_players.append(player)

        return list({player.id: player for player in matching_players}.values())

    def update_player_stats(player_name, stat_type):
        matching_players = find_matching_players(player_name)

        if not matching_players:
            return f"No player found matching '{player_name}' in club {club_id}"

        if len(matching_players) > 1:
            player_names = [player.to_dict()['player_name'] for player in matching_players]
            return f"Multiple players found matching '{player_name}': {', '.join(player_names)}. Please specify."

        # Update the matching player's stats
        player_doc = matching_players[0]
        if stat_type == 'goal':
            players_ref.document(player_doc.id).update({'goals_scored': firestore.Increment(1)})
        elif stat_type == 'assist':
            players_ref.document(player_doc.id).update({'assists': firestore.Increment(1)})

        return f"Updated {stat_type} for {player_doc.to_dict()['player_name']}"

    result_messages = []

    if goal_scorer:
        result_messages.append(update_player_stats(goal_scorer, 'goal'))

    if assist_provider:
        result_messages.append(update_player_stats(assist_provider, 'assist'))

    # Clear memory after update
    goal_memory.pop(club_id, None)
    assist_memory.pop(club_id, None)

    return '. '.join(result_messages)


if __name__ == "__main__":
    app.run(debug=True)
