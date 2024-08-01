import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/players_stats_and_info.dart';
import '../notifier/top_goals_players_stats_info_notifier.dart';

Future<void> getTopGoalsPlayersStatsAndInfo(TopGoalsPlayersStatsAndInfoNotifier topGoalsPlayersStatsAndInfoNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('PllayersTable')
      .where('goals_scored', isGreaterThan: 0)
      .orderBy('goals_scored', descending: true)
      .limit(10)
      .get();

  List<PlayersStatsAndInfo> topGoalsPlayersStatsAndInfoList = [];

  for (var document in snapshot.docs) {
    PlayersStatsAndInfo playersStatsAndInfo = PlayersStatsAndInfo.fromMap(document.data() as Map<String, dynamic>);
    topGoalsPlayersStatsAndInfoList.add(playersStatsAndInfo);
  }

  topGoalsPlayersStatsAndInfoNotifier.topGoalsPlayersStatsAndInfoList = topGoalsPlayersStatsAndInfoList;
}
