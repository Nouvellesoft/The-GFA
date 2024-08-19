from google.cloud import firestore
from apify_client import ApifyClient

# Your Apify API token
APIFY_TOKEN = 'apify_api_KhK9u2juMKX6BZzwzfSyi5johqdPzE4w5cvB'
# Actor ID
ACTOR_ID = 'KoJrdxJCTtpon81KY'
# Firestore Project ID
FIRESTORE_PROJECT_ID = 'the-gfa'

# Initialize Firestore
db = firestore.Client(project=FIRESTORE_PROJECT_ID)


def fetch_latest_post(username):
    # Initialize the ApifyClient with your API token
    client = ApifyClient(APIFY_TOKEN)

    # Prepare the Actor input
    run_input = {
        "resultsLimit": 7,
        "startUrls": [
            {
                "url": f"https://www.facebook.com/{username}/"
            }
        ]
    }

    try:
        # Start the Actor task
        run = client.actor(ACTOR_ID).call(run_input=run_input)
        run_id = run['id']
        print(f"Actor run started with ID: {run_id}")

        # Wait for the actor to complete
        # (you might want to use a better method for waiting/checking completion)
        client.run(run_id).wait_for_finish()

        # Get dataset items from the run
        dataset_id = run["defaultDatasetId"]
        dataset = client.dataset(dataset_id)

        latest_post = None
        latest_timestamp = None

        # Fetch and compare dataset items
        for item in dataset.iterate_items():
            item_timestamp = item.get('timestamp')

            if item_timestamp and (latest_timestamp is None or item_timestamp > latest_timestamp):
                latest_post = item
                latest_timestamp = item_timestamp

        if latest_post:
            post_id = extract_post_id(latest_post)
            print(f'Facebook post ID: {post_id}')
            return post_id
        else:
            print('No dataset items found.')
            return None

    except Exception as e:
        print(f"An error occurred while fetching the post: {e}")
        return None


def extract_post_id(item):
    # Extract the postId from the item
    post_id = item.get('postId', '')
    return post_id


def update_firestore_with_post(club_id, post_id):
    try:
        # Navigate to the club document and update the 'facebook_post_handle' field
        about_page_ref = (db.collection('clubs').document(club_id)
                          .collection('AboutClub').document('about_club_page'))
        about_page_ref.update({
            'facebook_post_handle': post_id
        })
        print(f"Updated {club_id} with facebook_post_handle: {post_id}")
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
                facebook_handle = doc.get('facebook_handle')
                print(f"Fetched facebook_handle for {club_id}: {facebook_handle}")

                # Fetch the Facebook post ID using the handle
                if facebook_handle:
                    post_id = fetch_latest_post(facebook_handle)

                    # If a post ID was found, update Firestore
                    if post_id:
                        update_firestore_with_post(club_id, post_id)
                    else:
                        print(f"No post ID found for {facebook_handle}.")
                else:
                    print(f"No facebook_handle found for {club_id}.")
            else:
                print(f"Document not found for {club_id}.")
    except Exception as e:
        print(f"An error occurred while processing clubs: {e}")


def main():
    # Process all clubs and update Firestore
    process_all_clubs()


if __name__ == '__main__':
    main()
