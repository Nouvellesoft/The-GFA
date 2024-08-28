class PastMatchesForAllClubs {
  String? assistsBy;
  String? goalsScorers;
  String? homeTeam;
  String? awayTeam;
  String? awayTeamScore;
  String? homeTeamScore;
  String? matchDate;
  String? homeTeamIcon;
  String? awayTeamIcon;
  String? ultimateScore;
  String? competition;
  dynamic id;

  PastMatchesForAllClubs({
    this.assistsBy,
    this.goalsScorers,
    this.homeTeam,
    this.awayTeam,
    this.awayTeamScore,
    this.homeTeamScore,
    this.matchDate,
    this.homeTeamIcon,
    this.awayTeamIcon,
    this.ultimateScore,
    this.competition,
    this.id,
  });

  PastMatchesForAllClubs.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    assistsBy = data['assists_by'];
    goalsScorers = data['goalscorers'];
    homeTeam = data['home_team'];
    awayTeam = data['away_team'];
    awayTeamScore = data['at_score'];
    homeTeamScore = data['ht_score'];
    matchDate = data['match_date'];
    homeTeamIcon = data['home_team_icon'];
    awayTeamIcon = data['away_team_icon'];
    ultimateScore = data['ultimate_score'];
    competition = data['competition'];
  }
}
