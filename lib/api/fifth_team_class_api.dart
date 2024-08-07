import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/fifth_team_class.dart';
import '../notifier/fifth_team_class_notifier.dart';

Future<void> getFifthTeamClass(FifthTeamClassNotifier fifthTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('FifthTeamClassPlayers').orderBy('name').get();

  List<FifthTeamClass> fifthTeamClassList = [];

  for (var document in snapshot.docs) {
    FifthTeamClass fifthTeamClass = FifthTeamClass.fromMap(document.data() as Map<String, dynamic>);
    fifthTeamClassList.add(fifthTeamClass);
  }

  fifthTeamClassNotifier.fifthTeamClassList = fifthTeamClassList;
}
