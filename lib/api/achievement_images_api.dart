import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/achievements_model.dart';
import '../notifier/achievement_images_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "AchievementImages";

Future<void> getAchievements(AchievementsNotifier achievementsNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionSnapshotID).doc(clubId).collection(subCollectionSnapshotID).get();

  List<Achievements> achievementsList = [];

  for (var document in snapshot.docs) {
    Achievements achievements = Achievements.fromMap(document.data() as Map<String, dynamic>);
    achievementsList.add(achievements);
  }

  achievementsNotifier.achievementsList = achievementsList;
}
