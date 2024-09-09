import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/first_team_class_model.dart';
import '../notifier/first_team_class_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "FirstTeamClassPlayers";
String fieldsAnchorSnapshotID = "name";

getFirstTeamClass(FirstTeamClassNotifier firstTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID)
      .get();

  List<FirstTeamClass> firstTeamClassList = [];

  for (var document in snapshot.docs) {
    FirstTeamClass firstTeamClass = FirstTeamClass.fromMap(document.data() as Map<String, dynamic>);
    firstTeamClassList.add(firstTeamClass);
  }

  firstTeamClassNotifier.firstTeamClassList = firstTeamClassList;
}
