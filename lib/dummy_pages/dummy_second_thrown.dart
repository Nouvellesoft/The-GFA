// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:the_gfa/sidebar/sidebar_layout.dart';
// import 'package:video_player/video_player.dart';
//
// import '../api/all_clubs_api.dart';
// import '../home_page/home_page_deux.dart';
//
// class ClubSelectionPage extends StatefulWidget {
//   const ClubSelectionPage({super.key});
//
//   @override
//   State<ClubSelectionPage> createState() => ClubSelectionPageState();
// }
//
// class ClubSelectionPageState extends State<ClubSelectionPage> with TickerProviderStateMixin {
//   late VideoPlayerController _controller;
//   bool _isVideoInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//     _checkSelectedClub();
//   }
//
//   void _initializeVideoPlayer() async {
//     try {
//       _controller = VideoPlayerController.asset('assets/videos/car_intro_background_1.mov')..setLooping(true);
//       await _controller.initialize();
//       _controller.play();
//       setState(() {
//         _isVideoInitialized = true;
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error initializing video player: $e');
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _checkSelectedClub() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? clubId = prefs.getString('selectedClub');
//
//     if (clubId != null) {
//       if (clubId == 'coventryphoenixfc') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => PandCTransitions(clubId: clubId)),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SideBarLayout(clubId: clubId)),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Fallback color
//       body: Stack(
//         children: [
//           if (_controller.value.isInitialized)
//             Positioned.fill(
//               child: AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               ),
//             )
//           else
//             const Center(child: CircularProgressIndicator()), // Show a loader until video initializes
//           // Your main content goes here
//           Center(
//             child: FutureBuilder<List<String>>(
//               future: getClubs(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error fetching clubs: ${snapshot.error}');
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Text('No clubs found');
//                 } else {
//                   List<String> clubs = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: clubs.length,
//                     itemBuilder: (context, index) {
//                       var clubId = clubs[index];
//                       return ListTile(
//                         title: Text(
//                           clubId,
//                           style: const TextStyle(color: Colors.white), // Make text visible on video
//                         ),
//                         onTap: () async {
//                           // await saveSelectedClub(clubId);
//
//                           Fluttertoast.showToast(
//                             msg: "Welcome to $clubId!",
//                             toastLength: Toast.LENGTH_SHORT,
//                             gravity: ToastGravity.BOTTOM,
//                             backgroundColor: Colors.green,
//                             textColor: Colors.white,
//                             fontSize: 16.0,
//                           );
//
//                           if (clubId == 'coventryphoenixfc') {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (context) => PandCTransitions(clubId: clubId)),
//                             );
//                           } else {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (context) => SideBarLayout(clubId: clubId)),
//                             );
//                           }
//                         },
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
