import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/third_team_class_model.dart';
import '../notifier/third_team_class_notifier.dart';

Future<void> getThirdTeamClass(ThirdTeamClassNotifier thirdTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('ThirdTeamClassPlayers').orderBy('name').get();

  List<ThirdTeamClass> thirdTeamClassList = [];

  for (var document in snapshot.docs) {
    ThirdTeamClass thirdTeamClass = ThirdTeamClass.fromMap(document.data() as Map<String, dynamic>);
    thirdTeamClassList.add(thirdTeamClass);
  }

  thirdTeamClassNotifier.thirdTeamClassList = thirdTeamClassList;
}
