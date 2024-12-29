import os
from pathlib import Path

from dotenv import load_dotenv
from google.cloud import firestore
from apify_client import ApifyClient
from urllib.parse import urlparse


# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize keys
APIFY_TOKEN = os.getenv('APIFY_TOKEN')
ACTOR_ID = os.getenv('ACTOR_ID')

# Firestore Project ID
FIRESTORE_PROJECT_ID = 'the-gfa'

# Initialize Firestore
db = firestore.Client(project=FIRESTORE_PROJECT_ID)


def fetch_latest_post(username):
    client = ApifyClient(APIFY_TOKEN)
    run_input = {
        "username": [username],
        "resultsLimit": 4
    }

    try:
        run = client.actor(ACTOR_ID).call(run_input=run_input)
        run_id = run['id']
        print(f"Actor run started with ID: {run_id}")

        dataset_id = run["defaultDatasetId"]
        dataset = client.dataset(dataset_id)

        latest_post = None
        latest_timestamp = None

        for item in dataset.iterate_items():
            item_timestamp = item.get('timestamp')

            if item_timestamp and (latest_timestamp is None or item_timestamp > latest_timestamp):
                latest_post = item
                latest_timestamp = item_timestamp

        if latest_post:
            latest_post_url = latest_post.get("url", "")
            print(f'Latest post URL: {latest_post_url}')
            post_code = extract_post_code(latest_post_url)
            print(f'Instagram post code: {post_code}')
            return post_code
        else:
            print('No dataset items found.')
            return None

    except Exception as e:
        print(f"An error occurred while fetching the post: {e}")
        return None


def extract_post_code(url):
    parsed_url = urlparse(url)
    post_code = parsed_url.path.strip('/').split('/')[-1]
    return post_code


def update_firestore_with_post(club_id, post_code):
    try:
        about_page_ref = (db.collection('clubs').document(club_id)
                          .collection('AboutClub').document('about_club_page'))
        about_page_ref.update({
            'instagram_post_handle': post_code
        })
        print(f"Updated {club_id} with instagram_post_handle: {post_code}")
    except Exception as e:
        print(f"An error occurred while updating Firestore: {e}")


def process_all_clubs():
    try:
        clubs_ref = db.collection('clubs')
        docs = clubs_ref.stream()

        for doc in docs:
            club_id = doc.id
            about_page_ref = (db.collection('clubs').document(club_id)
                              .collection('AboutClub').document('about_club_page'))
            doc = about_page_ref.get()
            if doc.exists:
                instagram_handle = doc.get('instagram_handle')
                print(f"Fetched instagram_handle for {club_id}: {instagram_handle}")

                if instagram_handle:
                    post_code = fetch_latest_post(instagram_handle)

                    if post_code:
                        update_firestore_with_post(club_id, post_code)
                    else:
                        print(f"No post code found for {instagram_handle}.")
                else:
                    print(f"No instagram_handle found for {club_id}.")
            else:
                print(f"Document not found for {club_id}.")
    except Exception as e:
        print(f"An error occurred while processing clubs: {e}")


def hello_pubsub_instagram():  # (event, context):
    process_all_clubs()
