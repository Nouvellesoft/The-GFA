import 'package:intl/intl.dart';

class UpcomingMatchesForAllClubs {
  String? homeTeam;
  String? awayTeam;
  String? venue;
  DateTime? matchDate;
  String? matchDayKickOff;
  String? homeTeamIcon;
  String? awayTeamIcon;
  String? competition;
  dynamic id;

  UpcomingMatchesForAllClubs({
    this.homeTeam,
    this.awayTeam,
    this.venue,
    this.matchDate,
    this.matchDayKickOff,
    this.homeTeamIcon,
    this.awayTeamIcon,
    this.competition,
    this.id,
  });

  UpcomingMatchesForAllClubs.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    homeTeam = data['home_team'];
    awayTeam = data['away_team'];
    venue = data['venue'];
    matchDate = DateFormat('dd-MM-yyyy HH:mm:ss').parse(data['match_date']);
    matchDayKickOff = data['match_day_ko'];
    homeTeamIcon = data['home_team_icon'];
    awayTeamIcon = data['away_team_icon'];
    competition = data['competition'];
  }
}
