import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/a_upcoming_matches_all_clubs_model.dart';

class UpcomingMatchesForAllClubsNotifier with ChangeNotifier {
  List<UpcomingMatchesForAllClubs> _upcomingMatchesForAllClubsList = [];
  late UpcomingMatchesForAllClubs _currentUpcomingMatchesForAllClubs;

  UnmodifiableListView<UpcomingMatchesForAllClubs> get upcomingMatchesForAllClubsList => UnmodifiableListView(_upcomingMatchesForAllClubsList);

  UpcomingMatchesForAllClubs get currentUpcomingMatchesForAllClubs => _currentUpcomingMatchesForAllClubs;

  set upcomingMatchesForAllClubsList(List<UpcomingMatchesForAllClubs> upcomingMatchesForAllClubsList) {
    _upcomingMatchesForAllClubsList = upcomingMatchesForAllClubsList;
    notifyListeners();
  }

  set currentUpcomingMatchesForAllClubs(UpcomingMatchesForAllClubs upcomingMatchesForAllClubs) {
    _currentUpcomingMatchesForAllClubs = upcomingMatchesForAllClubs;
    notifyListeners();
  }
}
