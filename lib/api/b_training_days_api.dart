import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/b_training_days_model.dart';
import '../notifier/b_training_days_notifier.dart';

Future<void> getTrainingDays(TrainingDaysNotifier trainingDaysNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('TrainingDays').orderBy('day').get();

  List<TrainingDays> trainingDaysList = [];

  for (var document in snapshot.docs) {
    TrainingDays trainingDays = TrainingDays.fromMap(document.data() as Map<String, dynamic>);
    trainingDaysList.add(trainingDays);
  }

  trainingDaysNotifier.trainingDaysList = trainingDaysList;
}
