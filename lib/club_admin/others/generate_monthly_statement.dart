import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
                                      text: 'March 2024', // The first part
                                      style: TextStyle(
                                        fontSize: 25, // First part size
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nClub Report', // The second part
                                      style: TextStyle(
                                        fontSize: 40, // Bigger size for 'Club Report'
                                        fontWeight: FontWeight.w800, // Bold weight for 'Club Report'

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
                            Positioned(
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
                                        backgroundImage: AssetImage('assets/images/no_opp_club_image.jpg'),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Ayo Bamidele',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Matches Played: 13',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Goals: 12',
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
                                    children: const [
                                      Text(
                                        '2. Olu Sowunmi: Goals: 11, Matches Played: 11',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '3. Mark Black: Goals: 10, Matches Played: 12',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '4. Alice White: Goals: 9, Matches Played: 14',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '5. Jane Smith: Goals: 8, Matches Played: 15',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30), // Add spacing before the next section
                                ],
                              ),
                            ),
                            Positioned(
                              left: 30,
                              bottom: 30, // Space from the top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Past 5 Matches Section
                                  const Text(
                                    'Past 5 Matches:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  // Match 1
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        '1. Coventry Phoenix FC 2 - 1 Copswood FC - (11-03-2024)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '2. AFC Binley 3 - 2 Coventry Phoenix FC Thirds - (11-03-2024)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '3. Coventry Phoenix FC 1 - 0 Leamington FC - (11-03-2024)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '4. Coventry Phoenix FC 0 - 3 Southam United FC - (11-03-2024)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '5. Copswood FC 2 - 2 Coventry Phoenix FC - (11-03-2024)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
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
                            Positioned(
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
                                        backgroundImage: AssetImage('assets/images/no_opp_club_image.jpg'),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'David Ogundepo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Matches Played: 13',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            'Assists: 15',
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
                                    children: const [
                                      Text(
                                        '2. Joseph Shalipopi: Assists: 13, Matches Played: 11',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '3. Mark Black: Assists: 11, Matches Played: 12',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '4. Alice White: Assists: 10, Matches Played: 14',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '5. Jane Smith: Assists: 9, Matches Played: 15',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 30,
                              bottom: 30, // Space from the top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Heading for Upcoming Matches
                                  const Text(
                                    'Upcoming Matches:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  // Matches list
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '1. Coventry Phoenix FC vs Copswood FC:',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '(12-03-2024)',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '2. AFC Binley vs Coventry Phoenix FC:',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '(19-03-2024)',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '3. Leamington FC vs Coventry Phoenix FC:',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '(26-03-2024)',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '4. Coventry Phoenix FC vs Southam United FC:',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '(02-04-2024)',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            '5. Copswood FC vs Coventry Phoenix FC:',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '(09-04-2024)',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                  Icon(Icons.eco, color: Colors.red, size: 66),
                                  const SizedBox(width: 5),
                                  // const
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
                                  )
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
                                      text: 'March 2024', // The first part
                                      style: TextStyle(
                                        fontSize: 25, // First part size
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nClub Report', // The second part
                                      style: TextStyle(
                                        fontSize: 40, // Bigger size for 'Club Report'
                                        fontWeight: FontWeight.w800, // Bold weight for 'Club Report'

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

            /////
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: AspectRatio(
            //     aspectRatio: 210 / 297, // A4 aspect ratio
            //     child: Container(
            //       color: Colors.white,
            //       child: Column(
            //         children: [
            //           // Header with club information
            //           Container(
            //             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 // Club logo placeholder
            //                 CircleAvatar(
            //                   radius: 30,
            //                   backgroundColor: Colors.blue,
            //                   child: Icon(
            //                     Icons.sports_soccer,
            //                     color: Colors.white,
            //                     size: 40,
            //                   ),
            //                 ),
            //                 // Club name placeholder
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.end,
            //                   children: const [
            //                     Text(
            //                       'Coventry Phoenix',
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                     Text(
            //                       'Football Club',
            //                       style: TextStyle(
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.w600,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //           // The main content of the page
            //           Expanded(
            //             flex: 1,
            //             child: Stack(
            //               children: [
            //                 Positioned.fill(
            //                   child: Container(color: Colors.white), // Background
            //                 ),
            //                 // Pie chart section for club population
            //                 Positioned(
            //                   left: 20,
            //                   top: 80,
            //                   child: SizedBox(
            //                     width: 120,
            //                     height: 120,
            //                     child: PieChart(
            //                       dataMap: {
            //                         "Players": 70,
            //                         "Coaches": 20,
            //                         "Managers": 10,
            //                       },
            //                       chartType: ChartType.ring,
            //                       ringStrokeWidth: 20,
            //                       centerText: "Club Population",
            //                       chartValuesOptions: ChartValuesOptions(showChartValues: false),
            //                       colorList: [Colors.blue, Colors.red, Colors.green],
            //                     ),
            //                   ),
            //                 ),
            //                 // Club position in the table (top-right)
            //                 Positioned(
            //                   right: 20,
            //                   top: 80,
            //                   child: Container(
            //                     padding: const EdgeInsets.all(8),
            //                     decoration: BoxDecoration(
            //                       color: Colors.blue,
            //                       borderRadius: BorderRadius.circular(8),
            //                     ),
            //                     child: Column(
            //                       children: const [
            //                         Text(
            //                           'Position: 5th',
            //                           style: TextStyle(
            //                             color: Colors.white,
            //                             fontSize: 16,
            //                             fontWeight: FontWeight.bold,
            //                           ),
            //                         ),
            //                         Text(
            //                           'Goals: 45',
            //                           style: TextStyle(color: Colors.white),
            //                         ),
            //                         Text(
            //                           'Goals Conceded: 22',
            //                           style: TextStyle(color: Colors.white),
            //                         ),
            //                         Text(
            //                           'Matches Played: 12',
            //                           style: TextStyle(color: Colors.white),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //                 // Top 5 Goal Scorers
            //                 Positioned(
            //                   left: 20,
            //                   top: 220,
            //                   child: Container(
            //                     width: 150,
            //                     padding: const EdgeInsets.all(10),
            //                     color: Colors.grey[200],
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: const [
            //                         Text('Top 5 Goal Scorers', style: TextStyle(fontWeight: FontWeight.bold)),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('John Doe - 12 goals'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('Jane Smith - 9 goals'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('James Brown - 7 goals'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('Mark Black - 6 goals'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('Alice White - 5 goals'),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //                 // Top 3 Assist Players
            //                 Positioned(
            //                   right: 20,
            //                   top: 220,
            //                   child: Container(
            //                     width: 150,
            //                     padding: const EdgeInsets.all(10),
            //                     color: Colors.grey[200],
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: const [
            //                         Text('Top 3 Assist Players', style: TextStyle(fontWeight: FontWeight.bold)),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('John Doe - 7 assists'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('Jane Smith - 6 assists'),
            //                         ),
            //                         ListTile(
            //                           contentPadding: EdgeInsets.all(0),
            //                           leading: Icon(Icons.person),
            //                           title: Text('James Brown - 5 assists'),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           // Footer
            //           Container(
            //             height: 14,
            //             color: Colors.brown,
            //             padding: const EdgeInsets.symmetric(horizontal: 11),
            //             alignment: Alignment.center,
            //           ),
            //           // AI Summary footer container
            //           Container(
            //             height: 25,
            //             color: Colors.black,
            //             padding: const EdgeInsets.symmetric(horizontal: 11),
            //             alignment: Alignment.center,
            //             child: const Text(
            //               'AI-Generated Summary: Strong performance this month, key players include John Doe and Jane Smith. The club is looking to improve defense.',
            //               style: TextStyle(color: Colors.white, fontSize: 12),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
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
