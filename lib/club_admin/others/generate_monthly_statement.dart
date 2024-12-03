import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../notifier/coaches_reviews_comment_notifier.dart';
import '../../notifier/founders_reviews_comment_notifier.dart';
import '../../notifier/most_fouled_rc_players_stats_info_notifier.dart';
import '../../notifier/most_fouled_yc_players_stats_info_notifier.dart';
import '../../notifier/player_of_the_month_stats_info_notifier.dart';

String clubName = "";
String rawClubName = "";
String clubLogo = "";

class GenerateMonthlyStatementA4LayoutScreen extends StatefulWidget {
  final String clubId;
  const GenerateMonthlyStatementA4LayoutScreen({super.key, required this.clubId});

  @override
  State<StatefulWidget> createState() => GenerateMonthlyStatementA4LayoutScreenState();
}

class GenerateMonthlyStatementA4LayoutScreenState extends State<GenerateMonthlyStatementA4LayoutScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStreamTwo;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscription;

  late PlayerOfTheMonthStatsAndInfoNotifier playerOfTheMonthStatsAndInfoNotifier;

  @override
  Widget build(BuildContext context) {
    MostFouledYCPlayersStatsAndInfoNotifier mostFouledYCPlayersStatsAndInfoNotifier =
        Provider.of<MostFouledYCPlayersStatsAndInfoNotifier>(context, listen: true);

    MostFouledRCPlayersStatsAndInfoNotifier mostFouledRCPlayersStatsAndInfoNotifier =
        Provider.of<MostFouledRCPlayersStatsAndInfoNotifier>(context, listen: true);

    playerOfTheMonthStatsAndInfoNotifier = Provider.of<PlayerOfTheMonthStatsAndInfoNotifier>(context);

    CoachesReviewsCommentNotifier coachesReviewsCommentNotifier = Provider.of<CoachesReviewsCommentNotifier>(context);

    FoundersReviewsCommentNotifier foundersReviewsCommentNotifier = Provider.of<FoundersReviewsCommentNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey.withOpacity(0.8),
      appBar: AppBar(
        title: const Text('Monthly Statement'),
        backgroundColor: Colors.white70,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 210 / 297, // A4 aspect ratio
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 44, // 44% of the page height
                        child: Stack(
                          children: [
                            // Background Image with dynamic color filter
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/monthly_report_image_1.png'), // Replace with your image asset
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5), // Dim the background to make the main character stand out more
                                    BlendMode.darken, // Darkens the background
                                  ),
                                ),
                              ),
                            ),
                            // Profile Picture Segment
                            Positioned(
                              bottom: -20, // Align with the bottom of the parent
                              right: 20, // Slight offset from the right
                              child: Transform(
                                alignment: Alignment.bottomCenter, // Rotate around the bottom center
                                transform: Matrix4.identity()..rotateZ(-0.1), // Rotate counterclockwise (-ve for left tilt, +ve for right tilt)
                                child: Container(
                                  width: 100, // Width of the profile picture
                                  height: 140, // Height of the profile picture
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14), // Rounded corners
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2), // Subtle shadow
                                        blurRadius: 6,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.7), // White border around the image
                                      width: 9, // Border thickness
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10), // Match the top corners
                                    ),
                                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: firestoreStreamTwo,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        }
                                        if (!snapshot.hasData || snapshot.data?.data() == null) {
                                          return Image.asset(
                                            'assets/images/no_opp_club_image.jpg', // Fallback image if data is missing
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        // Use the fetched image URL from Firestore
                                        String imageUrl = snapshot.data!.data()!['slivers_page_7'] ?? '';
                                        if (imageUrl.isEmpty) {
                                          return Image.asset(
                                            'assets/images/no_opp_club_image.jpg', // Fallback if URL is empty
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        // Wrap the image with ColorFiltered to reduce brightness
                                        return ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.3), // Apply dark overlay to reduce brightness
                                            BlendMode.darken, // Darkens the image
                                          ),
                                          child: Transform.scale(
                                            scale: 2.1, // Adjust this value to zoom out (less than 1 will zoom out)
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover, // Keep the image coverage as before
                                              placeholder: (context, url) => CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Section taking 50% of the page
                      Expanded(
                        flex: 52,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 16, top: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header Section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Image from network inside a small container
                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: firestoreStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else {
                                          return Container(
                                            width: 66, // Set the width of the container
                                            height: 66, // Set the height of the container (same size as the icon)
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: CachedNetworkImageProvider(
                                                  clubLogo,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(8), // Optional: add rounded corners if needed
                                            ),
                                          );
                                        }
                                      }),
                                  const SizedBox(width: 15),
                                  RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      children: [
                                        // First part of the club name
                                        TextSpan(
                                          text: clubName.split('\n')[0], // The first line (e.g., 'Coventry Phoenix')
                                          style: TextStyle(
                                            fontSize: 14, // Smaller size for the first part
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\n${clubName.split('\n')[1]}', // The second line ('Football Club')
                                          style: TextStyle(
                                            fontSize: 26, // Bigger size for 'Football Club'
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 34),
                              // Statement Title
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 30, // Default font size for the first part
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Default text color
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${DateFormat('MMMM').format(DateTime.now())} 2024', // The first part
                                      style: TextStyle(
                                        fontSize: 25, // First part size
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nClub Report', // The second part
                                      style: TextStyle(
                                        fontSize: 40, // Bigger size for 'Club Report'
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 44),
                              // Details Section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Prepared by',
                                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                                      ),
                                      const Text(
                                        'The GFA App',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      const Text(
                                        'Nouvellesoft Inc.',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 70),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Prepared for',
                                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800),
                                      ),
                                      const Text(
                                        'Club Admin Team',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        rawClubName,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Section with dark background
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: Colors.black, // Dark background
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'The GFA App',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Monthly Performance Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 210 / 297, // A4 aspect ratio
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // The main content of the page
                      Expanded(
                        flex: 1, // This takes most of the page space
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.white), // Background
                            ),
                            // Draw ruler lines
                            CustomPaint(
                              size: Size(double.infinity, double.infinity),
                              painter: RulerPainter(),
                            ),
                            // Rectangle at the top-right corner
                            Positioned(
                              right: 0, // Adjust space from the right edge
                              top: 60, // Adjust space from the top
                              child: Container(
                                width: 60, // Adjust the width of the rectangle
                                height: 100, // Adjust the height to be longer than the width
                                color: Colors.brown.withOpacity(0.7), // Choose a color for the rectangle
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Table:', // Regular text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 12, // Smaller font for the label
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '5th', // Big text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 26, // Large font size
                                        fontWeight: FontWeight.w800, // Bold for emphasis
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Text(
                                    //   'position', // Regular text
                                    //   style: TextStyle(
                                    //     color: Colors.white, // Text color
                                    //     fontSize: 11, // Smaller font for the label
                                    //     fontWeight: FontWeight.w700,
                                    //   ),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              left: (MediaQuery.of(context).size.width - (100 + 10 + 150)) / 2, // Centers horizontally
                              top: (297 * (MediaQuery.of(context).size.width / 210)) / 2 - 50, // Centers vertically
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // PieChart
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            color: Colors.indigo,
                                            value: 30,
                                            showTitle: false, // No text on the chart
                                          ),
                                          PieChartSectionData(
                                            color: Colors.orange,
                                            value: 50,
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            color: Colors.teal,
                                            value: 20,
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            color: Colors.red,
                                            value: 20,
                                            showTitle: false,
                                          ),
                                        ],
                                        centerSpaceRadius: 0,
                                        sectionsSpace: 4,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // Legend
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Matches Played: 17', // Show number of matches played
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.indigo,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Matches Won: 10', // Show number of matches won
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.red, // You can choose a different color for this
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Matches Lost: 7', // Show number of matches lost
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.teal,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Goals Scored: 7', // Show number of goals scored
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Top 5 Goal Scorers Section
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('clubs')
                                  .doc(widget.clubId)
                                  .collection('PllayersTable')
                                  .orderBy('goals_scored', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                var players = snapshot.data!.docs;
                                return Positioned(
                                  left: 30,
                                  top: 30, // Space from the top
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Heading for top 5 goal scorers
                                      const Text(
                                        'Top 5 Goal Scorers:',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      // No. 1 player with circular image
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: CachedNetworkImageProvider(players[0]['image']), // Fetch player 1 image
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '1. ${players[0]['player_name']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Matches Played: ${players[0]['matches_played']}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                'Goals: ${players[0]['goals_scored']}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      // Remaining players
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 1; i < players.length && i < 5; i++) ...[
                                            Text(
                                              '${i + 1}. ${players[i]['player_name']} - Goals: ${players[i]['goals_scored']}, Matches Played: ${players[i]['matches_played']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            SizedBox(height: 5),
                                          ]
                                        ],
                                      ),
                                      SizedBox(height: 30), // Add spacing before the next section
                                    ],
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('clubs')
                                  .doc(widget.clubId)
                                  .collection('PastMatches')
                                  .orderBy('id', descending: false) // Sort matches by most recent date
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                var matches = snapshot.data!.docs;
                                return Positioned(
                                  left: 30,
                                  bottom: 30, // Position near the bottom
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Heading for Past 5 Matches
                                      const Text(
                                        'Past 5 Matches:',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      // List of past matches
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0; i < matches.length && i < 5; i++) ...[
                                            Text(
                                              '${i + 1}. ${matches[i]['home_team']} ${matches[i]['ht_score']} - ${matches[i]['at_score']} ${matches[i]['away_team']} - (${matches[i]['match_date']})',
                                              style: TextStyle(fontSize: 9),
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Footer
                      Container(
                        height: 14, // Fixed height for the footer
                        color: Colors.brown, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                      ),
                      // Another footer container
                      Container(
                        height: 25, // Fixed height for the footer
                        color: Colors.black, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'The GFA App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Monthly Performance Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 210 / 297, // A4 aspect ratio
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // The main content of the page
                      Expanded(
                        flex: 1, // This takes most of the page space
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.white), // Background
                            ),
                            // Draw ruler lines
                            CustomPaint(
                              size: Size(double.infinity, double.infinity),
                              painter: RulerPainter(),
                            ),
                            // Rectangle at the top-right corner
                            Positioned(
                              right: 0, // Aligns to the right edge
                              top: (297 * (MediaQuery.of(context).size.width / 210)) / 2 - 50, // Centers vertically within the A4 aspect ratio
                              child: Container(
                                width: 60, // Adjust the width of the rectangle
                                height: 100, // Adjust the height to be longer than the width
                                color: Colors.brown.withOpacity(0.7), // Choose a color for the rectangle
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Table:', // Regular text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 12, // Smaller font for the label
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '5th', // Big text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 26, // Large font size
                                        fontWeight: FontWeight.w800, // Bold for emphasis
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30, // Adjust the left position for center alignment
                              top: (297 * (MediaQuery.of(context).size.width / 210)) / 2 - 50, // Centers vertically
                              child: Container(
                                width: 300, // Adjust the width as needed
                                height: 100, // Adjust the width as needed
                                padding: EdgeInsets.all(8), // Add padding around the text
                                color: Colors.blueGrey.withOpacity(0.8), // Set the container color with opacity
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stats Summary:', // Title for the summary section
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    AutoSizeText(
                                      'This season, the team has shown impressive performance. With a total of 12 matches played, the team has secured 8 victories, scoring 18 goals. Despite a few setbacks, including 4 losses, the squad has been putting up a great fight, showing resilience in each game. Key players have been performing excellently, with David leading the assists leaderboard, contributing 15 assists in 13 matches.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.justify,
                                      maxLines: 5, // Allow text to wrap into 5 lines if needed
                                      minFontSize: 8, // Minimum font size to ensure readability
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Top 5 Goal Assists Section
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('clubs')
                                  .doc(widget.clubId)
                                  .collection('PllayersTable')
                                  .orderBy('assists', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                var players = snapshot.data!.docs;
                                return Positioned(
                                  left: 30,
                                  top: 30, // Space from the top
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Heading for Top 5 Assist Players
                                      const Text(
                                        'Top 5 Assist Players:',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      // No. 1 player with circular image
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: CachedNetworkImageProvider(players[0]['image']), // Fetch player 1 image
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '1. ${players[0]['player_name']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Matches Played: ${players[0]['matches_played']}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                'Assists: ${players[0]['assists']}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      // Remaining assist players
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 1; i < players.length && i < 5; i++) ...[
                                            Text(
                                              '${i + 1}. ${players[i]['player_name']} - Assists: ${players[i]['assists']}, Matches Played: ${players[i]['matches_played']}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            SizedBox(height: 5),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('clubs')
                                  .doc(widget.clubId)
                                  .collection('UpcomingMatches')
                                  .orderBy('id', descending: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                var matches = snapshot.data!.docs;
                                return Positioned(
                                  left: 30,
                                  bottom: 30, // Position near the bottom
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Heading for Upcoming Matches
                                      const Text(
                                        'Upcoming Matches:',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      // List of upcoming matches
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0; i < matches.length && i < 5; i++) ...[
                                            Row(
                                              children: [
                                                Text(
                                                  '${i + 1}. ${matches[i]['home_team']} vs ${matches[i]['away_team']}:',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  '(${DateFormat('dd-MM-yyyy HH:mm').format(
                                                    DateFormat('dd-MM-yyyy HH:mm:ss').parse(matches[i]['match_date']),
                                                  )})',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Footer
                      Container(
                        height: 14, // Fixed height for the footer
                        color: Colors.brown, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                      ),
                      // Another footer container
                      Container(
                        height: 25, // Fixed height for the footer
                        color: Colors.black, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'The GFA App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Monthly Performance Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 210 / 297, // A4 aspect ratio
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // The main content of the page
                      Expanded(
                        flex: 1, // This takes most of the page space
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.white), // Background
                            ),
                            // Draw ruler lines
                            CustomPaint(
                              size: Size(double.infinity, double.infinity),
                              painter: RulerPainter(),
                            ),
                            // Rectangle at the top-right corner
                            Positioned(
                              right: 0, // Aligns to the right edge
                              bottom: 40,
                              child: Container(
                                width: 60, // Adjust the width of the rectangle
                                height: 100, // Adjust the height to be longer than the width
                                color: Colors.brown.withOpacity(0.7), // Choose a color for the rectangle
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Table:', // Regular text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 12, // Smaller font for the label
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '5th', // Big text
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 26, // Large font size
                                        fontWeight: FontWeight.w800, // Bold for emphasis
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              bottom: 40,
                              child: Container(
                                width: 300, // Adjust the width as needed
                                height: 100, // Adjust the width as needed
                                padding: EdgeInsets.all(8), // Add padding around the text
                                color: Colors.blueGrey.withOpacity(0.8), // Set the container color with opacity
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upcoming Matches Suggestions:', // Updated title for the suggestions section
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(height: 10),
                                    AutoSizeText(
                                      'To improve our chances in upcoming games, the following strategies are recommended: Focus on building team cohesion during training sessions, especially in midfield transitions. Encourage players to maintain possession and minimize turnovers. For the next game, consider rotating the squad to keep key players rested while giving younger players more experience. Target key opposition weaknesses, such as their lack of pace in defense, by emphasizing counterattacks. Lastly, reinforce discipline to avoid unnecessary cards, which have cost the team valuable points this season.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.justify,
                                      maxLines: 5, // Allow text to wrap into 5 lines if needed
                                      minFontSize: 8, // Minimum font size to ensure readability
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0, // To center the content horizontally
                              right: 0,
                              top: 30, // Space from the top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Heading for "Other Club Summary"
                                  Center(
                                    child: const Text(
                                      'Other Club Summary',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Horizontal row for the cards
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('PllayersTable').snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      // Filter for MVP player
                                      final mvpPlayers = snapshot.data!.docs.where(
                                        (doc) => (doc.data()['player_of_the_month'] ?? '').toString().toLowerCase() == 'yes',
                                      );

                                      if (mvpPlayers.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          child: Text(
                                            'No MVP selected for this month.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }

                                      // Get the first matching MVP player
                                      var mvpPlayer = mvpPlayers.first;
                                      var mvpData = mvpPlayer.data();

                                      // Display MVP data
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30),
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.withOpacity(0.3),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Month of ${DateFormat('MMMM').format(DateTime.now())} MVP',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white30,
                                                      image: DecorationImage(
                                                        image: NetworkImage(mvpData['image'] ?? ''),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 20),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                mvpData['player_name'] ?? 'Unknown Player',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                              SizedBox(height: 4),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Matches Played: ${mvpData['matches_played'] ?? 0}',
                                                                    style: TextStyle(
                                                                      color: Colors.grey[600],
                                                                      fontSize: 9,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 2),
                                                                  Text(
                                                                    'Goals Scored: ${mvpData['goals_scored'] ?? 0}',
                                                                    style: TextStyle(
                                                                      color: Colors.grey[600],
                                                                      fontSize: 9,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 2),
                                                                  Text(
                                                                    'Assists Made: ${mvpData['assists'] ?? 0}',
                                                                    style: TextStyle(
                                                                      color: Colors.grey[600],
                                                                      fontSize: 9,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('clubs')
                                        .doc(widget.clubId)
                                        .collection('PllayersTable') // Fixed typo: 'PllayersTable' to 'PlayersTable'
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      // Loop through the players and sum up the yellow and red cards
                                      int totalYellowCards = 0;
                                      int totalRedCards = 0;

                                      for (var doc in snapshot.data!.docs) {
                                        totalYellowCards += (doc['yellow_card'] as num?)?.toInt() ?? 0;
                                        totalRedCards += (doc['red_card'] as num?)?.toInt() ?? 0;
                                      }

                                      // Now totalYellowCards and totalRedCards should have the correct summed values

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Yellow Card Display
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow.withOpacity(0.3),
                                              border: Border.all(
                                                color: Colors.grey, // Border color
                                                width: 1.5, // Border width
                                              ),
                                              borderRadius: BorderRadius.circular(2), // Optional: Add rounded corners
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    border: Border.all(
                                                      color: Colors.black, // Border color
                                                      width: 1.5, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Text('Yellow Cards So Far',
                                                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)),
                                                    Text(
                                                      '$totalYellowCards', // Display dynamic yellow card total
                                                      style: TextStyle(fontSize: 24, color: Colors.black54, fontWeight: FontWeight.w800),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Red Card Display
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.3),
                                              border: Border.all(
                                                color: Colors.grey, // Border color
                                                width: 1.5, // Border width
                                              ),
                                              borderRadius: BorderRadius.circular(2), // Optional: Add rounded corners
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    border: Border.all(
                                                      color: Colors.black, // Border color
                                                      width: 1.5, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Text('Red Cards So Far',
                                                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)),
                                                    Text(
                                                      '$totalRedCards', // Display dynamic red card total
                                                      style: TextStyle(fontSize: 24, color: Colors.black54, fontWeight: FontWeight.w800),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('clubs')
                                        .doc(widget.clubId)
                                        .collection('CoachesMonthlyComments')
                                        .orderBy('date', descending: true) // Order by date, with the most recent ones first
                                        .limit(3) // Limit to the most recent 2 comments
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      // Loop through the fetched documents and display the comments
                                      return SizedBox(
                                        height: 140,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Coaches comments section header
                                              const Text(
                                                'Coaches Comments',
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 2),

                                              // Loop through the documents and display the coach comments dynamically
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: snapshot.data!.docs.map((doc) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 7),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // Coach's name and comment
                                                        Text.rich(
                                                          TextSpan(
                                                            text: '${doc['name']}: ', // Coach's name
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 10,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: doc['comment'], // Coach's comment
                                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                                              ),
                                                            ],
                                                          ),
                                                          textAlign: TextAlign.justify, // Justify the text
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Footer
                      Container(
                        height: 14, // Fixed height for the footer
                        color: Colors.brown, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                      ),
                      // Another footer container
                      Container(
                        height: 25, // Fixed height for the footer
                        color: Colors.black, // Dark background
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'The GFA App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Monthly Performance Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    firestoreStream = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('AboutClub')
        .doc('about_club_page')
        .snapshots()
        .distinct(); // Ensure distinct events

    firestoreStreamTwo = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('SliversPages')
        .doc('slivers_pages')
        .snapshots()
        .distinct(); // Ensure distinct events

    streamSubscription = firestoreStream.listen((snapshot) {
      var data = snapshot.data()!;
      setState(() {
        rawClubName = data['club_name'] ?? "";
        String unRawedClubName = data['club_name'] ?? "";
        clubLogo = data['club_logo'];

        // Replace 'FC' with 'Football Club' and remove standalone instances
        unRawedClubName = unRawedClubName.replaceAll(RegExp(r'\b(Football Club|FC)\b', caseSensitive: false), '').trim();

        // Format club name into multiple lines, ensuring it ends with 'Football Club'
        List<String> nameParts = unRawedClubName.split(' ');
        if (nameParts.length > 1) {
          String firstLine = nameParts.sublist(0, nameParts.length - 1).join(' '); // All except the last word
          String lastWord = nameParts.last; // Last word
          clubName = "$firstLine $lastWord\nFootball Club";
        } else {
          clubName = "$unRawedClubName\nFootball Club"; // For single-word names
        }
      });
    });
  }
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    // Top horizontal line (slightly inset from top-left corner)
    canvas.drawLine(Offset(20, 20), Offset(size.width, 20), paint);

    // Left vertical line (slightly inset from top-left corner)
    canvas.drawLine(Offset(20, 0), Offset(20, size.height - 20), paint);

    // Diagonal line crossing the top-left corner (a bit inset from edges)
    // canvas.drawLine(Offset(10, 20), Offset(size.width - 20, size.height - 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
