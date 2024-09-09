import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/coaches_model.dart';
import '../notifier/coaching_staff_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "Coaches";
String fieldsAnchorSnapshotID = "id";

Future<void> getCoaches(CoachesNotifier coachesNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID)
      .get();

  List<Coaches> coachesList = [];

  for (var document in snapshot.docs) {
    Coaches coaches = Coaches.fromMap(document.data() as Map<String, dynamic>);
    coachesList.add(coaches);
  }

  coachesNotifier.coachesList = coachesList;
}
