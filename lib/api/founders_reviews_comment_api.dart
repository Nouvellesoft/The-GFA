import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../model/founders_reviews_comments_model.dart';
import '../notifier/founders_reviews_comment_notifier.dart';

String collectionSnapshotID = "clubs";
String subCollectionSnapshotID = "FoundersMonthlyComments";
String monthFieldsAnchorSnapshotID = "month";
String yearFieldsAnchorSnapshotID = "year";

const String monthFormat = 'MM';
const String yearFormat = 'yyyy';

Future<void> getFoundersReviewsComment(FoundersReviewsCommentNotifier foundersReviewsCommentNotifier, String clubId) async {
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

  List<FoundersReviewsComment> foundersReviewsCommentList = [];

  for (var document in snapshot.docs) {
    FoundersReviewsComment foundersReviewsComment = FoundersReviewsComment.fromMap(document.data() as Map<String, dynamic>);
    foundersReviewsCommentList.add(foundersReviewsComment);
  }

  foundersReviewsCommentNotifier.foundersReviewsCommentList = foundersReviewsCommentList;
}
