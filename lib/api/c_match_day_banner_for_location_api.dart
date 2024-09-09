import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/c_match_day_banner_for_locations_model.dart';
import '../notifier/c_match_day_banner_for_location_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "MatchDayBannerForLocation";
String fieldsAnchorSnapshotID = "location";

Future<void> getMatchDayBannerForLocation(MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
      .get();

  List<MatchDayBannerForLocation> matchDayBannerForLocationList = [];

  for (var document in snapshot.docs) {
    MatchDayBannerForLocation matchDayBannerForLocation = MatchDayBannerForLocation.fromMap(document.data() as Map<String, dynamic>);
    matchDayBannerForLocationList.add(matchDayBannerForLocation);
  }

  matchDayBannerForLocationNotifier.matchDayBannerForLocationList = matchDayBannerForLocationList;
}
