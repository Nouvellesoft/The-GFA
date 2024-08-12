// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../model/fifth_team_class_model.dart';
// import '../model/first_team_class_model.dart';
// import '../model/fourth_team_class_model.dart';
// import '../model/players_table_model.dart';
// import '../model/second_team_class_model.dart';
// import '../model/sixth_team_class_model.dart';
// import '../model/third_team_class_model.dart';
// import '../notifier/players_table_notifier.dart';
// import 'get_teams_visibility_api.dart';
//
// Future<void> getPlayersTable(PlayersTableNotifier playersTableNotifier, String clubId, {bool orderByGoalsScored = true}) async {
//   // Get visibility data
//   Map<String, Map<String, dynamic>> visibilityData = await getTeamClassVisibilityAndTitles(clubId);
//
//   // Create a set to hold names of players in visible teams
//   Set<String> validPlayerNames = {};
//
//   // List of team collections and their corresponding models
//   Map<String, Function(Map<String, dynamic>)> teamModels = {
//     'FirstTeamClassPlayers': (data) => FirstTeamClass.fromMap(data),
//     'SecondTeamClassPlayers': (data) => SecondTeamClass.fromMap(data),
//     'ThirdTeamClassPlayers': (data) => ThirdTeamClass.fromMap(data),
//     'FourthTeamClassPlayers': (data) => FourthTeamClass.fromMap(data),
//     'FifthTeamClassPlayers': (data) => FifthTeamClass.fromMap(data),
//     'SixthTeamClassPlayers': (data) => SixthTeamClass.fromMap(data),
//   };
//
//   for (String teamCollection in teamModels.keys) {
//     // Extract the team name by removing 'Players' suffix
//     String teamName = teamCollection.replaceAll('Players', '');
//
//     // Check visibility using the extracted team name
//     Map<String, dynamic>? teamVisibility = visibilityData[teamName];
//     bool isTeamVisible = teamVisibility != null && (teamVisibility['isVisible'] as bool? ?? false);
//
//     if (isTeamVisible) {
//       // Fetch players from the visible team
//       QuerySnapshot teamSnapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection(teamCollection).orderBy('name').get();
//
//       // Add player names to the set based on the corresponding model
//       validPlayerNames.addAll(teamSnapshot.docs.map((doc) {
//         var model = teamModels[teamCollection];
//         if (model != null) {
//           var player = model(doc.data() as Map<String, dynamic>);
//           return player.name ?? '';
//         }
//         return '';
//       }));
//     }
//   }
//
//   // Fetch PlayersTable and filter by the valid player names
//   Query playersQuery = FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('PllayersTable');
//
//   if (orderByGoalsScored) {
//     playersQuery = playersQuery.orderBy('goals_scored', descending: true);
//   }
//
//   playersQuery = playersQuery.orderBy('player_name', descending: false);
//
//   QuerySnapshot playersTableSnapshot = await playersQuery.get();
//
//   List<PlayersTable> filteredPlayersTableList = playersTableSnapshot.docs
//       .map((doc) => PlayersTable.fromMap(doc.data() as Map<String, dynamic>))
//       .where((player) => validPlayerNames.contains(player.playerName))
//       .toList();
//
//   playersTableNotifier.playersTableList = filteredPlayersTableList;
// }
