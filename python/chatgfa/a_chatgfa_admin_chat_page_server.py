import json
import os
import re
from pathlib import Path

import firebase_admin
from PIL import Image
import requests
from io import BytesIO
from flask import Flask, jsonify
from flask_cors import CORS
from openai import OpenAI
from dotenv import load_dotenv
from google.cloud import firestore
from fuzzywuzzy import fuzz
from datetime import datetime, timedelta
from firebase_admin import credentials, messaging, storage

# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Initialize Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'
db = firestore.Client(project=FIRESTORE_PROJECT_ID)

# Global variables to store recent goals, assists, and partial information
pending_info = {}
recent_goals = {}

# Use the path to the JSON file in Cloud Functions
FIREBASE_CREDENTIALS = os.path.join(os.path.dirname(__file__), 'firebase_credentials.json')

# Initialize Firebase Admin
cred = credentials.Certificate(FIREBASE_CREDENTIALS)
firebase_admin.initialize_app(cred, {
    'storageBucket': 'the-gfa.appspot.com'
})

touring_state = False


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

        # Check if the user is just touring, and prevent Firestore operations if True
        if touring_state:
            return jsonify({"message": "You are in touring mode. No data will be saved."})

        # Check if the input is a greeting
        if is_greeting(input_text):
            return handle_greeting(input_text)

        # Check if this is a correction to a recent goal
        if is_correction(input_text):
            return handle_correction(club_id, input_text)

        # Check if this is a single name response
        if is_single_name(input_text):
            return handle_single_name_response(club_id, input_text)

        # Check for yellow or red card
        card_keywords = ['yellow card', 'red card']
        if any(keyword in input_text.lower() for keyword in card_keywords):
            # Determine card type
            card_type = 'yellow_card' if 'yellow card' in input_text.lower() else 'red_card'

            # Extract player name
            player_name = None

            # Direct name extraction without OpenAI
            card_name_patterns = [
                r'(?:yellow|red)\s+card(?:\s+given)?\s+(?:to)?\s*(.+?)(?:\s+for|\s*$)',
                r'(.+?)\s+(?:got|received)\s+(?:a\s+)?(?:yellow|red)\s+card',
            ]

            for pattern in card_name_patterns:
                match = re.search(pattern, input_text.lower(), re.IGNORECASE)
                if match:
                    player_name = match.group(1).strip()
                    break

            if not player_name:
                return jsonify({"message": "No player name detected. Please specify the "
                                           "player who received the card."})

            return process_card_info(club_id, player_name, card_type)

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

        # Ensure Firestore updates only if not touring
        if not touring_state:
            return process_goal_info(club_id, goal_scorer, assist_provider, input_text)

        return jsonify({"message": "You are in touring mode. No changes to Firestore."})

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


def blend_images(goal_scorer_image_url, assist_provider_image_url):
    # Fetch the images from the URLs
    goal_scorer_image = Image.open(BytesIO(requests.get(goal_scorer_image_url).content))
    assist_provider_image = Image.open(BytesIO(requests.get(assist_provider_image_url).content))

    # Resize images to be the same height (optional)
    base_height = min(goal_scorer_image.height, assist_provider_image.height)
    goal_scorer_image = goal_scorer_image.resize(
        (int(goal_scorer_image.width * (base_height / goal_scorer_image.height)), base_height))
    assist_provider_image = assist_provider_image.resize(
        (int(assist_provider_image.width *
             (base_height / assist_provider_image.height)), base_height))

    # Create a new blank image to merge the two
    new_width = goal_scorer_image.width + assist_provider_image.width
    new_image = Image.new('RGB', (new_width, base_height))

    # Paste both images into the new image
    new_image.paste(goal_scorer_image, (0, 0))
    new_image.paste(assist_provider_image, (goal_scorer_image.width, 0))

    # Save the combined image to a BytesIO object instead of a file
    img_byte_arr = BytesIO()
    new_image.save(img_byte_arr, format='JPEG')
    img_byte_arr.seek(0)  # Rewind the BytesIO object to the beginning

    return img_byte_arr


def upload_image_to_firebase(image_stream, upload_path):
    bucket = storage.bucket()
    blob = bucket.blob(upload_path)

    # Upload the image directly from the BytesIO stream
    blob.upload_from_file(image_stream, content_type='image/jpeg')

    # Make the image publicly accessible
    blob.make_public()

    return blob.public_url


