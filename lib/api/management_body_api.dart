import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/management_body_model.dart';
import '../notifier/management_body_notifier.dart';

Future<void> getManagementBody(ManagementBodyNotifier managementBodyNotifier, String clubId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('ManagementBody').orderBy('id').get();

  List<ManagementBody> managementBodyList = [];

  for (var document in snapshot.docs) {
    ManagementBody managementBody = ManagementBody.fromMap(document.data() as Map<String, dynamic>);
    managementBodyList.add(managementBody);
  }

  managementBodyNotifier.managementBodyList = managementBodyList;
}
