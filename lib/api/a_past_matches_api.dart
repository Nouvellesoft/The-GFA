import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/a_past_matches_model.dart';
import '../notifier/a_past_matches_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/club_global_notifier.dart';
import 'c_match_day_banner_for_club_api.dart';

Future<void> getPastMatches(PastMatchesNotifier pastMatchesNotifier,  MatchDayBannerForClubNotifier matchDayBannerForClubNotifier,
    ClubGlobalProvider clubGlobalProvider,
    String clubId,
    ) async {
  // Fetch MatchDayBannerForClub data
  await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalProvider, clubId);


  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('PastMatches').orderBy('id', descending: true).limit(20).get();

  List<PastMatches> pastMatchesList = [];

  // Function to parse date strings and compare them
  // int compareDate(String dateString1, String dateString2) {
  //   DateTime date1 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString1);
  //   DateTime date2 = DateFormat('dd-MM-yyyy HH:mm').parse(dateString2);
  //   return date2.compareTo(date1); // Compare in descending order
  // }

  // Sort documents based on the custom comparison function
  // snapshot.docs.sort((a, b) => compareDate(a['match_date'], b['match_date']));

  for (var document in snapshot.docs) {
    PastMatches pastMatches = PastMatches.fromMap(document.data() as Map<String, dynamic>);

    // Match against the MatchDayBannerForClub team names
    for (var banner in matchDayBannerForClubNotifier.matchDayBannerForClubList) {
      if (pastMatches.homeTeam == banner.teamName) {
        pastMatches.homeTeamIcon = banner.clubIcon;
      }
      if (pastMatches.awayTeam == banner.teamName) {
        pastMatches.awayTeamIcon = banner.clubIcon;
      }
    }

    pastMatchesList.add(pastMatches);
  }

  pastMatchesNotifier.pastMatchesList = pastMatchesList;
}
