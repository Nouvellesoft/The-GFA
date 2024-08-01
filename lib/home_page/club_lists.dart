import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_gfa/sidebar/sidebar_layout.dart';

import '../api/all_clubs_api.dart';

class ClubSelectionPage extends StatefulWidget {
  const ClubSelectionPage({super.key});

  @override
  State<ClubSelectionPage> createState() => _ClubSelectionPageState();
}

class _ClubSelectionPageState extends State<ClubSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Club')),
      body: FutureBuilder<List<String>>(
        future: getClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching clubs: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clubs found'));
          } else {
            List<String> clubs = snapshot.data!;
            return ListView.builder(
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                var clubId = clubs[index];
                return ListTile(
                  title: Text(clubId), // Display the club ID or any other relevant information
                  onTap: () {
                    // Navigate to the ClubDetailPage with the selected clubId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => ClubDetailPage(clubId: clubId),
                        builder: (context) => SideBarLayout(clubId: clubId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      if (kDebugMode) {
        print("completed");
      }
      setState(() {});
    });
  }
}
