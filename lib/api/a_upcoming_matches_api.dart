import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_upcoming_matches_model.dart';
import '../notifier/a_upcoming_matches_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/club_global_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';

Future<void> getUpcomingMatches(
  UpcomingMatchesNotifier upcomingMatchesNotifier,
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier,
    ClubGlobalProvider clubGlobalProvider,
    String clubId,
) async {
  // Fetch MatchDayBannerForClub data
  await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalProvider, clubId);

  // DateTime currentDate = DateTime.now();
  // double currentFractionalDays = currentDate.millisecondsSinceEpoch / (1000 * 60 * 60 * 24);

  // print('Current Fractional Days: $currentFractionalDays');
  // print('Current Fractional Days: $currentDate');



  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('UpcomingMatches').orderBy('id', descending: false).limit(10).get();

  List<UpcomingMatches> upcomingMatchesList = [];

  // Loop through each upcoming match
  for (var document in snapshot.docs) {
    UpcomingMatches upcomingMatch = UpcomingMatches.fromMap(document.data() as Map<String, dynamic>);

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (upcomingMatch.homeTeam == banner.teamName) {
        upcomingMatch.homeTeamIcon = banner.clubIcon;
      }
      if (upcomingMatch.awayTeam == banner.teamName) {
        upcomingMatch.awayTeamIcon = banner.clubIcon;
      }
    }

    upcomingMatchesList.add(upcomingMatch);
  }

  upcomingMatchesNotifier.upcomingMatchesList = upcomingMatchesList;
}