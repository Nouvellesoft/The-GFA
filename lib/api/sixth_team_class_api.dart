import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/sixth_team_class.dart';
import '../notifier/sixth_team_class_notifier.dart';

Future<void> getSixthTeamClass(SixthTeamClassNotifier sixthTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('SixthTeamClassPlayers').orderBy('name').get();

  List<SixthTeamClass> sixthTeamClassList = [];

  for (var document in snapshot.docs) {
    SixthTeamClass sixthTeamClass = SixthTeamClass.fromMap(document.data() as Map<String, dynamic>);
    sixthTeamClassList.add(sixthTeamClass);
  }

  sixthTeamClassNotifier.sixthTeamClassList = sixthTeamClassList;
}
