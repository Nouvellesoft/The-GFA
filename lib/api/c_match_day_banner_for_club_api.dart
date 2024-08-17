import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_clubs_model.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/a_club_global_notifier.dart';

Future<void> getMatchDayBannerForClub(
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier, ClubGlobalProvider clubGlobalProvider, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('MatchDayBannerForClub')
      .orderBy('team_name', descending: false)
      .get();

  List<MatchDayBannerForClub> matchDayBannerForClubList = [];

  for (var document in snapshot.docs) {
    MatchDayBannerForClub matchDayBannerForClub = MatchDayBannerForClub.fromMap(document.data() as Map<String, dynamic>);
    matchDayBannerForClubList.add(matchDayBannerForClub);
  }

  matchDayBannerForClubNotifier.matchDayBannerForClubList = matchDayBannerForClubList;

  // Update icons from provider
  matchDayBannerForClubNotifier.updateClubIconsFromProvider(clubGlobalProvider);
}
