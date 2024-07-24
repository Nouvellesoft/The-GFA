import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ClubSelectionPage extends StatefulWidget {
  const ClubSelectionPage({super.key});

  @override
  _ClubSelectionPageState createState() => _ClubSelectionPageState();
}

class _ClubSelectionPageState extends State<ClubSelectionPage> {
  Future<List<String>> getClubIds() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').get();
      List<String> clubIds = snapshot.docs.map((doc) => doc.id).toList();
      return clubIds;
    } catch (e) {
      print('Error fetching club IDs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Club')),
      body: FutureBuilder<List<String>>(
        future: getClubIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching clubs: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No clubs found'));
          } else {
            List<String> clubIds = snapshot.data!;
            return Column(
              children: clubIds.map((id) => Text(id)).toList(),
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
      print("completed");
      setState(() {});
    });
  }
}
