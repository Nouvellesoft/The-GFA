import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/b_youtube_api.dart';
import '../../api/get_club_aspect_visibility_api.dart';
import '../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../notifier/a_club_global_notifier.dart';
import '../../notifier/b_youtube_notifier.dart';

Color splashColor = const Color.fromRGBO(98, 98, 213, 1.0);
Color backgroundColor = const Color.fromRGBO(147, 165, 193, 1.0);

class MyYouTubePage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyYouTubePage({super.key, required this.clubId});

  @override
  State<MyYouTubePage> createState() => MyYouTubePageState();
}

class MyYouTubePageState extends State<MyYouTubePage> {
  String clubYoutubeChannelIDName = '';
  bool _isLoading = true; // Track loading state
  bool _isVideoTitleVisible = true; // Track visibility of video titles

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      YouTubeNotifier youTubeNotifier = Provider.of<YouTubeNotifier>(context, listen: false);

      // Check if the data needs to be refreshed
      await checkAndUpdateVideos(widget.clubId);

      // Fetch YouTube data
      await getYouTube(youTubeNotifier, widget.clubId);

      // Fetch visibility data
      await _fetchVisibilityData(widget.clubId);

      // Update loading state
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clubYoutubeChannelIDName = Provider.of<ClubGlobalProvider>(context).clubYID;
  }

  Future<void> checkAndUpdateVideos(String clubId) async {
    final encodedChannelName = Uri.encodeComponent(clubYoutubeChannelIDName);
    const url = 'https://us-central1-the-gfa.cloudfunctions.net/youtube-posts-function';

    try {
      // Check Firestore for cached videos
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('clubs').doc(clubId).collection('Youtube').doc('latest_videos');
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        final lastUpdated = (data?['last_updated'] as Timestamp?)?.toDate();
        if (lastUpdated != null && DateTime.now().difference(lastUpdated).inDays < 7) {
          // Use cached data
          if (kDebugMode) {
            print('Using cached data from Firestore');
          }
          // Update your UI or state based on cached data
          return;
        }
      }

      // Fetch new data if cache is outdated or does not exist
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'club_id': clubId,
          'channel_name': encodedChannelName,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully fetched and updated videos
        if (kDebugMode) {
          print('Videos updated: ${response.body}');
        }
        // Update Firestore with new data
        await docRef.set({
          'videos': json.decode(response.body),
          'last_updated': DateTime.now().toUtc(),
        });
      } else {
        // Handle error status
        if (kDebugMode) {
          print('Failed to update videos: ${response.body}');
        }
      }
    } catch (e) {
      // Handle exceptions
      if (kDebugMode) {
        print('Error checking/updating videos: $e');
      }
    }
  }

  Future<void> launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("The required app is not installed")));
    }
  }

  Future<void> _fetchVisibilityData(String clubId) async {
    try {
      final visibilityData = await getClubAspectVisibilityAndTitles(clubId);
      setState(() {
        _isVideoTitleVisible = visibilityData['a_youtube_title']?['isVisible'] ?? true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching visibility data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    YouTubeNotifier youTubeNotifier = Provider.of<YouTubeNotifier>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : youTubeNotifier.youTubeList.isEmpty
                ? const Center(
                    child: Text(
                      'No videos available.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: youTubeNotifier.youTubeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final video = youTubeNotifier.youTubeList[index];
                      final url = video.toastURL;
                      final title = video.title;

                      // Extract video ID from URL if needed
                      final videoId = Uri.parse(url ?? '').queryParameters['v'] ?? '';

                      return InkWell(
                        splashColor: splashColor,
                        onTap: () => launchURL(url ?? ''),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.25,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider('https://img.youtube.com/vi/$videoId/0.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (_isVideoTitleVisible) // Conditionally render text
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width * 0.6,
                                      color: Colors.black54, // Optional background for text visibility
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        title ?? 'No Title',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
