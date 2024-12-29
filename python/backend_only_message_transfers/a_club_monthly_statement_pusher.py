import base64
import os
from pathlib import Path

from dotenv import load_dotenv

import smtplib
import logging
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from flask import Flask, request, jsonify


# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize keys
GMAIL_PASSCODE = os.getenv('GMAIL_PASSCODE')

# Initialize Flask app
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


@app.route('/send_email_with_pdf', methods=['POST'])
def send_email_with_pdf():
    try:
        logging.info("Received request to send email with PDF.")
        data = request.get_json()
        pdf_base64 = data['pdf']
        email = data['email']

        # Decode the base64 PDF
        pdf_data = base64.b64decode(pdf_base64)
        pdf_filename = "monthly_report.pdf"
        logging.info(f"Decoded PDF data and prepared file: {pdf_filename}")

        # Prepare email
        from_email = "david.oludepo@gmail.com"
        to_email = email
        subject = "Monthly Performance Report"
        body = "Please find attached the Monthly Performance Report."

        msg = MIMEMultipart()
        msg['From'] = from_email
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))
        logging.info("Prepared email message.")

        # Attach PDF file
        attachment = MIMEBase('application', 'octet-stream')
        attachment.set_payload(pdf_data)
        encoders.encode_base64(attachment)
        attachment.add_header('Content-Disposition', f'attachment; filename={pdf_filename}')
        msg.attach(attachment)
        logging.info("Attached PDF to the email.")

        # Send the email
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        logging.info("Connected to the SMTP server.")
        server.login(from_email, GMAIL_PASSCODE)
        logging.info("Logged in to SMTP server.")
        server.sendmail(from_email, to_email, msg.as_string())
        server.quit()
        logging.info(f"Email sent successfully to {to_email}.")
        return jsonify({"status": "success"}), 200

    except Exception as e:
        logging.error(f"Failed to send email: {str(e)}")
        return jsonify({"status": "failed", "error": str(e)}), 500


@app.route('/trigger', methods=['GET'])
def trigger():
    logging.info("Trigger route accessed.")
    return jsonify({"message": "generate_pdf"}), 200


if __name__ == '__main__':
    logging.info("Starting Flask server.")
    app.run(host='0.0.0.0', port=5001)
