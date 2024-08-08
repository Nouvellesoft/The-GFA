import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, bool>> getBasicVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('BasicVisibility');

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> basicVisibility = {};

  for (var doc in snapshot.docs) {
    basicVisibility[doc.id] = doc['isVisible'] as bool;
  }

  return basicVisibility;
}
