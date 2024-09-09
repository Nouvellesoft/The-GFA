import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../model/coaches_reviews_comments_model.dart';
import '../notifier/coaches_reviews_comment_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "CoachesMonthlyComments";
String monthFieldsAnchorSnapshotID = "month";
String yearFieldsAnchorSnapshotID = "year";

const String monthFormat = 'MM';
const String yearFormat = 'yyyy';

Future<void> getCoachesReviewsComment(CoachesReviewsCommentNotifier coachesReviewsCommentNotifier, String clubId) async {
  DateTime currentDateTime = DateTime.now();
  String currentMonth = DateFormat(monthFormat).format(currentDateTime);
  String currentYear = DateFormat(yearFormat).format(currentDateTime);

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionSnapshotID)
      .doc(clubId)
      .collection(subCollectionSnapshotID)
      .where(monthFieldsAnchorSnapshotID, isEqualTo: currentMonth)
      .where(yearFieldsAnchorSnapshotID, isEqualTo: currentYear)
      // .where('comment', whereNotIn: [""])
      .get();

  List<CoachesReviewsComment> coachesReviewsCommentList = [];

  for (var document in snapshot.docs) {
    CoachesReviewsComment coachesReviewsComment = CoachesReviewsComment.fromMap(document.data() as Map<String, dynamic>);
    coachesReviewsCommentList.add(coachesReviewsComment);
  }

  coachesReviewsCommentNotifier.coachesReviewsCommentList = coachesReviewsCommentList;
}

//// For Previous Month Comparison

// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../model/coaches_reviews_comments_model.dart';
// import '../notifier/coaches_reviews_comment_notifier.dart';
//
// getCoachesReviewsComment(
//     CoachesReviewsCommentNotifier coachesReviewsCommentNotifier) async {
//   DateTime currentDateTime = DateTime.now();
//   DateTime lastMonthDateTime =
//   DateTime(currentDateTime.year, currentDateTime.month - 1);
//
//   String currentMonth = DateFormat('MM').format(currentDateTime);
//   String currentYear = DateFormat('yyyy').format(currentDateTime);
//   String lastMonth = DateFormat('MM').format(lastMonthDateTime);
//   String lastYear = DateFormat('yyyy').format(lastMonthDateTime);
//
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection('CoachesMonthlyComments')
//       .where('(year = $currentYear AND month = $currentMonth) OR (year = $lastYear AND month = $lastMonth)')
//       .where('comment', whereNotIn: [""])
//       .get();
//
//   List<CoachesReviewsComment> coachesReviewsCommentList = [];
//
//   for (var document in snapshot.docs) {
//     CoachesReviewsComment coachesReviewsComment =
//     CoachesReviewsComment.fromMap(document.data() as Map<String, dynamic>);
//     coachesReviewsCommentList.add(coachesReviewsComment);
//   }
//
//   coachesReviewsCommentNotifier.coachesReviewsCommentList =
//       coachesReviewsCommentList;
// }
