import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/b_trial_dates_model.dart';
import '../notifier/b_trial_dates_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "TrialDates";
String fieldsAnchorSnapshotID = "date";

Future<void> getTrialDates(TrialDatesNotifier trialDatesNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID)
      .get();

  List<TrialDates> trialDatesList = [];

  for (var document in snapshot.docs) {
    TrialDates trialDates = TrialDates.fromMap(document.data() as Map<String, dynamic>);
    trialDatesList.add(trialDates);
  }

  trialDatesNotifier.trialDatesList = trialDatesList;
}
