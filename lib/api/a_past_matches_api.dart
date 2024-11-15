import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_past_matches_model.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/a_past_matches_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';
import 'c_match_day_banner_for_club_opp_api.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "PastMatches";
String fieldsAnchorSnapshotID = "id";

const String defaultImage = 'assets/images/no_club_icon_default.jpeg';

Future<void> getPastMatches(
  PastMatchesNotifier pastMatchesNotifier,
  MatchDayBannerForClubNotifier matchDayBannerForClubNotifier,
  MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier,
  ClubGlobalProvider clubGlobalProvider,
  String clubId,
) async {
  // Fetch MatchDayBannerForClub data
  await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalProvider, clubId);

  // Fetch MatchDayBannerForClubOpp data
  await getMatchDayBannerForClubOpp(matchDayBannerForClubOppNotifier, clubId);

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: false)
      .limit(30)
      .get();

  List<PastMatches> pastMatchesList = [];

  // Function to parse date strings and compare them
  // int compareDate(String dateString1, String dateString2) {
  //   DateTime date1 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString1);
  //   DateTime date2 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString2);
  //   return date2.compareTo(date1); // Compare in descending order
  // }

  // Sort documents based on the custom comparison function
  // snapshot.docs.sort((a, b) => compareDate(a['match_date'], b['match_date']));

  // Define the default image path

  for (var document in snapshot.docs) {
    PastMatches pastMatches = PastMatches.fromMap(document.data() as Map<String, dynamic>);

    // Check if home team matches any banner team name
    bool homeTeamMatched = false;
    bool awayTeamMatched = false;

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (pastMatches.homeTeam == banner.teamName) {
        pastMatches.homeTeamIcon = banner.clubLogo;
        homeTeamMatched = true;
      }
      if (pastMatches.awayTeam == banner.teamName) {
        pastMatches.awayTeamIcon = banner.clubLogo;
        awayTeamMatched = true;
      }
    }

    // Match against the MatchDayBannerForClubOpp team names (for opposition teams)
    for (var oppBanner in matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList) {
      if (pastMatches.homeTeam == oppBanner.clubName) {
        pastMatches.homeTeamIcon = oppBanner.clubIcon;
        homeTeamMatched = true;
      }
      if (pastMatches.awayTeam == oppBanner.clubName) {
        pastMatches.awayTeamIcon = oppBanner.clubIcon;
        awayTeamMatched = true;
      }
    }

    // If no match is found for the home team, use the default image
    if (!homeTeamMatched) {
      pastMatches.homeTeamIcon = defaultImage;
    }

    // If no match is found for the away team, use the default image
    if (!awayTeamMatched) {
      pastMatches.awayTeamIcon = defaultImage;
    }

    pastMatchesList.add(pastMatches);
  }

  pastMatchesNotifier.pastMatchesList = pastMatchesList;
}
