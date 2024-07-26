import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_club.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';

getMatchDayBannerForClub(MatchDayBannerForClubNotifier matchDayBannerForClubNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('MatchDayBannerForClub')
      .orderBy('club_name', descending: false)
      .get();

  List<MatchDayBannerForClub> matchDayBannerForClubList = [];

  for (var document in snapshot.docs) {
    MatchDayBannerForClub matchDayBannerForClub = MatchDayBannerForClub.fromMap(document.data() as Map<String, dynamic>);
    matchDayBannerForClubList.add(matchDayBannerForClub);
  }

  matchDayBannerForClubNotifier.matchDayBannerForClubList = matchDayBannerForClubList;
}
