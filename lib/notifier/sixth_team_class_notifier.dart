import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/sixth_team_class.dart';

class SixthTeamClassNotifier with ChangeNotifier {
  List<SixthTeamClass> _sixthTeamClassList = [];
  late SixthTeamClass _currentSixthTeamClass;

  UnmodifiableListView<SixthTeamClass> get sixthTeamClassList => UnmodifiableListView(_sixthTeamClassList);

  SixthTeamClass get currentSixthTeamClass => _currentSixthTeamClass;

  set sixthTeamClassList(List<SixthTeamClass> sixthTeamClassList) {
    _sixthTeamClassList = sixthTeamClassList;
    notifyListeners();
  }

  set currentSixthTeamClass(SixthTeamClass sixthTeamClass) {
    _currentSixthTeamClass = sixthTeamClass;
    notifyListeners();
  }
}
