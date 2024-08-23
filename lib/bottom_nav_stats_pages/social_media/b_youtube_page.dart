import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../notifier/a_club_global_notifier.dart';

Color splashColor = const Color.fromRGBO(98, 98, 213, 1.0);
Color textColor = const Color.fromRGBO(222, 214, 214, 1.0);
Color textColorTwo = const Color.fromRGBO(19, 20, 21, 1.0);
Color dialogBackgroundColor = const Color.fromRGBO(238, 235, 235, 1.0);

Color conColor = const Color.fromRGBO(194, 194, 220, 1.0);
Color conColorTwo = const Color.fromRGBO(151, 147, 151, 1.0);
Color whiteColor = const Color.fromRGBO(255, 253, 253, 1.0);
Color twitterColor = const Color.fromRGBO(36, 81, 149, 1.0);
Color instagramColor = const Color.fromRGBO(255, 255, 255, 1.0);
Color facebookColor = const Color.fromRGBO(43, 103, 195, 1.0);
Color snapchatColor = const Color.fromRGBO(222, 163, 36, 1.0);
Color youtubeColor = const Color.fromRGBO(220, 45, 45, 1.0);
Color websiteColor = const Color.fromRGBO(104, 79, 178, 1.0);
Color emailColor = const Color.fromRGBO(230, 45, 45, 1.0);
Color phoneColor = const Color.fromRGBO(20, 134, 46, 1.0);
Color backgroundColor = const Color.fromRGBO(147, 165, 193, 1.0);

class MyYouTubePage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyYouTubePage({super.key, required this.clubId});

  @override
  State<MyYouTubePage> createState() => MyYouTubePageState();
}

class MyYouTubePageState extends State<MyYouTubePage> {
  List<Map<String, dynamic>> _videos = [];
  String clubYoutubeChannelIDName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clubYoutubeChannelIDName = Provider.of<ClubGlobalProvider>(context).clubYID;

    if (clubYoutubeChannelIDName.isNotEmpty) {
      _fetchYoutubeVideos();
    }
  }

  Future<void> _fetchYoutubeVideos() async {
    final url = Uri.parse('https://us-central1-the-gfa.cloudfunctions.net/youtube-posts-function?channel_name=$clubYoutubeChannelIDName');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> videoList = jsonDecode(response.body);
        setState(() {
          _videos = videoList
              .map((video) => {
                    'url': video['url'],
                    'title': video['title'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        _videos = [];
      });
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Internet is required to fetch YouTube videos. Please check your connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("The required app is not installed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _videos.isEmpty
            ? Center(
                child: _videos.isEmpty
                    ? const Text('Loading...') // You might want to show a loading indicator initially
                    : const Text('Internet is required to fetch YouTube videos.'),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final video = _videos[index];
                    final videoUrl = video['url']!;
                    final title = video['title']!;
                    return InkWell(
                      splashColor: Colors.blue,
                      onTap: () {
                        launchURL(videoUrl);
                      },
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
                                    image: CachedNetworkImageProvider(
                                      'https://img.youtube.com/vi/${Uri.parse(videoUrl).queryParameters['v']}/0.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.6,
                                  color: Colors.black54, // Optional background for text visibility
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    title,
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
      ),
    );
  }
}
