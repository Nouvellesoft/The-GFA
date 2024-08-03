import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/players_table.dart';
import '../../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../../notifier/players_table_notifier.dart';

Color backgroundColor = const Color.fromRGBO(187, 192, 195, 1.0);

class MyDisplayedMVPHistoryPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyDisplayedMVPHistoryPage({super.key, required this.clubId});

  @override
  State<MyDisplayedMVPHistoryPage> createState() => MyDisplayedMVPHistoryPageState();
}

class MyDisplayedMVPHistoryPageState extends State<MyDisplayedMVPHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('PllayersTable').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final playersTableNotifier = Provider.of<PlayersTableNotifier>(context);
            playersTableNotifier.playersTableList = snapshot.data!.docs.map((doc) {
              return PlayersTable.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            final filteredPlayers = playersTableNotifier.playersTableList.where((player) => player.playerOfTheMonthCum! > 0).toList();

            // Sort the list based on playerOfTheMonthCum in descending order
            filteredPlayers.sort((a, b) => b.playerOfTheMonthCum!.compareTo(a.playerOfTheMonthCum!));

            return Scrollbar(
              child: ListView.builder(
                itemCount: filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];

                  return InkWell(
                    splashColor: Colors.black54,
                    onTap: () async {
                      // Handle onTap logic if needed
                    },
                    child: ListTile(
                      title: Text(
                        '${player.playerName ?? 'No Name'} (${player.playerOfTheMonthCum}X MVP)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
