import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/bloc_navigation_bloc/navigation_bloc.dart';
import '../../api/first_team_class_api.dart';
import '../../api/second_team_class_api.dart';
import '../../notifier/first_team_class_notifier.dart';
import '../../notifier/players_notifier.dart';
import '../../notifier/second_team_class_notifier.dart';

PlayersNotifier? playersNotifier;

Color backgroundColor = const Color.fromRGBO(187, 192, 195, 1.0);

class MyModifyClubPlayersPage extends StatefulWidget implements NavigationStates {
  const MyModifyClubPlayersPage({super.key});

  @override
  State<MyModifyClubPlayersPage> createState() => MyModifyClubPlayersPageState();
}

class MyModifyClubPlayersPageState extends State<MyModifyClubPlayersPage> {
  bool isEditing = false; // Flag to determine if the user is in "Edit" mode
  List<dynamic> selectedPlayers = []; // List to store selected players

  @override
  Widget build(BuildContext context) {
    // Use the PlayersNotifier to access the combined list of players
    playersNotifier = Provider.of<PlayersNotifier>(context);

    // Create a copy of the allClubMembersList and sort it alphabetically by name
    List<dynamic> sortedPlayers = List.from(playersNotifier!.playersList);
    sortedPlayers.sort((a, b) => (a.name ?? 'No Name').toLowerCase().compareTo((b.name ?? 'No Name').toLowerCase()));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('All Players'),
        actions: [
          // Add a button to toggle "Edit" mode
          IconButton(
            icon: Icon(isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              // Toggle "Edit" mode and clear selected players list
              setState(() {
                isEditing = !isEditing;
                selectedPlayers.clear();
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Hide the keyboard when tapping outside the text field
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh the data when the user pulls down the list
            await refreshData();
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.25),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // You can add logic here to show/hide the scrollbar based on scroll position
                return true;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = sortedPlayers[index];
                    return ListTile(
                      title: Text(player.name ?? 'No Name'),
                      trailing: isEditing
                          ? Checkbox(
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              value: selectedPlayers.contains(player),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedPlayers.add(player);
                                  } else {
                                    selectedPlayers.remove(player);
                                  }
                                });
                              },
                            )
                          : null, // Show checkbox only in "Edit" mode
                      // Add other player information you want to display
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: isEditing
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.27,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // const Text('Selected\nPlayers:'),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Set the scroll direction to horizontal
                        child: Wrap(
                          children: selectedPlayers.map((player) {
                            return Chip(
                              label: Text(
                                player.name ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setState(() {
                                  selectedPlayers.remove(player);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        await deleteSelectedPlayers(selectedPlayers);
                        // Clear selected players list after deletion
                        setState(() {
                          selectedPlayers.clear();
                        });
                      },
                      child: const Text(
                        'Delete Selected',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null, // Show selected players at the bottom only in "Edit" mode
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch data for the first and second teams using their notifiers
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
    _fetchFirstTeamClassAndUpdateNotifier(firstTeamClassNotifier);

    SecondTeamClassNotifier secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);
    _fetchSecondTeamClassAndUpdateNotifier(secondTeamClassNotifier);

    // Populate the PlayersNotifier with data from both teams
    PlayersNotifier playersNotifier = Provider.of<PlayersNotifier>(context, listen: false);

    playersNotifier.setFirstTeamPlayers(firstTeamClassNotifier.firstTeamClassList);
    playersNotifier.setSecondTeamPlayers(secondTeamClassNotifier.secondTeamClassList);
  }

  Future<void> _fetchFirstTeamClassAndUpdateNotifier(FirstTeamClassNotifier firstTeamNotifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getFirstTeamClass(firstTeamNotifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchSecondTeamClassAndUpdateNotifier(SecondTeamClassNotifier secondTeamNotifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getSecondTeamClass(secondTeamNotifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> deleteSelectedPlayers(List<dynamic> selectedPlayers) async {
    final firestore = FirebaseFirestore.instance;

    // Iterate through the selected players and delete them
    for (final player in selectedPlayers) {
      // Assuming 'name' is a unique identifier
      final name = player.name;

      // Delete from both collections
      await deletePlayerByName(firestore, 'FirstTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'SecondTeamClassPlayers', name);
    }

    // Show a Snackbar message indicating the players that have been removed
    showSnackbar(selectedPlayers);

    // Refresh the data to trigger a UI update
    await refreshData();
  }

  Future<void> deletePlayerByName(FirebaseFirestore firestore, String collection, String name) async {
    final querySnapshot = await firestore.collection(collection).where('name', isEqualTo: name).get();

    for (final document in querySnapshot.docs) {
      await document.reference.delete();
    }
  }

  Future<void> refreshData() async {
    // Assuming you have a method to fetch or update player data in your notifier
    // Replace the following line with the actual logic to update your data
    // await playersNotifier!.fetchData(); // Replace 'fetchData()' with your actual method

    // After refreshing, call setState to trigger a UI update
    setState(() {});
  }

  void showSnackbar(List<dynamic> players) {
    final snackBar = SnackBar(
      content: Text('${players.length} players have been removed: ${players.map((player) => player.name).join(", ")}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
