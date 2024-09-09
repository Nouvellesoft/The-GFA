import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/trainings_and_games_reels_model.dart';
import '../notifier/trainings_games_reels_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "TrainingsAndGamesReels";
String fieldsAnchorSnapshotID = "id";

Future<void> getTrainingsAndGamesReels(TrainingsAndGamesReelsNotifier trainingsAndGamesReelsNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .orderBy(fieldsAnchorSnapshotID, descending: true)
      .limit(20)
      .get();

  List<TrainingsAndGamesReels> trainingsAndGamesReelsList = [];

  for (var document in snapshot.docs) {
    TrainingsAndGamesReels trainingsAndGamesReels = TrainingsAndGamesReels.fromMap(document.data() as Map<String, dynamic>);
    trainingsAndGamesReelsList.add(trainingsAndGamesReels);
  }

  trainingsAndGamesReelsNotifier.trainingsAndGamesReelsList = trainingsAndGamesReelsList;
}
