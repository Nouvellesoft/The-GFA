import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_clubs_model.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "MatchDayBannerForClub";
String fieldsAnchorSnapshotID = "team_name";

Future<void> getMatchDayBannerForClub(
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier, ClubGlobalProvider clubGlobalProvider, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
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
