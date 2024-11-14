import spacy
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from google.cloud import firestore
from openai import OpenAI
from fuzzywuzzy import process

# Load environment variables and set up Firestore and OpenAI clients
load_dotenv()
app = Flask(__name__)
db = firestore.Client()

# Initialize OpenAI client
client = OpenAI(api_key='sk-GFTuZzkvMOyU6oJCvDAl5b-V4wx_gJP7nlPJGJZTIyT3BlbkFJCb3wPfhUjA'
                        'jkwzuW2s4H6iIBsydv41ouQvVLNKynAA')

# Load the spaCy model
nlp = spacy.load("en_core_web_sm")

# Example list of potential fields for flexible matching
POTENTIAL_FIELDS = [
    "vision", "vision_statement", "mission", "mission_statement",
    "goals_scored", "assists", "matches_played", "player_value",
    "age", "player_name", "goals", "preferred_foot", "clean_sheets_gk"
]


def find_closest_field(query_field, available_fields):
    """
    Find the closest matching field from available fields using fuzzy matching.
    """
    closest_match = process.extractOne(query_field, available_fields)
    if closest_match and closest_match[1] > 60:  # Threshold score
        return closest_match[0]
    return None


def search_firestore_for_answer(club_id, query):
    try:
        # Analyze the user's query using spaCy
        doc = nlp(query)
        target = None
        field_requested = None

        # Extract entity names and potential fields from the query
        for entity in doc.ents:
            if entity.label_ in {"PLAYER", "ORG", "CLUB_INFO"}:
                target = entity.text.strip().title()

        # Extract potential field names from the query (e.g., goals, assists, vision, etc.)
        for token in doc:
            if token.lemma_ in {"goal", "assist", "match", "vision", "mission", "value", "age"}:
                field_requested = token.text.lower()
                break

        if not target and not field_requested:
            return "Could not identify a specific target or field in the query."

        # Reference the main club document
        club_ref = db.collection('clubs').document(club_id)
        club_doc = club_ref.get()

        # Check main club document for general fields (e.g., vision, mission)
        if club_doc.exists and not target:
            club_info = club_doc.to_dict()
            if field_requested:
                closest_field = find_closest_field(field_requested, club_info.keys())
                if closest_field:
                    return {closest_field: club_info[closest_field]}

        # Search through all subcollections dynamically
        subcollections = club_ref.collections()
        for subcollection in subcollections:
            docs = subcollection.get()

            for doc in docs:
                data = doc.to_dict()

                # If target is a player, search for player-specific data
                if 'player_name' in data and data['player_name'] == target:
                    if field_requested:
                        closest_field = find_closest_field(field_requested, data.keys())
                        if closest_field:
                            return {closest_field: data[closest_field]}
                    else:
                        # Return the full player data if no specific field is requested
                        return data

                # General search across all document fields
                closest_field = find_closest_field(field_requested, data.keys())
                if closest_field:
                    return {closest_field: data[closest_field]}

        # No matching information found
        return "No matching information found for your query. Please try refining your question."

    except Exception as e:
        return f"Error retrieving data: {str(e)}"


@app.route('/general_chat', methods=['POST'])
def general_chat():
    data = request.json
    input_text = data.get('text')
    club_id = data.get('club_id')

    if not input_text or not club_id:
        return jsonify({"error": "Both 'text' and 'club_id' are required"}), 400

    # Try to retrieve answer from Firestore
    firestore_answer = search_firestore_for_answer(club_id, input_text)
    if firestore_answer:
        return jsonify({"message": firestore_answer})

    # If no Firestore data, use OpenAI to generate a general response
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


if __name__ == "__main__":
    app.run(debug=True)
