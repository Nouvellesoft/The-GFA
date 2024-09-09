import 'package:cloud_firestore/cloud_firestore.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "BasicVisibility";

String visibilityCheckTitle = 'isVisible';

Future<Map<String, bool>> getBasicVisibility(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID);

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, bool> basicVisibility = {};

  for (var doc in snapshot.docs) {
    basicVisibility[doc.id] = doc[visibilityCheckTitle] as bool;
  }

  return basicVisibility;
}
