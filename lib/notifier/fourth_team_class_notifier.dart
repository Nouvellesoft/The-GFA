import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/fourth_team_class_model.dart';

class FourthTeamClassNotifier with ChangeNotifier {
  List<FourthTeamClass> _fourthTeamClassList = [];
  late FourthTeamClass _currentFourthTeamClass;

  UnmodifiableListView<FourthTeamClass> get fourthTeamClassList => UnmodifiableListView(_fourthTeamClassList);

  FourthTeamClass get currentFourthTeamClass => _currentFourthTeamClass;

  set fourthTeamClassList(List<FourthTeamClass> fourthTeamClassList) {
    _fourthTeamClassList = fourthTeamClassList;
    notifyListeners();
  }

  set currentFourthTeamClass(FourthTeamClass fourthTeamClass) {
    _currentFourthTeamClass = fourthTeamClass;
    notifyListeners();
  }
}
