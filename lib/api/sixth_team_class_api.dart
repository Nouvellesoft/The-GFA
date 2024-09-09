import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/sixth_team_class_model.dart';
import '../notifier/sixth_team_class_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "SixthTeamClassPlayers";
String fieldsAnchorSnapshotID = "name";

Future<void> getSixthTeamClass(SixthTeamClassNotifier sixthTeamClassNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID)
      .get();

  List<SixthTeamClass> sixthTeamClassList = [];

  for (var document in snapshot.docs) {
    SixthTeamClass sixthTeamClass = SixthTeamClass.fromMap(document.data() as Map<String, dynamic>);
    sixthTeamClassList.add(sixthTeamClass);
  }

  sixthTeamClassNotifier.sixthTeamClassList = sixthTeamClassList;
}
