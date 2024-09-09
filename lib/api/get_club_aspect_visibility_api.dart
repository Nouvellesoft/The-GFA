import 'package:cloud_firestore/cloud_firestore.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "ClubAspectVisibility";

String visibilityCheckTitle = 'isVisible';
String titleTitle = 'title';

Future<Map<String, Map<String, dynamic>>> getClubAspectVisibilityAndTitles(String clubId) async {
  CollectionReference visibilityRef = FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID);

  QuerySnapshot snapshot = await visibilityRef.get();

  Map<String, Map<String, dynamic>> teamData = {};

  for (var doc in snapshot.docs) {
    teamData[doc.id] = {
      visibilityCheckTitle: doc[visibilityCheckTitle] as bool,
      titleTitle: doc[titleTitle] as String? ?? '', // Get the title, default to empty string if not found
    };
  }

  return teamData;
}
