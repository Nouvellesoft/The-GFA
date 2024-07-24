import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getClubIds() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').get();

    // List<String> clubIds = [];
    // for (var document in snapshot.docs) {
    //   clubIds.add(document.id);
    // }
    List<String> clubIds = snapshot.docs.map((doc) => doc.id).toList();
    print('Club ID: $clubIds'); //Log Call Ids
    return clubIds;
  } catch (e) {
    print('Error fetching club IDs: $e'); //Log errors
    return [];
  }
}
