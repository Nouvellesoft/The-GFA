import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/first_team_class_api.dart';
import '../model/first_team_class_model.dart';
import '../notifier/first_team_class_notifier.dart';

class ClubDetailPage extends StatefulWidget {
  final String clubId;

  const ClubDetailPage({required this.clubId, super.key});

  @override
  ClubDetailPageState createState() => ClubDetailPageState();
}

class ClubDetailPageState extends State<ClubDetailPage> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
    await getFirstTeamClass(firstTeamClassNotifier, widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context);
    List<FirstTeamClass> players = firstTeamClassNotifier.firstTeamClassList;

    return Scaffold(
      appBar: AppBar(title: Text('Details for ${widget.clubId}')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching players: ${snapshot.error}'));
          } else {
            if (players.isEmpty) {
              return const Center(child: Text('No players found'));
            } else {
              return ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index].name ?? 'Unknown'),
                    onTap: () {
                      // Handle player selection if needed
                      if (kDebugMode) {
                        print('Selected player: ${players[index].name}');
                      }
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
