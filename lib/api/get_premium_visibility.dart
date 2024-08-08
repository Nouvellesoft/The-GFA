import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, bool>> getPremiumVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('PremiumVisibility');

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> premiumVisibility = {};

  for (var doc in snapshot.docs) {
    premiumVisibility[doc.id] = doc['isVisible'] as bool;
  }

  return premiumVisibility;
}
