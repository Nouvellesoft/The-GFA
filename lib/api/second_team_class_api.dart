import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/second_team_class_model.dart';
import '../notifier/second_team_class_notifier.dart';

Future<void> getSecondTeamClass(SecondTeamClassNotifier secondTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('SecondTeamClassPlayers').orderBy('name').get();

  List<SecondTeamClass> secondTeamClassList = [];

  for (var document in snapshot.docs) {
    SecondTeamClass secondTeamClass = SecondTeamClass.fromMap(document.data() as Map<String, dynamic>);
    secondTeamClassList.add(secondTeamClass);
  }

  secondTeamClassNotifier.secondTeamClassList = secondTeamClassList;
}
