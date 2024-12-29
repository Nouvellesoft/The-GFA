import os
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask, jsonify
import requests
from google.cloud import firestore
from datetime import datetime, timedelta
import pytz

app = Flask(__name__)


# Get root directory path and load .env
root_dir = Path(__file__).resolve().parents[2]
env_path = os.path.join(root_dir, '.env')
load_dotenv(env_path)

# Initialize key
YOUTUBE_API_KEY = os.getenv('YOUTUBE_API_KEY')

FIRESTORE_PROJECT_ID = 'the-gfa'

# Initialize Firestore
db = firestore.Client(project=FIRESTORE_PROJECT_ID)


def get_channel_id_from_name(channel_name):
    """Fetch the YouTube Channel ID from a given channel name."""
    try:
        url = (
            f"https://www.googleapis.com/youtube/v3/search?part=snippet"
            f"&q={channel_name}&type=channel&key={YOUTUBE_API_KEY}"
        )
        response = requests.get(url)
        data = response.json()
        channels = data.get('items', [])
        if channels:
            return channels[0]['id']['channelId']  # Extract the channel ID
        return None
    except Exception as e:
        print(f"Error fetching channel ID for name {channel_name}: {e}")
        return None


def get_latest_videos(api_key, channel_id, max_results=10):
    """Fetch the latest videos from a given YouTube channel ID."""
    try:
        url = (
            f"https://www.googleapis.com/youtube/v3/search?key={api_key}"
            f"&channelId={channel_id}&part=snippet,id&order=date&maxResults={max_results}"
        )
        response = requests.get(url)
        videos = response.json().get('items', [])
        video_data = []
        for video in videos:
            if video['id']['kind'] == 'youtube#video':
                video_data.append({
                    'url': f"https://www.youtube.com/watch?v={video['id']['videoId']}",
                    'title': video['snippet']['title']
                })
        return video_data
    except Exception as e:
        print(f"Error fetching latest videos: {e}")
        return []


def get_cached_videos_from_firestore(club_id):
    """Fetch cached video data from Firestore if it's less than 7 days old."""
    doc_ref = (db.collection('clubs').document(club_id)
               .collection('Youtube').document('latest_videos'))
    doc = doc_ref.get()
    if doc.exists:
        data = doc.to_dict()
        last_updated = data.get('last_updated')

        if isinstance(last_updated, datetime):
            if last_updated.tzinfo is None:
                last_updated = pytz.utc.localize(last_updated)
        else:
            last_updated = None

        if (last_updated and datetime.utcnow()
                .astimezone(pytz.utc) - last_updated < timedelta(days=7)):
            return data.get('videos', [])
    return []


def save_videos_to_firestore(club_id, videos):
    """Save the latest video data to Firestore."""
    doc_ref = db.collection('clubs').document(club_id).collection('Youtube').document(
        'latest_videos')
    doc_ref.set({
        'videos': videos,
        'last_updated': datetime.utcnow().astimezone(pytz.utc)
    })


def get_videos(request):
    """HTTP endpoint to get YouTube videos based on club_id and channel_name."""
    request_json = request.get_json()

    if not request_json or 'club_id' not in request_json or 'channel_name' not in request_json:
        return jsonify({"error": "Missing club_id or channel_name parameter"}), 400

    club_id = request_json['club_id']
    channel_name = request_json['channel_name']

    cached_videos = get_cached_videos_from_firestore(club_id)
    if cached_videos:
        return jsonify(cached_videos), 200

    channel_id = get_channel_id_from_name(channel_name)
    if not channel_id:
        return jsonify({"error": "Channel not found"}), 404

    videos = get_latest_videos(YOUTUBE_API_KEY, channel_id)
    if videos:
        save_videos_to_firestore(club_id, videos)
        return jsonify(videos), 200
    else:
        return jsonify({"error": "No videos found"}), 404
