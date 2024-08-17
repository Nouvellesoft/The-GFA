import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../bloc_navigation_bloc/navigation_bloc.dart';

class MyYouTubePage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyYouTubePage({super.key, required this.clubId});

  @override
  State<MyYouTubePage> createState() => MyYouTubePageState();
}

class MyYouTubePageState extends State<MyYouTubePage> {
  late List<String> _videoUrls;

  @override
  void initState() {
    super.initState();
    _videoUrls = [];
    _fetchYoutubeVideos();
  }

  Future<void> _fetchYoutubeVideos() async {
    final url = Uri.parse('http://localhost:5000/videos'); // Replace with your server's IP/hostname if needed

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> videoList = jsonDecode(response.body);
        setState(() {
          _videoUrls = List<String>.from(videoList);
        });
      } else {
        // Handle server errors
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      // Handle network errors
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("The required App not installed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _videoUrls.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _videoUrls.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    splashColor: Colors.blue,
                    onTap: () {
                      launchURL(_videoUrls[index]);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: MediaQuery.of(context).size.height * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                'https://img.youtube.com/vi/${Uri.parse(_videoUrls[index]).queryParameters['v']}/0.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
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
