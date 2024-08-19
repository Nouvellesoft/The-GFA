from google.cloud import firestore
from apify_client import ApifyClient
from urllib.parse import urlparse

# Your Apify API token
APIFY_TOKEN = 'apify_api_KhK9u2juMKX6BZzwzfSyi5johqdPzE4w5cvB'
# Actor ID
ACTOR_ID = 'nH2AHrwxeTRJoN5hX'
# Firestore Project ID
FIRESTORE_PROJECT_ID = 'the-gfa'

# Initialize Firestore
db = firestore.Client(project=FIRESTORE_PROJECT_ID)


def fetch_latest_post(username):
    # Initialize the ApifyClient with your API token
    client = ApifyClient(APIFY_TOKEN)

    # Prepare the Actor input
    run_input = {
        "username": [username],
        "resultsLimit": 4
    }

    try:
        # Start the Actor task
        run = client.actor(ACTOR_ID).call(run_input=run_input)
        run_id = run['id']
        print(f"Actor run started with ID: {run_id}")

        # Get dataset items from the run
        dataset_id = run["defaultDatasetId"]
        dataset = client.dataset(dataset_id)

        # Initialize variables to track the latest post
        latest_post = None
        latest_timestamp = None

        # Fetch and compare dataset items
        for item in dataset.iterate_items():
            item_timestamp = item.get('timestamp')

            if item_timestamp and (latest_timestamp is None or item_timestamp > latest_timestamp):
                latest_post = item
                latest_timestamp = item_timestamp

        # Return the Instagram post code from the URL
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
    # Parse the URL and extract the path
    parsed_url = urlparse(url)
    post_code = parsed_url.path.strip('/').split('/')[-1]
    return post_code


def update_firestore_with_post(club_id, post_code):
    try:
        # Navigate to the club document and update the 'instagram_post_handle' field
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
        # Fetch all documents in the 'clubs' collection
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

                # Fetch the Instagram post code using the handle
                if instagram_handle:
                    post_code = fetch_latest_post(instagram_handle)

                    # If a post code was found, update Firestore
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


def main():
    # Process all clubs and update Firestore
    process_all_clubs()


if __name__ == '__main__':
    main()
