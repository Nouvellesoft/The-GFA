import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/bloc_navigation_bloc/navigation_bloc.dart';
import '../../api/fifth_team_class_api.dart';
import '../../api/first_team_class_api.dart';
import '../../api/fourth_team_class_api.dart';
import '../../api/get_teams_visibility_api.dart'; // Import the visibility API
import '../../api/second_team_class_api.dart';
import '../../api/sixth_team_class_api.dart';
import '../../api/third_team_class_api.dart';
import '../../model/fifth_team_class.dart';
import '../../model/first_team_class.dart';
import '../../model/fourth_team_class.dart';
import '../../model/second_team_class.dart';
import '../../model/sixth_team_class.dart';
import '../../model/third_team_class.dart';
import '../../notifier/fifth_team_class_notifier.dart';
import '../../notifier/first_team_class_notifier.dart';
import '../../notifier/fourth_team_class_notifier.dart';
import '../../notifier/players_notifier.dart';
import '../../notifier/second_team_class_notifier.dart';
import '../../notifier/sixth_team_class_notifier.dart';
import '../../notifier/third_team_class_notifier.dart';

PlayersNotifier? playersNotifier;

Color backgroundColor = const Color.fromRGBO(187, 192, 195, 1.0);

class MyModifyClubPlayersPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyModifyClubPlayersPage({super.key, required this.clubId});

  @override
  State<MyModifyClubPlayersPage> createState() => MyModifyClubPlayersPageState();
}

class MyModifyClubPlayersPageState extends State<MyModifyClubPlayersPage> {
  bool isEditing = false; // Flag to determine if the user is in "Edit" mode
  List<dynamic> selectedPlayers = []; // List to store selected players
  late Future<Map<String, Map<String, dynamic>>> _teamVisibilityFuture;

  @override
  void initState() {
    super.initState();

    _teamVisibilityFuture = getTeamClassVisibilityAndTitles(widget.clubId);

    // Fetch data for the teams using their notifiers
    _fetchTeamData();
  }

  Future<void> _fetchTeamData() async {
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
    await _fetchFirstTeamClassAndUpdateNotifier(firstTeamClassNotifier);

    SecondTeamClassNotifier secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);
    await _fetchSecondTeamClassAndUpdateNotifier(secondTeamClassNotifier);

    ThirdTeamClassNotifier thirdTeamClassNotifier = Provider.of<ThirdTeamClassNotifier>(context, listen: false);
    await _fetchThirdTeamClassAndUpdateNotifier(thirdTeamClassNotifier);

    FourthTeamClassNotifier fourthTeamClassNotifier = Provider.of<FourthTeamClassNotifier>(context, listen: false);
    await _fetchFourthTeamClassAndUpdateNotifier(fourthTeamClassNotifier);

    FifthTeamClassNotifier fifthTeamClassNotifier = Provider.of<FifthTeamClassNotifier>(context, listen: false);
    await _fetchFifthTeamClassAndUpdateNotifier(fifthTeamClassNotifier);

    SixthTeamClassNotifier sixthTeamClassNotifier = Provider.of<SixthTeamClassNotifier>(context, listen: false);
    await _fetchSixthTeamClassAndUpdateNotifier(sixthTeamClassNotifier);

