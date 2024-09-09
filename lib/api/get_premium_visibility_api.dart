import 'package:cloud_firestore/cloud_firestore.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "PremiumVisibility";

String visibilityCheckTitle = 'isVisible';

Future<Map<String, bool>> getPremiumVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID);

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> premiumVisibility = {};

  for (var doc in snapshot.docs) {
    premiumVisibility[doc.id] = doc[visibilityCheckTitle] as bool;
  }

  return premiumVisibility;
}
