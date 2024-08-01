import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/club_arial.dart';
import '../notifier/club_arial_notifier.dart';

Future<void> getClubArial(ClubArialNotifier clubArialNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('ClubArial').get();

  List<ClubArial> clubArialList = [];

  for (var document in snapshot.docs) {
    ClubArial clubArial = ClubArial.fromMap(document.data() as Map<String, dynamic>);
    clubArialList.add(clubArial);
  }

  clubArialNotifier.clubArialList = clubArialList;
}
