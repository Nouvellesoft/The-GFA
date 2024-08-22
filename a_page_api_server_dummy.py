from apify_client import ApifyClient

# Your Apify API token
APIFY_TOKEN = 'apify_api_KhK9u2juMKX6BZzwzfSyi5johqdPzE4w5cvB'
# Actor ID
ACTOR_ID = 'nH2AHrwxeTRJoN5hX'


def fetch_latest_post():
    # Initialize the ApifyClient with your API token
    client = ApifyClient(APIFY_TOKEN)

    # Prepare the Actor input
    run_input = {
        "username": ["davidautobio"],
        "resultsLimit": 5
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
            # Assuming the post has a 'timestamp' field
            item_timestamp = item.get('timestamp')  # Change 'timestamp' to your actual field name

            if item_timestamp and (latest_timestamp is None or item_timestamp > latest_timestamp):
                latest_post = item
                latest_timestamp = item_timestamp

        # Print the latest post
        if latest_post:
            print(f'Latest post ID: {latest_post.get("id", "No ID found")}')
            print(f'Latest post URL: {latest_post.get("url", "No URL found")}')
            print(f'Latest post timestamp: {latest_post.get("timestamp", "No timestamp found")}')
        else:
            print('No dataset items found.')

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == '__main__':
    fetch_latest_post()
