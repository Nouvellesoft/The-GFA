import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_upcoming_matches_all_clubs_model.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/a_upcoming_matches_all_clubs_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';
import 'c_match_day_banner_for_club_opp_api.dart';

Future<void> getUpcomingMatchesForAllClubs(
  UpcomingMatchesForAllClubsNotifier upcomingMatchesForAllClubsNotifier,
  MatchDayBannerForClubNotifier matchDayBannerForClubNotifier,
  MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier,
  ClubGlobalProvider clubGlobalProvider,
  String clubId,
) async {
  // Fetch MatchDayBannerForClub data
  await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalProvider, clubId);

  // Fetch MatchDayBannerForClubOpp data
  await getMatchDayBannerForClubOpp(matchDayBannerForClubOppNotifier, clubId);

  // DateTime currentDate = DateTime.now();
  // double currentFractionalDays = currentDate.millisecondsSinceEpoch / (1000 * 60 * 60 * 24);

  // print('Current Fractional Days: $currentFractionalDays');
  // print('Current Fractional Days: $currentDate');

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('UpcomingMatchesForAllClubs')
      .orderBy('id', descending: false)
      .limit(50)
      .get();

  List<UpcomingMatchesForAllClubs> upcomingMatchesForAllClubsList = [];

  const String defaultImage = 'assets/images/no_club_icon_default.jpeg';

  // Loop through each upcoming match
  for (var document in snapshot.docs) {
    UpcomingMatchesForAllClubs upcomingMatchesForAllClubs = UpcomingMatchesForAllClubs.fromMap(document.data() as Map<String, dynamic>);

    // Check if home team matchesForAllClubs any banner team name
    bool homeTeamMatched = false;
    bool awayTeamMatched = false;

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (upcomingMatchesForAllClubs.homeTeam == banner.teamName) {
        upcomingMatchesForAllClubs.homeTeamIcon = banner.clubLogo;
        homeTeamMatched = true;
      }
      if (upcomingMatchesForAllClubs.awayTeam == banner.teamName) {
        upcomingMatchesForAllClubs.awayTeamIcon = banner.clubLogo;
        awayTeamMatched = true;
      }
    }

    // Match against the MatchDayBannerForClubOpp team names (for opposition teams)
    for (var oppBanner in matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList) {
      if (upcomingMatchesForAllClubs.homeTeam == oppBanner.clubName) {
        upcomingMatchesForAllClubs.homeTeamIcon = oppBanner.clubIcon;
        homeTeamMatched = true;
      }
      if (upcomingMatchesForAllClubs.awayTeam == oppBanner.clubName) {
        upcomingMatchesForAllClubs.awayTeamIcon = oppBanner.clubIcon;
        awayTeamMatched = true;
      }
    }

    // If no match is found for the home team, use the default image
    if (!homeTeamMatched) {
      upcomingMatchesForAllClubs.homeTeamIcon = defaultImage;
    }

    // If no match is found for the away team, use the default image
    if (!awayTeamMatched) {
      upcomingMatchesForAllClubs.awayTeamIcon = defaultImage;
    }

    upcomingMatchesForAllClubsList.add(upcomingMatchesForAllClubs);
  }

  upcomingMatchesForAllClubsNotifier.upcomingMatchesForAllClubsList = upcomingMatchesForAllClubsList;
}
