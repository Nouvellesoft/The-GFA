import json
import requests

# Configuration
YOUTUBE_API_KEY = 'AIzaSyD5QDjHfD-7WIhmoMmhDAT_57NnbLc1rPk'


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


def get_videos(request):
    """HTTP function to get YouTube videos based on channel name."""
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'channel_name' in request_json:
        channel_name = request_json['channel_name']
    elif request_args and 'channel_name' in request_args:
        channel_name = request_args['channel_name']
    else:
        return json.dumps({"error": "Missing channel_name parameter"}), 400

    # Convert channel name to channel ID
    channel_id = get_channel_id_from_name(channel_name)

    if not channel_id:
        return json.dumps({"error": "Channel not found"}), 404

    # Fetch and return the latest videos
    videos = get_latest_videos(YOUTUBE_API_KEY, channel_id)
    return json.dumps(videos), 200
