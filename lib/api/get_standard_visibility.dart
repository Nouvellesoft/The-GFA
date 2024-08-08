import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, bool>> getStandardVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('StandardVisibility');

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> standardVisibility = {};

  for (var doc in snapshot.docs) {
    standardVisibility[doc.id] = doc['isVisible'] as bool;
  }

  return standardVisibility;
}
