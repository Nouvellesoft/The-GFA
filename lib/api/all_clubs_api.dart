import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getClubs() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').get();

  List<String> clubIds = snapshot.docs.map((doc) => doc.id).toList();

  return clubIds;
}
