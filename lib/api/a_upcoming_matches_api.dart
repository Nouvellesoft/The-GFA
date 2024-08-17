import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_upcoming_matches_model.dart';
import '../notifier/a_upcoming_matches_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import '../notifier/a_club_global_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';
import 'c_match_day_banner_for_club_opp_api.dart';

Future<void> getUpcomingMatches(
  UpcomingMatchesNotifier upcomingMatchesNotifier,
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

  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('UpcomingMatches').orderBy('id', descending: false).limit(10).get();

  List<UpcomingMatches> upcomingMatchesList = [];

  const String defaultImage = 'assets/images/no_club_icon_default.jpeg';

  // Loop through each upcoming match
  for (var document in snapshot.docs) {
    UpcomingMatches upcomingMatch = UpcomingMatches.fromMap(document.data() as Map<String, dynamic>);

    // Check if home team matches any banner team name
    bool homeTeamMatched = false;
    bool awayTeamMatched = false;

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (upcomingMatch.homeTeam == banner.teamName) {
        upcomingMatch.homeTeamIcon = banner.clubLogo;
        homeTeamMatched = true;
      }
      if (upcomingMatch.awayTeam == banner.teamName) {
        upcomingMatch.awayTeamIcon = banner.clubLogo;
        awayTeamMatched = true;
      }
    }

    // Match against the MatchDayBannerForClubOpp team names (for opposition teams)
    for (var oppBanner in matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList) {
      if (upcomingMatch.homeTeam == oppBanner.clubName) {
        upcomingMatch.homeTeamIcon = oppBanner.clubIcon;
        homeTeamMatched = true;
      }
      if (upcomingMatch.awayTeam == oppBanner.clubName) {
        upcomingMatch.awayTeamIcon = oppBanner.clubIcon;
        awayTeamMatched = true;
      }
    }

    // If no match is found for the home team, use the default image
    if (!homeTeamMatched) {
      upcomingMatch.homeTeamIcon = defaultImage;
    }

    // If no match is found for the away team, use the default image
    if (!awayTeamMatched) {
      upcomingMatch.awayTeamIcon = defaultImage;
    }

    upcomingMatchesList.add(upcomingMatch);
  }

  upcomingMatchesNotifier.upcomingMatchesList = upcomingMatchesList;
}
