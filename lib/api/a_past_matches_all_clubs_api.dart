import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_past_matches_all_clubs_model.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/a_past_matches_all_clubs_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';
import 'c_match_day_banner_for_club_opp_api.dart';

Future<void> getPastMatchesForAllClubs(
  PastMatchesForAllClubsNotifier pastMatchesForAllClubsNotifier,
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
      .collection('clubs')
      .doc(clubId)
      .collection('PastMatchesForAllClubs')
      .orderBy('id', descending: false)
      .limit(30)
      .get();

  List<PastMatchesForAllClubs> pastMatchesForAllClubsList = [];

  // Function to parse date strings and compare them
  // int compareDate(String dateString1, String dateString2) {
  //   DateTime date1 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString1);
  //   DateTime date2 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString2);
  //   return date2.compareTo(date1); // Compare in descending order
  // }

  // Sort documents based on the custom comparison function
  // snapshot.docs.sort((a, b) => compareDate(a['match_date'], b['match_date']));

  // Define the default image path

  const String defaultImage = 'assets/images/no_club_icon_default.jpeg';

  for (var document in snapshot.docs) {
    PastMatchesForAllClubs pastMatchesForAllClubs = PastMatchesForAllClubs.fromMap(document.data() as Map<String, dynamic>);

    // Check if home team matchesForAllClubs any banner team name
    bool homeTeamMatched = false;
    bool awayTeamMatched = false;

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (pastMatchesForAllClubs.homeTeam == banner.teamName) {
        pastMatchesForAllClubs.homeTeamIcon = banner.clubLogo;
        homeTeamMatched = true;
      }
      if (pastMatchesForAllClubs.awayTeam == banner.teamName) {
        pastMatchesForAllClubs.awayTeamIcon = banner.clubLogo;
        awayTeamMatched = true;
      }
    }

    // Match against the MatchDayBannerForClubOpp team names (for opposition teams)
    for (var oppBanner in matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList) {
      if (pastMatchesForAllClubs.homeTeam == oppBanner.clubName) {
        pastMatchesForAllClubs.homeTeamIcon = oppBanner.clubIcon;
        homeTeamMatched = true;
      }
      if (pastMatchesForAllClubs.awayTeam == oppBanner.clubName) {
        pastMatchesForAllClubs.awayTeamIcon = oppBanner.clubIcon;
        awayTeamMatched = true;
      }
    }

    // If no match is found for the home team, use the default image
    if (!homeTeamMatched) {
      pastMatchesForAllClubs.homeTeamIcon = defaultImage;
    }

    // If no match is found for the away team, use the default image
    if (!awayTeamMatched) {
      pastMatchesForAllClubs.awayTeamIcon = defaultImage;
    }

    pastMatchesForAllClubsList.add(pastMatchesForAllClubs);
  }

  pastMatchesForAllClubsNotifier.pastMatchesForAllClubsList = pastMatchesForAllClubsList;
}
