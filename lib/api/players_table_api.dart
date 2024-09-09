import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/fifth_team_class_model.dart';
import '../model/first_team_class_model.dart';
import '../model/fourth_team_class_model.dart';
import '../model/players_table_model.dart';
import '../model/second_team_class_model.dart';
import '../model/sixth_team_class_model.dart';
import '../model/third_team_class_model.dart';
import '../notifier/players_table_notifier.dart';
import 'get_teams_classes_visibility_api.dart';

String collectionSnapshotID = "clubs";
String fieldsAnchorSnapshotID = "name";

String subCollectionSnapshotIDTwo = "PllayersTable";
String fieldsAnchorSnapshotIDTwo = "goals_scored";
String fieldsAnchorSnapshotIDThree = "player_name";

String firstTeamClassPlayersTitle = 'FirstTeamClassPlayers';
String secondTeamClassPlayersTitle = 'SecondTeamClassPlayers';
String thirdTeamClassPlayersTitle = 'ThirdTeamClassPlayers';
String fourthTeamClassPlayersTitle = 'FourthTeamClassPlayers';
String fifthTeamClassPlayersTitle = 'FifthTeamClassPlayers';
String sixthTeamClassPlayersTitle = 'SixthTeamClassPlayers';

String teamClassModelVisibilityCheckTitle = 'isVisible';

Future<void> getPlayersTable(PlayersTableNotifier playersTableNotifier, String clubId, {bool orderByGoalsScored = true}) async {
  // Get visibility data
  Map<String, Map<String, dynamic>> visibilityData = await getTeamClassVisibilityAndTitles(clubId);

  // Create a set to hold names of players in visible teams
  Set<String> validPlayerNames = {};

  // List of team collections and their corresponding models
  Map<String, Function(Map<String, dynamic>)> teamModels = {
    firstTeamClassPlayersTitle: (data) => FirstTeamClass.fromMap(data),
    secondTeamClassPlayersTitle: (data) => SecondTeamClass.fromMap(data),
    thirdTeamClassPlayersTitle: (data) => ThirdTeamClass.fromMap(data),
    fourthTeamClassPlayersTitle: (data) => FourthTeamClass.fromMap(data),
    fifthTeamClassPlayersTitle: (data) => FifthTeamClass.fromMap(data),
    sixthTeamClassPlayersTitle: (data) => SixthTeamClass.fromMap(data),
  };

  // Fetch valid player names from visible teams
  for (String teamCollection in teamModels.keys) {
    // Extract the team name by removing 'Players' suffix
    String teamName = teamCollection.replaceAll('Players', '');

    // Check visibility using the extracted team name
    Map<String, dynamic>? teamVisibility = visibilityData[teamName];
    bool isTeamVisible = teamVisibility != null && (teamVisibility[teamClassModelVisibilityCheckTitle] as bool? ?? false);

    if (isTeamVisible) {
      // Fetch players from the visible team
      QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection(collectionSnapshotID)
          .doc(clubId)
          .collection(teamCollection)
          .orderBy(fieldsAnchorSnapshotID)
          .get();

      // Add player names to the set based on the corresponding model
      validPlayerNames.addAll(teamSnapshot.docs.map((doc) {
        var model = teamModels[teamCollection];
        if (model != null) {
          var player = model(doc.data() as Map<String, dynamic>);
          return player.name ?? '';
        }
        return '';
      }));
    }
  }

  // Fetch PlayersTable and filter by the valid player names
  Query playersQuery = FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotIDTwo);

  if (orderByGoalsScored) {
    playersQuery = playersQuery.orderBy(fieldsAnchorSnapshotIDTwo, descending: true);
  } else {
    playersQuery = playersQuery.orderBy(fieldsAnchorSnapshotIDThree, descending: false);
  }

  QuerySnapshot playersTableSnapshot = await playersQuery.get();

  List<PlayersTable> filteredPlayersTableList = playersTableSnapshot.docs
      .map((doc) => PlayersTable.fromMap(doc.data() as Map<String, dynamic>))
      .where((player) => validPlayerNames.contains(player.playerName))
      .toList();

  playersTableNotifier.playersTableList = filteredPlayersTableList;
}
