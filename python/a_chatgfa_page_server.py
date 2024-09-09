import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize OpenAI client
# client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
client = OpenAI(api_key='sk-vmlljSQyothDSl7Z21GzsO5mn2So2t_jvDSsEwsuFcT3BlbkFJf'
                        '_MQdlWiBQHFkNetmzB7CMtTZ_KGirEHKIoDSy8ooA')


@app.route('/parse', methods=['POST'])
def parse_message():
    input_text = request.json.get('text')

    try:
        # Make a request to OpenAI API
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",  # Choose the model based on your needs
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user",
                 "content": f"Extract the goal scorer and assist provider from this text: "
                            f"'{input_text}'. Format the result as JSON with 'goal_scorer' "
                            f"and 'assist_provider' fields."}
            ],
            max_tokens=50
        )

        # Extract and clean the response
        parsed_data = response.choices[0].message.content.strip()

        # Convert OpenAI response to a dictionary
        try:
            parsed_data_dict = json.loads(parsed_data)
        except json.JSONDecodeError:
            parsed_data_dict = {"goal_scorer": "", "assist_provider": ""}

        return jsonify(parsed_data_dict)

    except Exception as e:
        app.logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    # Run the Flask app
    app.run(debug=True)
