import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/fourth_team_class_model.dart';
import '../notifier/fourth_team_class_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "FourthTeamClassPlayers";
String fieldsAnchorSnapshotID = "name";

Future<void> getFourthTeamClass(FourthTeamClassNotifier fourthTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID)
      .get();

  List<FourthTeamClass> fourthTeamClassList = [];

  for (var document in snapshot.docs) {
    FourthTeamClass fourthTeamClass = FourthTeamClass.fromMap(document.data() as Map<String, dynamic>);
    fourthTeamClassList.add(fourthTeamClass);
  }

  fourthTeamClassNotifier.fourthTeamClassList = fourthTeamClassList;
}
