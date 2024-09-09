import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_leagues_model.dart';
import '../notifier/c_match_day_banner_for_league_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "MatchDayBannerForLeague";
String fieldsAnchorSnapshotID = "league";

Future<void> getMatchDayBannerForLeague(MatchDayBannerForLeagueNotifier matchDayBannerForLeagueNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
      .get();

  List<MatchDayBannerForLeague> matchDayBannerForLeagueList = [];

  for (var document in snapshot.docs) {
    MatchDayBannerForLeague matchDayBannerForLeague = MatchDayBannerForLeague.fromMap(document.data() as Map<String, dynamic>);
    matchDayBannerForLeagueList.add(matchDayBannerForLeague);
  }

  matchDayBannerForLeagueNotifier.matchDayBannerForLeagueList = matchDayBannerForLeagueList;
}
