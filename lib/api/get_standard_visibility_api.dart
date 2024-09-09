import 'package:cloud_firestore/cloud_firestore.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "StandardVisibility";

String visibilityCheckTitle = 'isVisible';

Future<Map<String, bool>> getStandardVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID);

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> standardVisibility = {};

  for (var doc in snapshot.docs) {
    standardVisibility[doc.id] = doc[visibilityCheckTitle] as bool;
  }

  return standardVisibility;
}
