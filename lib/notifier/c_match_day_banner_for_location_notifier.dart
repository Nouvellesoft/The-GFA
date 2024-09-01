import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../api/c_match_day_banner_for_location_api.dart';
import '../model/c_match_day_banner_for_locations_model.dart';

class MatchDayBannerForLocationNotifier with ChangeNotifier {
  List<MatchDayBannerForLocation> _matchDayBannerForLocationList = [];
  late MatchDayBannerForLocation _currentMatchDayBannerForLocation;

  UnmodifiableListView<MatchDayBannerForLocation> get matchDayBannerForLocationList => UnmodifiableListView(_matchDayBannerForLocationList);

  MatchDayBannerForLocation get currentMatchDayBannerForLocation => _currentMatchDayBannerForLocation;

  set matchDayBannerForLocationList(List<MatchDayBannerForLocation> matchDayBannerForLocationList) {
    _matchDayBannerForLocationList = matchDayBannerForLocationList;
    notifyListeners();
  }

  set currentMatchDayBannerForLocation(MatchDayBannerForLocation matchDayBannerForLocation) {
    _currentMatchDayBannerForLocation = matchDayBannerForLocation;
    notifyListeners();
  }

  Future<void> refreshLocations(String clubId) async {
    await getMatchDayBannerForLocation(this, clubId);
    notifyListeners();
  }

  // Define the addMatchDayBannerForLocation method
  void addMatchDayBannerForLocation(MatchDayBannerForLocation matchDayBannerForLocation) {
    _matchDayBannerForLocationList.add(matchDayBannerForLocation);
    notifyListeners(); // Notify listeners after adding a new location
  }
}
