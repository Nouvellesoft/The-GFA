import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/coaches_model.dart';
import '../notifier/coaching_staff_notifier.dart';

Future<void> getCoaches(CoachesNotifier coachesNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('Coaches').orderBy('id').get();

  List<Coaches> coachesList = [];

  for (var document in snapshot.docs) {
    Coaches coaches = Coaches.fromMap(document.data() as Map<String, dynamic>);
    coachesList.add(coaches);
  }

  coachesNotifier.coachesList = coachesList;
}
