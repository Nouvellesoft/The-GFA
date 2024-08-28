import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/a_past_matches_all_clubs_model.dart';

class PastMatchesForAllClubsNotifier with ChangeNotifier {
  List<PastMatchesForAllClubs> _pastMatchesForAllClubsList = [];
  late PastMatchesForAllClubs _currentPastMatchesForAllClubs;

  UnmodifiableListView<PastMatchesForAllClubs> get pastMatchesForAllClubsList => UnmodifiableListView(_pastMatchesForAllClubsList);

  PastMatchesForAllClubs get currentPastMatchesForAllClubs => _currentPastMatchesForAllClubs;

  set pastMatchesForAllClubsList(List<PastMatchesForAllClubs> pastMatchesForAllClubsList) {
    _pastMatchesForAllClubsList = pastMatchesForAllClubsList;
    notifyListeners();
  }

  set currentPastMatchesForAllClubs(PastMatchesForAllClubs pastMatchesForAllClubs) {
    _currentPastMatchesForAllClubs = pastMatchesForAllClubs;
    notifyListeners();
  }
}
