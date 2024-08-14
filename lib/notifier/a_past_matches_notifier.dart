import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/a_past_matches_model.dart';
import 'club_global_notifier.dart';

class PastMatchesNotifier with ChangeNotifier {
  List<PastMatches> _pastMatchesList = [];
  late PastMatches _currentPastMatches;

  UnmodifiableListView<PastMatches> get pastMatchesList => UnmodifiableListView(_pastMatchesList);

  PastMatches get currentPastMatches => _currentPastMatches;

  set pastMatchesList(List<PastMatches> pastMatchesList) {
    _pastMatchesList = pastMatchesList;
    notifyListeners();
  }

  set currentPastMatches(PastMatches pastMatches) {
    _currentPastMatches = pastMatches;
    notifyListeners();
  }

  void updateClubIconFromProvider(ClubGlobalProvider clubGlobalProvider) {
    for (var match in _pastMatchesList) {
      match.updateClubIcon(clubGlobalProvider.clubName, clubGlobalProvider.clubIcon);
    }
    notifyListeners();
  }
}