    PlayersNotifier playersNotifier = Provider.of<PlayersNotifier>(context, listen: false);
    playersNotifier.setFirstTeamPlayers(firstTeamClassNotifier.firstTeamClassList);
    playersNotifier.setSecondTeamPlayers(secondTeamClassNotifier.secondTeamClassList);
    playersNotifier.setThirdTeamPlayers(thirdTeamClassNotifier.thirdTeamClassList);
    playersNotifier.setFourthTeamPlayers(fourthTeamClassNotifier.fourthTeamClassList);
    playersNotifier.setFifthTeamPlayers(fifthTeamClassNotifier.fifthTeamClassList);
    playersNotifier.setSixthTeamPlayers(sixthTeamClassNotifier.sixthTeamClassList);
  }

  Future<void> _fetchFirstTeamClassAndUpdateNotifier(FirstTeamClassNotifier firstTeamNotifier) async {
    await getFirstTeamClass(firstTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchSecondTeamClassAndUpdateNotifier(SecondTeamClassNotifier secondTeamNotifier) async {
    await getSecondTeamClass(secondTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchThirdTeamClassAndUpdateNotifier(ThirdTeamClassNotifier thirdTeamClassNotifier) async {
    await getThirdTeamClass(thirdTeamClassNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchFourthTeamClassAndUpdateNotifier(FourthTeamClassNotifier fourthTeamClassNotifier) async {
    await getFourthTeamClass(fourthTeamClassNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchFifthTeamClassAndUpdateNotifier(FifthTeamClassNotifier fifthTeamClassNotifier) async {
    await getFifthTeamClass(fifthTeamClassNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchSixthTeamClassAndUpdateNotifier(SixthTeamClassNotifier sixthTeamClassNotifier) async {
    await getSixthTeamClass(sixthTeamClassNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> refreshData() async {
    await _fetchTeamData();
    setState(() {}); // Ensure the UI updates with the latest data
  }

  @override
  Widget build(BuildContext context) {
    // Use the PlayersNotifier to access the combined list of players
    playersNotifier = Provider.of<PlayersNotifier>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('All Players'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.done : Icons.edit),
            onPressed: () {
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
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: FutureBuilder<Map<String, Map<String, dynamic>>>(
          future: _teamVisibilityFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No visibility data available"));
            } else {
              final teamVisibility = snapshot.data!;

              // Filter players based on visibility
              List<dynamic> filteredPlayers = playersNotifier!.playersList.where((player) {
                if (player is FirstTeamClass && teamVisibility['FirstTeamClass']?['isVisible'] != true) {
                  return false;
                } else if (player is SecondTeamClass && teamVisibility['SecondTeamClass']?['isVisible'] != true) {
                  return false;
                } else if (player is ThirdTeamClass && teamVisibility['ThirdTeamClass']?['isVisible'] != true) {
                  return false;
                } else if (player is FourthTeamClass && teamVisibility['FourthTeamClass']?['isVisible'] != true) {
                  return false;
                } else if (player is FifthTeamClass && teamVisibility['FifthTeamClass']?['isVisible'] != true) {
                  return false;
                } else if (player is SixthTeamClass && teamVisibility['SixthTeamClass']?['isVisible'] != true) {
                  return false;
                } else {
                  return true;
                }
              }).toList();

              // Sort filtered players alphabetically by name
              filteredPlayers.sort((a, b) => (a.name ?? 'No Name').toLowerCase().compareTo((b.name ?? 'No Name').toLowerCase()));

              return RefreshIndicator(
                onRefresh: refreshData,
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.25),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      return true;
                    },
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = filteredPlayers[index];
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
              );
            }
          },
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
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
          : null,
    );
  }

  Future<void> deleteSelectedPlayers(List<dynamic> selectedPlayers) async {
    final firestore = FirebaseFirestore.instance;

    for (final player in selectedPlayers) {
      final name = player.name;

      // Delete from team collections
      await deletePlayerByName(firestore, 'FirstTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'SecondTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'ThirdTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'FourthTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'FifthTeamClassPlayers', name);
      await deletePlayerByName(firestore, 'SixthTeamClassPlayers', name);

      // Delete from PllayersTable collection
      await deletePlayerFromCollection(firestore, 'PllayersTable', name);
    }

    showSnackbar(selectedPlayers);

    await refreshData();
  }

  Future<void> deletePlayerByName(FirebaseFirestore firestore, String collection, String name) async {
    final querySnapshot = await firestore.collection('clubs').doc(widget.clubId).collection(collection).where('name', isEqualTo: name).get();

    for (final document in querySnapshot.docs) {
      await document.reference.delete();
    }
  }

  Future<void> deletePlayerFromCollection(FirebaseFirestore firestore, String collection, String name) async {
    final querySnapshot = await firestore.collection(collection).where('player_name', isEqualTo: name).get();

    for (final document in querySnapshot.docs) {
      await document.reference.delete();
    }
  }

  void showSnackbar(List<dynamic> players) {
    final snackBar = SnackBar(
      content: Text('${players.length} players have been removed: ${players.map((player) => player.name).join(", ")}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
