import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/fourth_team_class.dart';
import '../notifier/fourth_team_class_notifier.dart';

Future<void> getFourthTeamClass(FourthTeamClassNotifier fourthTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('FourthTeamClassPlayers').orderBy('name').get();

  List<FourthTeamClass> fourthTeamClassList = [];

  for (var document in snapshot.docs) {
    FourthTeamClass fourthTeamClass = FourthTeamClass.fromMap(document.data() as Map<String, dynamic>);
    fourthTeamClassList.add(fourthTeamClass);
  }

  fourthTeamClassNotifier.fourthTeamClassList = fourthTeamClassList;
}
