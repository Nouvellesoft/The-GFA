import logging
import os
from pathlib import Path

from dotenv import load_dotenv
from google.cloud import firestore
from openai import OpenAI
from twilio.rest import Client
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize logging
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')


class PlayerCommunicationSystem:
    def __init__(self,
                 openai_api_key,
                 smtp_server="smtp.gmail.com",
                 smtp_port=587,
                 sender_email=None,
                 sender_password=None,
                 twilio_account_sid=None,
                 twilio_auth_token=None,
                 twilio_number=None):
        """
        Initialize the communication system with necessary configurations
        """
        logging.info("Initializing PlayerCommunicationSystem...")

        # Initialize OpenAI client
        self.openai_client = OpenAI(api_key=openai_api_key)
        logging.debug("OpenAI client initialized.")

        # Initialize Firestore client
        FIRESTORE_PROJECT_ID = 'the-gfa'
        self.firestore_client = firestore.Client(project=FIRESTORE_PROJECT_ID)
        logging.debug("Firestore client initialized.")

        # Email configuration
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.sender_email = sender_email
        self.sender_password = sender_password
        logging.debug("Email configuration set up.")

        # Twilio configuration
        if twilio_account_sid and twilio_auth_token and twilio_number:
            self.twilio_client = Client(twilio_account_sid, twilio_auth_token)
            self.twilio_number = twilio_number
            logging.debug("Twilio client initialized.")
        else:
            self.twilio_client = None
            self.twilio_number = None
            logging.warning("Twilio not configured.")

    def get_player_stats(self, club_name, player_name):
        """
        Retrieve player stats by matching names across collections
        """
        try:
            logging.info(f"Retrieving stats for {player_name} in {club_name}...")
            players_ref = (self.firestore_client.collection('clubs')
                           .document(club_name).collection('PllayersTable'))
            stats_query = players_ref.where('player_name', '==', player_name).limit(1)
            stats_docs = list(stats_query.stream())

            if stats_docs:
                logging.debug(f"Stats found for {player_name}: {stats_docs[0].to_dict()}")
                return stats_docs[0].to_dict()

            for doc in players_ref.stream():
                if doc.to_dict().get('player_name', '').lower() == player_name.lower():
                    logging.debug(f"Case-insensitive match found for "
                                  f"{player_name}: {doc.to_dict()}")
                    return doc.to_dict()

            logging.warning(f"No stats found for {player_name} in {club_name}")
            return None
        except Exception as e:
            logging.error(f"Error retrieving player stats for {player_name}: {e}")
            return None

    def generate_ai_message(self, player_stats):
        """
        Generate personalized performance message using OpenAI
        """
        try:
            logging.info(f"Generating AI message for "
                         f"{player_stats.get('player_name', 'Player')}...")
            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional sports performance analyst "
                                   "providing motivational and constructive feedback."
                    },
                    {
                        "role": "user",
                        "content": f"""Generate a performance analysis 
                        for {player_stats.get('player_name', 'Player')}:
                        - Age: {player_stats.get('age', 'N/A')}
                        - Matches Played: {player_stats.get('matches_played', 0)}
                        - Goals Scored: {player_stats.get('goals_scored', 0)}
                        - Assists: {player_stats.get('assists', 0)}
                        - Yellow Cards: {player_stats.get('yellow_card', 0)}"""
                    }
                ],
                max_tokens=400
            )
            logging.debug(f"AI message generated: {response.choices[0].message.content}")
            return response.choices[0].message.content
        except Exception as e:
            logging.error(f"AI message generation error: {e}")
            return f"Performance summary for {player_stats.get('player_name', 'Player')}"

    def create_html_email(self, player_name, player_stats, ai_message):
        """
        Create styled HTML email with player performance details
        """
        return f'''
        <div style="background-color: #f0f0f0; border-radius: 15px; 
        padding: 20px; text-align: justify;">
            <h2>Performance Analysis: {player_name}</h2>
            <div style="background-color: #e0e0e0; padding: 10px; border-radius: 10px;">
                <strong>Performance Snapshot:</strong>
                <ul>
                    <li>Matches Played: {player_stats.get('matches_played', 0)}</li>
                    <li>Goals: {player_stats.get('goals_scored', 0)}</li>
                    <li>Assists: {player_stats.get('assists', 0)}</li>
                </ul>
            </div>
            <p>{ai_message}</p>
            <p><em>Sincerely,<br>ChatGFA Performance Team</em></p>
        </div>
        '''

    def send_email(self, recipient, subject, html_content):
        """
        Send HTML email using SMTP
        """
        try:
            logging.info(f"Sending email to {recipient}...")
            msg = MIMEMultipart('alternative')
            msg['From'] = self.sender_email
            msg['To'] = recipient
            msg['Subject'] = subject
            msg.attach(MIMEText(html_content, 'html'))

            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.sender_email, self.sender_password)
                server.sendmail(self.sender_email, recipient, msg.as_string())
            logging.info(f"Email sent to {recipient}")
        except Exception as e:
            logging.error(f"Email sending failed to {recipient}: {e}")

    def send_sms(self, phone_number, message):
        """
        Send SMS using Twilio
        """
        if not self.twilio_client:
            logging.warning("Twilio not configured. Cannot send SMS.")
            return

        try:
            logging.info(f"Sending SMS to {phone_number}...")
            self.twilio_client.messages.create(
                body=message,
                from_=self.twilio_number,
                to=phone_number
            )
            logging.info(f"SMS sent to {phone_number}")
        except Exception as e:
            logging.error(f"SMS sending failed to {phone_number}: {e}")

    def process_communications(self):
        """
        Main method to process communications for all clubs
        """
        team_classes = [
            'FirstTeamClassPlayers', 'SecondTeamClassPlayers',
            'ThirdTeamClassPlayers', 'FourthTeamClassPlayers',
            'FifthTeamClassPlayers', 'SixthTeamClassPlayers'
        ]

        clubs_ref = self.firestore_client.collection('clubs')
        clubs = clubs_ref.stream()

        for club in clubs:
            club_name = club.id
            logging.info(f"Processing club: {club_name}")

            for team_class in team_classes:
                team_players_ref = clubs_ref.document(club_name).collection(team_class)
                team_players = team_players_ref.stream()

                for player in team_players:
                    player_data = player.to_dict()
                    player_name = player_data.get('name')

                    if player_name:
                        player_stats = self.get_player_stats(club_name, player_name)

                        if player_stats:
                            ai_message = self.generate_ai_message(player_stats)
                            subject = f"Performance Review: {player_name}"
                            html_content = (
                                self.create_html_email(player_name, player_stats, ai_message))
                            email = player_data.get('email')
                            phone = player_data.get('phone')

                            if email:
                                self.send_email(email, subject, html_content)
                            elif phone and self.twilio_client:
                                sms_message = (f"Performance Summary for {player_name}: "
                                               f"Goals: {player_stats.get('goals_scored', 0)}, "
                                               f"Assists: {player_stats.get('assists', 0)}. "
                                               f"Keep pushing your limits! - ChatGFA")
                                self.send_sms(phone, sms_message)
                            else:
                                logging.warning(f"No contact info for {player_name}")


def main():
    communication_system = PlayerCommunicationSystem(
        openai_api_key=os.getenv('OPENAI_API_KEY'),
        sender_email='david.oludepo@gmail.com',
        sender_password=os.getenv('GMAIL_PASSCODE'),
        twilio_account_sid=os.getenv('TWILIO_ACCOUNT_SID'),
        twilio_auth_token=os.getenv('TWILIO_AUTH_TOKEN'),
        twilio_number=os.getenv('TWILIO_PHONE_NUMBER')
    )
    communication_system.process_communications()


if __name__ == "__main__":
    main()
