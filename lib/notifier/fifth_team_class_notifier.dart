import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/fifth_team_class.dart';

class FifthTeamClassNotifier with ChangeNotifier {
  List<FifthTeamClass> _fifthTeamClassList = [];
  late FifthTeamClass _currentFifthTeamClass;

  UnmodifiableListView<FifthTeamClass> get fifthTeamClassList => UnmodifiableListView(_fifthTeamClassList);

  FifthTeamClass get currentFifthTeamClass => _currentFifthTeamClass;

  set fifthTeamClassList(List<FifthTeamClass> fifthTeamClassList) {
    _fifthTeamClassList = fifthTeamClassList;
    notifyListeners();
  }

  set currentFifthTeamClass(FifthTeamClass fifthTeamClass) {
    _currentFifthTeamClass = fifthTeamClass;
    notifyListeners();
  }
}
