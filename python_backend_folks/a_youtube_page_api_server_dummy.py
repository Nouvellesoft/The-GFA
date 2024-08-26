import json
import requests
from google.cloud import firestore
from datetime import datetime, timedelta

# Configuration
YOUTUBE_API_KEY = 'AIzaSyD5QDjHfD-7WIhmoMmhDAT_57NnbLc1rPk'
# Firestore Project ID
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


def get_latest_videos_from_youtube(api_key, channel_id, max_results=10):
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
    doc_path = get_firestore_document_path(club_id)
    doc_ref = db.document(doc_path)

    doc = doc_ref.get()
    if doc.exists:
        data = doc.to_dict()
        last_updated = data.get('last_updated')
        if last_updated and datetime.utcnow() - last_updated < timedelta(days=7):
            return data.get('videos', [])
    return []


def get_firestore_document_path(club_id):
    """Generate the Firestore document path for cached videos."""
    return f"clubs/{club_id}/about_club/youtube_data/cached_videos"


def save_videos_to_firestore(club_id, videos):
    """Save the latest video data to Firestore."""
    doc_path = get_firestore_document_path(club_id)
    doc_ref = db.document(doc_path)

    # Save videos with timestamp
    doc_ref.set({
        'videos': videos,
        'last_updated': datetime.utcnow()
    })


def fetch_and_cache_youtube_videos(request):
    """HTTP function to get YouTube videos based on channel name."""
    request_json = request.get_json(silent=True)

    if not request_json or 'club_id' not in request_json or 'channel_name' not in request_json:
        return json.dumps({"error": "Missing club_id or channel_name parameter"}), 400

    club_id = request_json['club_id']
    channel_name = request_json['channel_name']

    # Check Firestore for cached videos
    cached_videos = get_cached_videos_from_firestore(club_id)
    if cached_videos:
        return json.dumps(cached_videos), 200

    # Convert channel name to channel ID
    channel_id = get_channel_id_from_name(channel_name)
    if not channel_id:
        return json.dumps({"error": "Channel not found"}), 404

    # Fetch and return the latest videos
    videos = get_latest_videos_from_youtube(YOUTUBE_API_KEY, channel_id)
    if videos:
        save_videos_to_firestore(club_id, videos)
        return json.dumps(videos), 200
    else:
        return json.dumps({"error": "No videos found"}), 404
