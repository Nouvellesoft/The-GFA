import json
from flask import Flask, jsonify
from flask_cors import CORS
from openai import OpenAI
from dotenv import load_dotenv
from google.cloud import firestore
from fuzzywuzzy import fuzz
from datetime import datetime, timedelta

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

# Global variables to store recent goals, assists, and partial information
pending_info = {}
recent_goals = {}


def parse_message(request):
    """
    Main entry point for Google Cloud Functions.
    This function handles incoming HTTP requests.
    """
    if request.method != 'POST':
        return jsonify({"error": "Invalid request method. Only POST is allowed."}), 405

    try:
        data = request.get_json()
        input_text = data.get('text')
        club_id = data.get('club_id')

        if not club_id:
            return jsonify({"error": "club_id is required"}), 400

        # Check if the input is a greeting
        if is_greeting(input_text):
            return handle_greeting(input_text)

        # Check if this is a correction to a recent goal
        if is_correction(input_text):
            return handle_correction(club_id, input_text)

        # Check if this is a single name response
        if is_single_name(input_text):
            return handle_single_name_response(club_id, input_text)

        # Use OpenAI to extract goal and assist information
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system",
                 "content": "You are a sports assistant specialized in parsing goal "
                            "and assist information."},
                {"role": "user",
                 "content": f"Extract the goal scorer and assist provider from this text: "
                            f"'{input_text}'. Format the result as JSON with 'goal_scorer' and "
                            f"'assist_provider' fields. If either is not mentioned, use null. "
                            f"Always distinguish between the goal scorer and assist provider."}
            ],
            max_tokens=150
        )

        parsed_data = json.loads(response.choices[0].message.content.strip())

        goal_scorer = parsed_data.get('goal_scorer')
        assist_provider = parsed_data.get('assist_provider')

        return process_goal_info(club_id, goal_scorer, assist_provider, input_text)

    except json.JSONDecodeError:
        return jsonify({"error": "Failed to parse OpenAI response"}), 500
    except Exception as e:
        # app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500


def is_greeting(input_text):
    greetings = ['hello', 'hi', 'hey', 'greetings', 'good morning', 'good afternoon',
                 'good evening']
    return input_text.lower().strip() in greetings


def is_single_name(input_text):
    # Check if the input is a single word (name) without any additional context
    return len(input_text.split()) == 1


def handle_single_name_response(club_id, name):
    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    # Check if the name exists in the database
    matching_players = find_matching_players(players_ref, name)

    if not matching_players:
        return jsonify(
            {"message": f"No player found matching '{name}'. Please provide more information."})

    if len(matching_players) > 1:
        player_names = [player.to_dict()['player_name'] for player in matching_players]
        return jsonify({
            "message": f"Multiple players found matching '{name}': "
                       f"{', '.join(player_names)}. Please specify."})

    # If we have a pending goal or assist, update accordingly
    if club_id in pending_info:
        if 'goal_scorer' in pending_info[club_id]:
            return process_goal_info(club_id, pending_info[club_id]['goal_scorer'], name,
                                     f"{name} assisted")
        elif 'assist_provider' in pending_info[club_id]:
            return process_goal_info(club_id, name, pending_info[club_id]['assist_provider'],
                                     f"Goal by {name}")

    # If no pending info, ask for more context
    return jsonify({"message": f"Player {name} noted. Did they score a goal or provide an assist?"})


