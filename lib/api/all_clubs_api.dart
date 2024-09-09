import 'package:cloud_firestore/cloud_firestore.dart';

String collectionSnapshotID = "clubs";

Future<List<String>> getClubs() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionSnapshotID).get();

  List<String> clubIds = snapshot.docs.map((doc) => doc.id).toList();

  return clubIds;
}
