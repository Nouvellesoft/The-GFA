import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
from dotenv import load_dotenv
from google.cloud import firestore

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize OpenAI client
# client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
# Initialize OpenAI client
client = OpenAI(api_key='sk-GFTuZzkvMOyU6oJCvDAl5b-V4wx_gJP7nlPJGJZTIyT3BlbkFJCb3wPfhUjA'
                        'jkwzuW2s4H6iIBsydv41ouQvVLNKynAA')

# Initialize Firestore client
FIRESTORE_PROJECT_ID = 'the-gfa'  # Replace with your Firestore project ID
db = firestore.Client(project=FIRESTORE_PROJECT_ID)

# Add this at the top of your file, after the imports
assist_memory = {}
goal_memory = {}


@app.route('/parse', methods=['POST'])
def parse_message():
    data = request.json
    input_text = data.get('text')
    club_id = data.get('club_id')

    if not club_id:
        return jsonify({"error": "club_id is required"}), 400

    try:
        # Check if there's a remembered assist for this club
        remembered_assist = assist_memory.get(club_id)
        remembered_goal = goal_memory.get(club_id)

        # Make a request to OpenAI API
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system",
                 "content": "You are a sports assistant specialized in parsing goal and assist information from text."},
                {"role": "user",
                 "content": f"Extract the goal scorer and assist provider from this text: '{input_text}'. Format the result as JSON with 'goal_scorer' and 'assist_provider' fields. If either is not mentioned, use null."}
            ],
            max_tokens=150
        )

        parsed_data = json.loads(response.choices[0].message.content.strip())
        goal_scorer = parsed_data.get('goal_scorer') or remembered_goal
        assist_provider = parsed_data.get('assist_provider') or remembered_assist

        players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

        # If we're answering who assisted, and there's no goal_scorer in this message
        if not parsed_data.get('goal_scorer') and remembered_goal and assist_provider:
            goal_scorer = remembered_goal
            goal_memory.pop(club_id, None)  # Clear the remembered goal
            update_firestore(club_id, goal_scorer, assist_provider)
            return jsonify(
                {"message": f"Goal by {goal_scorer}, assist by {assist_provider} recorded."})

        if goal_scorer:
            goal_docs = players_ref.where('player_name', '==', goal_scorer).get()
            if len(goal_docs) > 1:
                return jsonify({
                                   "message": f"Multiple players found with the name {goal_scorer}. Please specify which one scored."})

        if assist_provider:
            assist_docs = players_ref.where('player_name', '==', assist_provider).get()
            if len(assist_docs) > 1:
                return jsonify({
                                   "message": f"Multiple players found with the name {assist_provider}. Please specify which one assisted."})

        if assist_provider and not goal_scorer:
            # Remember the assist provider for this club
            assist_memory[club_id] = assist_provider
            return jsonify({"message": f"Assist by {assist_provider} noted. Who scored the goal?"})

        if goal_scorer and assist_provider:
            # Update Firestore
            update_firestore(club_id, goal_scorer, assist_provider)
            # Clear the remembered assist and goal
            assist_memory.pop(club_id, None)
            goal_memory.pop(club_id, None)
            return jsonify(
                {"message": f"Goal by {goal_scorer}, assist by {assist_provider} recorded."})

        if goal_scorer and not assist_provider:
            # Remember the goal scorer for this club
            goal_memory[club_id] = goal_scorer
            return jsonify({"message": f"Goal by {goal_scorer} noted. Was there an assist?"})

        return jsonify({"message": "No goal or assist information detected."})

    except Exception as e:
        app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500


def update_firestore(club_id, goal_scorer, assist_provider):
    players_ref = db.collection('clubs').document(club_id).collection('PllayersTable')

    if goal_scorer:
        goal_docs = players_ref.where('player_name', '==', goal_scorer).get()
        if goal_docs:
            players_ref.document(goal_docs[0].id).update({'goals_scored': firestore.Increment(1)})

    if assist_provider:
        assist_docs = players_ref.where('player_name', '==', assist_provider).get()
        if assist_docs:
            players_ref.document(assist_docs[0].id).update({'assists': firestore.Increment(1)})


if __name__ == "__main__":
    app.run(debug=True)
