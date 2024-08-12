class PlayersTable {
  // int? id;
  String? id;
  String? image;
  int? matchesPlayed;
  int? matchesStarted;
  int? matchesBenched;
  int? goalsScored;
  int? assists;
  String? playerPosition;
  String? nationality;
  String? manOfTheMatch;
  int? manOfTheMatchCum;
  String? playerOfTheMonth;
  int? playerOfTheMonthCum;
  int? yellowCard;
  int? redCard;
  String? playerName;

  PlayersTable.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    image = data['image'];
    matchesPlayed = data['matches_played'];
    matchesStarted = data['matches_started'];
    matchesBenched = data['matches_benched'];
    goalsScored = data['goals_scored'];
    assists = data['assists'];
    playerPosition = data['player_position'];
    nationality = data['nationality'];
    manOfTheMatchCum = data['man_of_the_match_cum'];
    playerOfTheMonth = data['player_of_the_month'];
    playerOfTheMonthCum = data['potm_cum'];
    yellowCard = data['yellow_card'];
    redCard = data['red_card'];
    playerName = data['player_name'];
  }
}