def process_goal_info(club_id, goal_scorer, assist_provider, input_text):
    # Check if we have pending information for this club
    if club_id in pending_info:
        if goal_scorer and not assist_provider:
            assist_provider = pending_info[club_id].get('assist_provider')
        elif assist_provider and not goal_scorer:
            goal_scorer = pending_info[club_id].get('goal_scorer')

    # If we have both goal scorer and assist provider, update Firestore
    if goal_scorer and assist_provider:
        update_result = update_firestore(club_id, goal_scorer, assist_provider)
        # Clear pending info
        if club_id in pending_info:
            del pending_info[club_id]
        return jsonify(
            {"message": f"Goal by {goal_scorer}, assisted by {assist_provider}. {update_result}"})

    # If we only have goal scorer
    if goal_scorer and not assist_provider:
        pending_info[club_id] = {'goal_scorer': goal_scorer, 'timestamp': datetime.now()}
        return jsonify({"message": f"Goal by {goal_scorer} noted. Who provided the assist?"})

    # If we only have assist provider
    if assist_provider and not goal_scorer:
        pending_info[club_id] = {'assist_provider': assist_provider, 'timestamp': datetime.now()}
        return jsonify({"message": f"Assist by {assist_provider} noted. Who scored the goal?"})

    # If we don't have either, it might be a general query or unrelated input
    return handle_general_query(input_text)


def find_matching_players(players_ref, name):
    if not name:
        return []
    name = name.lower()
    matching_players = []

    all_players = players_ref.get()
    for player in all_players:
        player_data = player.to_dict()
        player_name = player_data['player_name'].lower()

        # Check for exact match
        if name == player_name:
            return [player]

        # Check for partial matches
        if name in player_name:
            matching_players.append(player)

        # Fuzzy matching
        if fuzz.partial_ratio(name, player_name) > 80:
            matching_players.append(player)

    return list({player.id: player for player in matching_players}.values())


def handle_general_query(input_text):
    fallback_response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a friendly sports assistant."},
            {"role": "user", "content": input_text}
        ],
        max_tokens=150
    )
    return jsonify({"message": fallback_response.choices[0].message.content.strip()})


def is_correction(input_text):
    correction_keywords = ['actually', 'correction', 'i meant', 'sorry', 'my bad']
    return any(keyword in input_text.lower() for keyword in correction_keywords)


def handle_correction(club_id, input_text):
    if club_id not in recent_goals or (
            datetime.now() - recent_goals[club_id]['timestamp']) > timedelta(minutes=5):
        return jsonify(
            {"message": "No recent goal to correct. Please provide full goal information."})

    # Parse the correction
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system",
             "content": "You are a sports assistant specialized in parsing "
                        "goal and assist corrections."},
            {"role": "user",
             "content": f"Extract any corrections to the goal scorer or "
                        f"assist provider from this text: '{input_text}'. Format the result as "
                        f"JSON with 'goal_scorer' and 'assist_provider' fields. If either is "
                        f"not mentioned or not being corrected, use null."}
        ],
        max_tokens=150
    )

    parsed_correction = json.loads(response.choices[0].message.content.strip())

    # Update the recent goal with corrections
    if parsed_correction.get('goal_scorer'):
        recent_goals[club_id]['goal_scorer'] = parsed_correction['goal_scorer']
    if parsed_correction.get('assist_provider'):
        recent_goals[club_id]['assist_provider'] = parsed_correction['assist_provider']

    # Update Firestore with the corrected information
    update_result = update_firestore(club_id, recent_goals[club_id]['goal_scorer'],
                                     recent_goals[club_id]['assist_provider'], is_correction=True)

    return jsonify({"message": f"Correction recorded. {update_result}"})


def handle_greeting(greeting):
    responses = {
        'hello': "Hello! How can I assist you with tracking goals and assists today?",
        'hi': "Hi there! Ready to record some football action?",
        'hey': "Hey! What's the latest on the pitch?",
        'greetings': "Greetings! How's the game going?",
        'good morning': "Good morning! Ready for some football talk?",
        'good afternoon': "Good afternoon! Any exciting matches happening?",
        'good evening': "Good evening! How can I help with your football stats?"
    }
    return jsonify({"message": responses.get(greeting.lower().strip(),
                                             "Hello! How can I help you with football today?")})


def update_firestore(club_id, goal_scorer, assist_provider, is_correction=False):
    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    def find_matching_players(name):
        if not name:
            return []
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
            return (f"Multiple players found matching '{player_name}': "
                    f"{', '.join(player_names)}. Please specify.")

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

    return '. '.join(result_messages)
