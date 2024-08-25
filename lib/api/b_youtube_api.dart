import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/b_youtube_model.dart';
import '../notifier/b_youtube_notifier.dart';

Future<void> getYouTube(YouTubeNotifier youTubeNotifier, String clubId) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('Youtube').doc('latest_videos').get();

    // Check if the document exists and has data
    if (snapshot.exists && snapshot.data() != null) {
      // Cast the data to a Map<String, dynamic>
      var data = snapshot.data() as Map<String, dynamic>?;

      // Safely access the 'videos' field
      var videosList = data?['videos'] as List<dynamic>?;

      if (videosList != null) {
        List<YouTube> youTubeList = [];

        for (var videoData in videosList) {
          var videoMap = videoData as Map<String, dynamic>;

          String? url = videoMap['url'] as String?;
          String? title = videoMap['title'] as String?;

          YouTube youTube = YouTube(toastURL: url, title: title);
          youTubeList.add(youTube);
        }

        youTubeNotifier.youTubeList = youTubeList;
      } else {
        // Handle the case where 'videos' list is null
        youTubeNotifier.youTubeList = [];
      }
    } else {
      // Handle the case where the document doesn't exist or has no data
      youTubeNotifier.youTubeList = [];
    }
  } catch (e) {
    // Handle any errors during the Firestore call
    if (kDebugMode) {
      print('Error fetching YouTube data: $e');
    }
    youTubeNotifier.youTubeList = [];
  }
}
