import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingMatches {
  String? homeTeam;
  String? awayTeam;
  String? venue;
  String? matchDate;
  String? matchDayKickOff;
  String? homeTeamIcon;
  String? awayTeamIcon;
  dynamic id;

  UpcomingMatches({
    this.homeTeam,
    this.awayTeam,
    this.venue,
    this.matchDate,
    this.matchDayKickOff,
    this.homeTeamIcon,
    this.awayTeamIcon,
    this.id,
  });

  UpcomingMatches.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    homeTeam = data['home_team'];
    awayTeam = data['away_team'];
    venue = data['venue'];
    matchDate = data['match_date'];
    matchDayKickOff = data['match_day_ko'];
    homeTeamIcon = data['home_team_icon'];
    awayTeamIcon = data['away_team_icon'];
  }


  // Method to update the team icons based on the club's ID
  Future<void> updateClubIcon(String clubId, String clubIcon) async {
    // Check if the home or away team is part of a special match day banner for the club
    if (await _checkTeamInMatchDayBanner(clubId, homeTeam!)) {
      homeTeamIcon = clubIcon;
    }
    if (await _checkTeamInMatchDayBanner(clubId, awayTeam!)) {
      awayTeamIcon = clubIcon;
    }
  }

  // Helper method to check if a team is part of the club's match day banner
  Future<bool> _checkTeamInMatchDayBanner(String clubId, String teamName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .collection('MatchDayBannerForClub')
        .where('team_name', isEqualTo: teamName)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}