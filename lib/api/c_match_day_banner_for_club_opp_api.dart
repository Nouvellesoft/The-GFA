import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_club_opps_model.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "MatchDayBannerForClubOpp";
String fieldsAnchorSnapshotID = "club_name";

Future<void> getMatchDayBannerForClubOpp(MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
      .get();

  List<MatchDayBannerForClubOpp> matchDayBannerForClubOppList = [];

  for (var document in snapshot.docs) {
    MatchDayBannerForClubOpp matchDayBannerForClubOpp = MatchDayBannerForClubOpp.fromMap(document.data() as Map<String, dynamic>);
    matchDayBannerForClubOppList.add(matchDayBannerForClubOpp);
  }

  matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList = matchDayBannerForClubOppList;
}
