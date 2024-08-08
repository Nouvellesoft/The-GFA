import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, bool>> getTeamClassVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('TeamClassVisibility');

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> teamVisibility = {};

  for (var doc in snapshot.docs) {
    teamVisibility[doc.id] = doc['isVisible'] as bool;
  }

  return teamVisibility;
}
