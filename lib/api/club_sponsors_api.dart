import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/club_sponsors_model.dart';
import '../notifier/club_sponsors_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "ClubSponsors";
String fieldsAnchorSnapshotID = "id";

Future<void> getClubSponsors(ClubSponsorsNotifier clubSponsorsNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
      .get();

  List<ClubSponsors> clubSponsorsList = [];

  for (var document in snapshot.docs) {
    ClubSponsors clubSponsors = ClubSponsors.fromMap(document.data() as Map<String, dynamic>);
    clubSponsorsList.add(clubSponsors);
  }

  clubSponsorsNotifier.clubSponsorsList = clubSponsorsList;
}
