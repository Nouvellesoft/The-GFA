import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/b_trial_dates_model.dart';

class TrialDatesNotifier with ChangeNotifier {
  List<TrialDates> _trialDatesList = [];
  TrialDates _currentTrialDates = TrialDates();

  UnmodifiableListView<TrialDates> get trialDatesList => UnmodifiableListView(_trialDatesList);

  TrialDates get currentTrialDates => _currentTrialDates;

  set trialDatesList(List<TrialDates> trialDatesList) {
    _trialDatesList = trialDatesList;
    notifyListeners();
  }

  set currentTrialDates(TrialDates trialDates) {
    _currentTrialDates = trialDates;
    notifyListeners();
  }
}
