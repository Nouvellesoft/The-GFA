import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/b_trial_dates_model.dart';
import '../notifier/b_trial_dates_notifier.dart';

Future<void> getTrialDates(TrialDatesNotifier trialDatesNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('TrialDates').orderBy('date').get();

  List<TrialDates> trialDatesList = [];

  for (var document in snapshot.docs) {
    TrialDates trialDates = TrialDates.fromMap(document.data() as Map<String, dynamic>);
    trialDatesList.add(trialDates);
  }

  trialDatesNotifier.trialDatesList = trialDatesList;
}
