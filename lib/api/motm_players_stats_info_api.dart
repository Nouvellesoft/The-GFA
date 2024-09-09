import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/fifth_team_class_model.dart';
import '../model/first_team_class_model.dart';
import '../model/fourth_team_class_model.dart';
import '../model/players_stats_and_info_model.dart';
import '../model/second_team_class_model.dart';
import '../model/sixth_team_class_model.dart';
import '../model/third_team_class_model.dart';
import '../notifier/motm_players_stats_info_notifier.dart';
import 'get_teams_classes_visibility_api.dart';

String collectionSnapshotID = "clubs";
String fieldsAnchorSnapshotID = "name";

String subCollectionSnapshotIDTwo = "PllayersTable";
String fieldsAnchorSnapshotIDTwo = "man_of_the_match";

String firstTeamClassPlayersTitle = 'FirstTeamClassPlayers';
String secondTeamClassPlayersTitle = 'SecondTeamClassPlayers';
String thirdTeamClassPlayersTitle = 'ThirdTeamClassPlayers';
String fourthTeamClassPlayersTitle = 'FourthTeamClassPlayers';
String fifthTeamClassPlayersTitle = 'FifthTeamClassPlayers';
String sixthTeamClassPlayersTitle = 'SixthTeamClassPlayers';

String teamClassModelVisibilityCheckTitle = 'isVisible';

Future<void> getMOTMPlayersStatsAndInfo(MOTMPlayersStatsAndInfoNotifier mOTMPlayersStatsAndInfoNotifier, String clubId) async {
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

  for (String teamCollection in teamModels.keys) {
    // Extract the team name by removing 'Players' suffix
    String teamName = teamCollection.replaceAll('Players', '');

    // Check visibility using the extracted team name
    Map<String, dynamic>? teamVisibility = visibilityData[teamName];
    bool isTeamVisible = teamVisibility != null && (teamVisibility[teamClassModelVisibilityCheckTitle] as bool? ?? false);

    if (isTeamVisible) {
      // Fetch player names from the visible team collection
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

  List<String> generateYesVariations(String word) {
    Set<String> variations = {};

    // Generate all combinations of upper and lowercase letters
    int n = word.length;
    for (int i = 0; i < (1 << n); i++) {
      String variation = '';
      for (int j = 0; j < n; j++) {
        if ((i & (1 << j)) != 0) {
          variation += word[j].toUpperCase();
        } else {
          variation += word[j].toLowerCase();
        }
      }
      variations.add(variation);
    }

    return variations.toList();
  }

  // Generate variations of "yes"
  List<String> yesVariations = generateYesVariations('yes');

  // Firestore query using dynamically generated variations
  QuerySnapshot playersTableSnapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotIDTwo)
      .where(fieldsAnchorSnapshotIDTwo, whereIn: yesVariations)
      .limit(1)
      .get();

  List<PlayersStatsAndInfo> mOTMPlayersStatsAndInfoList = playersTableSnapshot.docs
      .map((doc) => PlayersStatsAndInfo.fromMap(doc.data() as Map<String, dynamic>))
      .where((player) => validPlayerNames.contains(player.playerName))
      .toList();

  mOTMPlayersStatsAndInfoNotifier.mOTMPlayersStatsAndInfoList = mOTMPlayersStatsAndInfoList;
}
