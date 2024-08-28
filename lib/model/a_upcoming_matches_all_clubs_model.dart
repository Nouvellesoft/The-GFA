class UpcomingMatchesForAllClubs {
  String? homeTeam;
  String? awayTeam;
  String? venue;
  String? matchDate;
  String? matchDayKickOff;
  String? homeTeamIcon;
  String? awayTeamIcon;
  dynamic id;

  UpcomingMatchesForAllClubs({
    this.homeTeam,
    this.awayTeam,
    this.venue,
    this.matchDate,
    this.matchDayKickOff,
    this.homeTeamIcon,
    this.awayTeamIcon,
    this.id,
  });

  UpcomingMatchesForAllClubs.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    homeTeam = data['home_team'];
    awayTeam = data['away_team'];
    venue = data['venue'];
    matchDate = data['match_date'];
    matchDayKickOff = data['match_day_ko'];
    homeTeamIcon = data['home_team_icon'];
    awayTeamIcon = data['away_team_icon'];
  }
}