def process_goal_info(club_id, goal_scorer, assist_provider, input_text):
    # Fetch player details from Firestore
    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    def get_player_stats(player_name):
        players = find_matching_players(players_ref, player_name)
        if players:
            player = players[0].to_dict()  # Assume only one player matches
            return {
                'player_name': player.get('player_name', 'Unknown'),
                'matches_played': player.get('matches_played', 0),
                'goals_scored': player.get('goals_scored', 0),
                'assists': player.get('assists', 0),
                'yellow_cards': player.get('yellow_card', 0),  # Correct field name
                'red_cards': player.get('red_card', 0),  # Correct field name
                'nationality': player.get('nationality', 'Unknown'),
                'image': player.get('image', ''),
            }
        return None

    if goal_scorer or assist_provider:
        goal_scorer_stats = get_player_stats(goal_scorer) if goal_scorer else None
        assist_provider_stats = get_player_stats(assist_provider) if assist_provider else None

        # If we only have goal scorer
        if goal_scorer and not assist_provider:
            pending_info[club_id] = {'goal_scorer': goal_scorer, 'timestamp': datetime.now()}
            return jsonify({"message": f"Goal by {goal_scorer} noted. Who provided the assist?"})

        # If we only have assist provider
        if assist_provider and not goal_scorer:
            pending_info[club_id] = {'assist_provider': assist_provider,
                                     'timestamp': datetime.now()}
            return jsonify({"message": f"Assist by {assist_provider} noted. Who scored the goal?"})

        # Ensure both players are found
        if not goal_scorer_stats or not assist_provider_stats:
            missing_players = []
            if not goal_scorer_stats:
                missing_players.append(goal_scorer)
            if not assist_provider_stats:
                missing_players.append(assist_provider)
            return jsonify({"error": f"Stats for {', '.join(missing_players)} not found. "
                                     f"Please check player names."})

        # Create the prompt with player stats
        prompt = (
            f"{goal_scorer_stats['player_name']} scored a goal assisted by "
            f"{assist_provider_stats['player_name']}\n"
            f"{goal_scorer_stats['player_name']} Stats: {goal_scorer_stats['goals_scored']} goals, "
            f"{goal_scorer_stats['assists']} assists, "
            f"{goal_scorer_stats['matches_played']} matches played.\n"
            f"{assist_provider_stats['player_name']} "
            f"Stats: {assist_provider_stats['assists']} assists, "
            f"{assist_provider_stats['matches_played']} matches played.\n"
            "Generate a notification within 14 words summarizing the event and their stats."
        )

        # Generate notification body using OpenAI
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=50
        )
        generated_content = response.choices[0].message.content.strip()

        # Generate notification title
        notification_title = (f"Goal by {goal_scorer_stats['player_name']} "
                              f"- Assist by {assist_provider_stats['player_name']}")

        # Generate and upload the blended image
        blended_image_stream = blend_images(goal_scorer_stats['image'],
                                            assist_provider_stats['image'])
        merged_image_url = upload_image_to_firebase(
            blended_image_stream, f"images/merged_image_{club_id}.jpg"
        )

        # Send notification using FCM
        send_fcm_notification(club_id, notification_title, generated_content, merged_image_url)

        # Update Firestore with the goal and assist stats
        update_result = update_firestore(club_id, goal_scorer, assist_provider)
        return jsonify(
            {"message": f"Goal by {goal_scorer}, "
                        f"assisted by {assist_provider}. {update_result}"}
        )

    # If we don't have either, it might be a general query or unrelated input
    return handle_general_query(input_text)


def send_fcm_notification(club_id, title, body, image_url):
    """
    Sends an FCM notification to the specified club (topic).
    """
    # Prepare the message payload for FCM
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
            image=image_url  # Optional image URL
        ),
        topic=club_id  # Send notification to a topic based on club_id
    )

    # Send the message via Firebase Cloud Messaging
    try:
        response = messaging.send(message)
        print(f"Successfully sent message: {response}")
        print(f"Notification Details:")
        print(f"Topic: {club_id}")
        print(f"Title: {title}")
        print(f"Body: {body}")
        print(f"Image URL: {image_url}")
    except Exception as e:
        print(f"Error sending message: {e}")
        # Consider logging more details about the error
        import traceback
        traceback.print_exc()


