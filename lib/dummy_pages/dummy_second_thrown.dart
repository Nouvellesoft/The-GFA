import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/b_youtube_api.dart';
import '/notifier/b_youtube_notifier.dart';
import '../../bloc_navigation_bloc/navigation_bloc.dart';

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
  late double width;
  late double height;

  Future launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("The required App not installed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    YouTubeNotifier youTubeNotifier = Provider.of<YouTubeNotifier>(context);
    return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
            child: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: youTubeNotifier.youTubeList.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  splashColor: splashColor,
                  onTap: () {
                    dynamic videoUrl = "https://www.youtube.com/watch?v=${youTubeNotifier.youTubeList[index].yid}";
                    launchURL(videoUrl);
                  },
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    //alignment: const Alignment(0, -1),
                                    image: CachedNetworkImageProvider('https://img.youtube.com/vi/${youTubeNotifier.youTubeList[index].yid!}/0.jpg'),
                                    fit: BoxFit.cover)),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ])));
  }

  Future<void> _fetchYoutubeVideosAndUpdateNotifier(YouTubeNotifier youTubeNotifier) async {
    await getYouTube(youTubeNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  @override
  void initState() {
    super.initState();

    YouTubeNotifier youTubeNotifier = Provider.of<YouTubeNotifier>(context, listen: false);
    _fetchYoutubeVideosAndUpdateNotifier(youTubeNotifier);
  }
}
