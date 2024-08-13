import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, Map<String, dynamic>>> getTeamClassVisibilityAndTitles(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('TeamClassVisibility');

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, Map<String, dynamic>> teamData = {};

  for (var doc in snapshot.docs) {
    teamData[doc.id] = {
      'isVisible': doc['isVisible'] as bool,
      'title': doc['title'] as String? ?? '', // Get the title, default to empty string if not found
    };
  }

  return teamData;
}
