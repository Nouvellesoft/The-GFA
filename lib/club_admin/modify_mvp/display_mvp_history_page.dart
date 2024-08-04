import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/api/players_table_api.dart';
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
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPlayersTableAndUpdateNotifier();
  }

  Future<void> _fetchPlayersTableAndUpdateNotifier() async {
    PlayersTableNotifier playersTableNotifier = Provider.of<PlayersTableNotifier>(context, listen: false);
    await getPlayersTable(playersTableNotifier, widget.clubId);

    setState(() {
      _isLoading = false; // Stop loading after fetching data
    });
  }

  @override
  Widget build(BuildContext context) {
    PlayersTableNotifier playersTableNotifier = Provider.of<PlayersTableNotifier>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    List<PlayersTable> filteredPlayers = playersTableNotifier.playersTableList.where((player) => player.playerOfTheMonthCum! > 0).toList();

    // Sort the list based on playerOfTheMonthCum in descending order
    filteredPlayers.sort((a, b) => b.playerOfTheMonthCum!.compareTo(a.playerOfTheMonthCum!));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // You can add logic here to show/hide the scrollbar based on scroll position
            return true;
          },
          child: Scrollbar(
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
          ),
        ),
      ),
    );
  }
}
