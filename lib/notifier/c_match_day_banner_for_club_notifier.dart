import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/c_match_day_banner_for_clubs_model.dart';
import 'a_club_global_notifier.dart';

class MatchDayBannerForClubNotifier with ChangeNotifier {
  List<MatchDayBannerForClub> _matchDayBannerForClubList = [];
  late MatchDayBannerForClub _currentMatchDayBannerForClub;

  UnmodifiableListView<MatchDayBannerForClub> get matchDayBannerForClubList => UnmodifiableListView(_matchDayBannerForClubList);

  MatchDayBannerForClub get currentMatchDayBannerForClub => _currentMatchDayBannerForClub;

  set matchDayBannerForClubList(List<MatchDayBannerForClub> matchDayBannerForClubList) {
    _matchDayBannerForClubList = matchDayBannerForClubList;
    notifyListeners();
  }

  set currentMatchDayBannerForClub(MatchDayBannerForClub matchDayBannerForClub) {
    _currentMatchDayBannerForClub = matchDayBannerForClub;
    notifyListeners();
  }

  void updateClubIconsFromProvider(ClubGlobalProvider clubGlobalProvider) {
    for (var banner in _matchDayBannerForClubList) {
      banner.updateClubIcon(clubGlobalProvider.clubIcon);
      banner.updateClubLogo(clubGlobalProvider.clubLogo);
    }
    notifyListeners();
  }
}