def process_card_info(club_id, player_name, card_type):
    """
    Process yellow or red card information for a given player.
    Ensures stats are updated before generating notification.
    """
    if not player_name:
        return jsonify({"message": "No player name detected. Please specify "
                                   "the player who received the card."})

    print(f"Processing card info: club_id={club_id}, player_name={player_name}, "
          f"card_type={card_type}")

    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    # Find the matching player
    matching_players = find_matching_players(players_ref, player_name)

    if not matching_players:
        return jsonify({"message": f"No player found matching '{player_name}' in the team."})

    if len(matching_players) > 1:
        player_names = [player.to_dict()['player_name'] for player in matching_players]
        return jsonify({"message": f"Multiple players found matching '{player_name}': "
                                   f"{', '.join(player_names)}. Please specify."})

    # Get the player document
    player_doc = matching_players[0]
    player_id = player_doc.id
    player_data = player_doc.to_dict()

    # Ensure correct field names
    card_field = 'yellow_card' if card_type == 'yellow_card' else 'red_card'

    # Perform the card increment
    players_ref.document(player_id).update({card_field: firestore.Increment(1)})

    # Fetch the updated player data after increment
    updated_player_doc = players_ref.document(player_id).get()
    updated_player_data = updated_player_doc.to_dict()

    # Generate notification title
    notification_title = (f"{card_type.replace('_', ' ').title()} Awarded to "
                          f"{updated_player_data['player_name']}")

    # Generate notification body using the updated stats
    notification_body = generate_card_notification(updated_player_data, card_type)
    player_image_url = updated_player_data.get('image', '')

    # Send FCM notification
    send_fcm_notification(
        club_id=club_id,
        title=notification_title,
        body=notification_body,
        image_url=player_image_url
    )

    return jsonify({
        "message": f"{card_type.replace('_', ' ').capitalize()} "
                   f"recorded for {updated_player_data['player_name']}"})


def generate_card_notification(player_data, card_type):
    """
    Generate a creative notification for yellow or red cards using OpenAI.

    Args:
        player_data (dict): Player statistics dictionary
        card_type (str): 'yellow_card' or 'red_card'

    Returns:
        str: AI-generated notification message
    """
    # Extract relevant stats
    yellow_cards = player_data.get('yellow_card', 0)
    red_cards = player_data.get('red_card', 0)
    goals = player_data.get('goals_scored', 0)
    assists = player_data.get('assists', 0)
    matches_played = player_data.get('matches_played', 0)
    player_name = player_data.get('player_name', 'Player')

    # Prepare prompt for OpenAI
    prompt = (
        f"Generate a creative, concise {card_type.replace('_', ' ')} notification "
        f"for {player_name} in less than 15 words. "
        f"The player's stats are: {yellow_cards} yellow cards, {red_cards} red cards, "
        f"{goals} goals, {assists} assists, {matches_played} matches played. You don't always "
        f"have to include the stats nor all of it nor any just "
        f"make the {card_type.replace('_', ' ')} relevant and funny or "
        f"something to captivate the receivers of the notification."
        f"Use a playful, engaging tone that captures the drama of the moment."
    )

    try:
        # Use OpenAI to generate the notification
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a witty sports commentator generating "
                                              "concise, exciting match notifications."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=50,
            temperature=0.7  # Adds some creativity
        )

        # Extract and clean the generated message
        generated_message = response.choices[0].message.content.strip()

        # Ensure the message is not too long
        if len(generated_message) > 100:
            generated_message = generated_message[:100] + "..."

        return generated_message

    except Exception as e:
        # Fallback to a default message if OpenAI generation fails
        default_messages = {
            'yellow_card': f"🟨 {player_name} walks the tightrope with card #{yellow_cards}!",
            'red_card': f"🔴 {player_name} sees red - game-changing moment!"
        }
        return default_messages.get(card_type,
                                    f"{card_type.replace('_', ' ').title()} for {player_name}")


def find_matching_players(players_ref, name):
    if not name:
        return []

    # Normalize the input name by stripping whitespace and converting to lowercase
    name = name.strip().lower()
    matching_players = []

    all_players = players_ref.get()
    for player in all_players:
        player_data = player.to_dict()
        player_name = player_data['player_name'].lower()

        # Check for exact match
        if name == player_name:
            return [player]

        # Check for partial match (any part of the name)
        name_parts = name.split()
        stored_name_parts = player_name.split()

        # Check if any name part matches any part of the stored name
        if any(part in stored_name_parts for part in name_parts):
            matching_players.append(player)

        # Fuzzy matching with lowered names
        if fuzz.partial_ratio(name, player_name) > 80:
            matching_players.append(player)

    # Remove duplicates while preserving order
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
    # Skip Firestore update if the user is in touring mode
    if touring_state:
        return "Touring mode active. No updates to Firestore will occur."

    # Continue with Firestore update logic if not touring
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
