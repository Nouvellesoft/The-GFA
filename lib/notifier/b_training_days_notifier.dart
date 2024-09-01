import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/b_training_days_model.dart';

class TrainingDaysNotifier with ChangeNotifier {
  List<TrainingDays> _trainingDaysList = [];
  TrainingDays _currentTrainingDays = TrainingDays();

  UnmodifiableListView<TrainingDays> get trainingDaysList => UnmodifiableListView(_trainingDaysList);

  TrainingDays get currentTrainingDays => _currentTrainingDays;

  set trainingDaysList(List<TrainingDays> trainingDaysList) {
    _trainingDaysList = trainingDaysList;
    notifyListeners();
  }

  set currentTrainingDays(TrainingDays trainingDays) {
    _currentTrainingDays = trainingDays;
    notifyListeners();
  }
}
