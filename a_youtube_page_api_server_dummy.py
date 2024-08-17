from flask import Flask, jsonify, request
from apscheduler.schedulers.background import BackgroundScheduler
import requests

app = Flask(__name__)

# Configuration
YOUTUBE_API_KEY = 'AIzaSyD5QDjHfD-7WIhmoMmhDAT_57NnbLc1rPk'
STATIC_CHANNEL_NAME = 'CoventryPhoenixFC'  # Static channel name for testing
latest_videos = []


def get_channel_id_from_name(channel_name):
    try:
        url = (
            f"https://www.googleapis.com/youtube/v3/search?part=snippet"
            f"&q={channel_name}&type=channel&key={YOUTUBE_API_KEY}"
        )
        print(f"Requesting URL: {url}")
        response = requests.get(url)
        data = response.json()
        print(f"Response Data: {data}")
        channels = data.get('items', [])
        print(f"Fetched channels for {channel_name}: {channels}")  # Debug print
        if channels:
            return channels[0]['id']['channelId']  # Correctly extract the channel ID
        return None
    except Exception as e:
        print(f"Error fetching channel ID for name {channel_name}: {e}")
        return None


def get_latest_videos(api_key, channel_id, max_results=10):
    try:
        url = (
            f"https://www.googleapis.com/youtube/v3/search?key={api_key}"
            f"&channelId={channel_id}&part=snippet,id&order=date&maxResults={max_results}"
        )
        response = requests.get(url)
        videos = response.json().get('items', [])
        print(f"Fetched videos for channel ID {channel_id}: {videos}")  # Debug print
        video_urls = [
            f"https://www.youtube.com/watch?v={video['id']['videoId']}"
            for video in videos if video['id']['kind'] == 'youtube#video'
        ]
        return video_urls
    except Exception as e:
        print(f"Error fetching latest videos: {e}")
        return []


def update_videos():
    global latest_videos
    channel_id = get_channel_id_from_name(STATIC_CHANNEL_NAME)
    if channel_id:
        latest_videos = get_latest_videos(YOUTUBE_API_KEY, channel_id)


# Scheduler to update the videos every 48 hours
scheduler = BackgroundScheduler()
scheduler.add_job(func=update_videos, trigger="interval", hours=48)
scheduler.start()


@app.route('/videos', methods=['GET'])
def get_videos():
    return jsonify(latest_videos)


if __name__ == '__main__':
    update_videos()  # Initial update on startup
    app.run(debug=True)
