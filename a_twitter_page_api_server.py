from flask import Flask, jsonify, request
from apscheduler.schedulers.background import BackgroundScheduler
from google.cloud import firestore
import requests

app = Flask(__name__)
db = firestore.Client()
YOUTUBE_API_KEY = 'AIzaSyD5QDjHfD-7WIhmoMmhDAT_57NnbLc1rPk'
latest_videos_dict = {}


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
            return channels[0]['id']
        return None
    except Exception as e:
        print(f"Error fetching channel ID for name {channel_name}: {e}")
        return None


def get_channel_id(club_id):
    try:
        about_club_ref = (db.collection('clubs').document(club_id)
                          .collection('AboutClub').document('about_club_page'))
        doc = about_club_ref.get()
        if doc.exists:
            youtube_name = doc.to_dict().get('youtube_name')
            print(f"Fetched youtube_name for club {club_id}: {youtube_name}")  # Debug print
            if youtube_name:
                return get_channel_id_from_name(youtube_name)
        return None
    except Exception as e:
        print(f"Error fetching channel ID for club {club_id}: {e}")
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


def update_videos_for_club(club_id):
    channel_id = get_channel_id(club_id)
    if channel_id:
        latest_videos_dict[club_id] = get_latest_videos(YOUTUBE_API_KEY, channel_id)


def get_all_club_ids():
    try:
        clubs_ref = db.collection('clubs')
        docs = clubs_ref.stream()
        return [doc.id for doc in docs]
    except Exception as e:
        print(f"Error fetching club IDs: {e}")
        return []


def schedule_updates_for_clubs():
    club_ids = get_all_club_ids()
    for club_id in club_ids:
        scheduler.add_job(func=update_videos_for_club, trigger="interval", hours=48, args=[club_id])


# Scheduler to update the videos for all known clubs every 48 hours
scheduler = BackgroundScheduler()
schedule_updates_for_clubs()
scheduler.start()


@app.route('/videos', methods=['GET'])
def get_videos():
    club_id = request.args.get('clubId')
    if not club_id:
        return jsonify({'error': 'Club ID is required'}), 400

    videos = latest_videos_dict.get(club_id)
    if videos is None:
        # Update videos if they haven't been fetched yet
        update_videos_for_club(club_id)
        videos = latest_videos_dict.get(club_id, [])

    print(f"Responding with videos: {videos}")  # Add this line to log the response
    return jsonify(videos)


if __name__ == '__main__':
    app.run(debug=True)
