import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/club_arial_model.dart';
import '../notifier/club_arial_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "ClubArial";

Future<void> getClubArial(ClubArialNotifier clubArialNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID).get();

  List<ClubArial> clubArialList = [];

  for (var document in snapshot.docs) {
    ClubArial clubArial = ClubArial.fromMap(document.data() as Map<String, dynamic>);
    clubArialList.add(clubArial);
  }

  clubArialNotifier.clubArialList = clubArialList;
}
