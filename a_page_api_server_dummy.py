import tweepy

# Replace these with your actual credentials
bearer_token = 'AAAAAAAAAAAAAAAAAAAAABThkwEAAAAA8JXbM7qYxP%2BFnYGPsDyeK0A55XE%3DgtWhAaSHR4YVGZg0FOCSEPLLyVlwvrMSuHScloTaLJ4Czxm1Qu'
consumer_key = 'Me3Wk1SYNsu0F4YnlxOwjDrpj'
consumer_secret = '2shziqmbtTMDkP5qVOemQCoNhAkyOdxbFSHi1YC90MoE65WNJ3'
access_token = '1019261607006883841-rVx4134bwatHvOsFhDIjr2OQUb9wb9'
access_token_secret = 'PIO35OZ6L5eWAU1QAzFXX4xHAVV1G4cC2O5S6BRhaLnj7'


# Authenticate to Twitter
client = tweepy.Client(bearer_token=bearer_token,
                       consumer_key=consumer_key,
                       consumer_secret=consumer_secret,
                       access_token=access_token,
                       access_token_secret=access_token_secret)


# Fetch recent tweets from the user using API v2
def fetch_and_print_tweets(username, tweet_count=5):
    try:
        # Fetch user ID from username
        user = client.get_user(username=username)
        user_id = user.data.id

        # Fetch recent tweets
        response = client.get_users_tweets(user_id, max_results=tweet_count)

        # Print tweet details
        for tweet in response.data:
            print(f"Tweet created at: {tweet.created_at}")
            print(f"Tweet text: {tweet.text}")
            print("-" * 40)

    except Exception as e:
        print(f"An error occurred: {e}")


# Example usage
if __name__ == "__main__":
    fetch_and_print_tweets('zelenskyyua', tweet_count=5)
