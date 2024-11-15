import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/api/c_match_day_banner_for_club_api.dart';
import '../../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../../model/c_match_day_banner_for_clubs_model.dart';
import '../../../notifier/c_match_day_banner_for_club_notifier.dart';
import '../../../notifier/a_club_global_notifier.dart';

late MatchDayBannerForClubNotifier matchDayBannerForClubNotifier;

class MyRemoveNewHomeTeamPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyRemoveNewHomeTeamPage({super.key, required this.clubId});

  @override
  State<MyRemoveNewHomeTeamPage> createState() => MyRemoveNewHomeTeamPageState();
}

class MyRemoveNewHomeTeamPageState extends State<MyRemoveNewHomeTeamPage> {
  bool isEditing = false; // Flag to determine if user is in "Edit" mode
  List<MatchDayBannerForClub> selectedHomeTeams = []; // List to store selected home teams

  @override
  Widget build(BuildContext context) {
    matchDayBannerForClubNotifier = Provider.of<MatchDayBannerForClubNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.accessibility, color: Colors.black38),
          onPressed: () {},
        ),
        title: const Text('Remove Home Teams'),
        actions: [
          // Add a button to toggle "Edit" mode
          IconButton(
            icon: Icon(
              isEditing ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              // Toggle "Edit" mode and clear selected home teams list
              setState(() {
                isEditing = !isEditing;
                selectedHomeTeams.clear();
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
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.25),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // You can add logic here to show/hide the scrollbar based on scroll position
              return true;
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: matchDayBannerForClubNotifier.matchDayBannerForClubList.length, // Replace with your actual list of home teams
                itemBuilder: (context, index) {
                  final homeTeamName = matchDayBannerForClubNotifier.matchDayBannerForClubList[index]; // Replace with your actual data structure
                  return ListTile(
                    title: Text(homeTeamName.teamName!),
                    trailing: isEditing
                        ? Checkbox(
                            activeColor: const Color.fromRGBO(147, 165, 193, 1.0),
                            checkColor: Colors.white,
                            value: selectedHomeTeams.contains(homeTeamName),
                            onChanged: (value) {
                              setState(() {
                                if (value != null && value) {
                                  selectedHomeTeams.add(homeTeamName);
                                } else {
                                  selectedHomeTeams.remove(homeTeamName);
                                }
                              });
                            },
                          )
                        : null, // Show checkbox only in "Edit" mode
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomSheet: isEditing
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                color: const Color.fromRGBO(147, 165, 193, 1.0),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.27,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const Text(
                    //   'Selected\nHome Teams:',
                    //   style: TextStyle(
                    //       fontSize: 13,
                    //     fontWeight: FontWeight.w600
                    //   ),
                    // ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Set the scroll direction to horizontal
                        child: Wrap(
                          children: selectedHomeTeams.map((homeTeams) {
                            return Chip(
                              label: Text(
                                homeTeams.teamName ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setState(() {
                                  selectedHomeTeams.remove(homeTeams);
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
                        // Implement logic to delete selected home teams
                        await deleteSelectedHomeTeams(selectedHomeTeams);
                        // Clear selected home teams list after deletion
                        setState(() {
                          selectedHomeTeams.clear();
                        });
                      },
                      child: const Text(
                        'Delete Selected',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null, // Show selected home teams at the bottom only in "Edit" mode
    );
  }

  // Implement your logic to delete selected home teams
  Future<void> deleteSelectedHomeTeams(List<MatchDayBannerForClub> selectedHomeTeams) async {
    final firestore = FirebaseFirestore.instance;

    // Create a list to hold updated management after deletion
    final updatedList = List<MatchDayBannerForClub>.from(matchDayBannerForClubNotifier.matchDayBannerForClubList);

    // Iterate through the selected management and delete them
    for (final homeTeams in selectedHomeTeams) {
      final homeTeamsName = homeTeams.teamName; // Get the name of the clubCaptains
      if (homeTeamsName != null) {
        // Delete management with matching names
        await firestore
            .collection('clubs')
            .doc(widget.clubId)
            .collection('MatchDayBannerForClub')
            .where('team_name', isEqualTo: homeTeamsName)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });

        // Remove the clubCaptains from the updated list
        updatedList.remove(homeTeams);
      }
    }

    // Update the home teams list in the notifier
    matchDayBannerForClubNotifier.matchDayBannerForClubList = updatedList;
  }

  @override
  void initState() {
    ClubGlobalProvider clubGlobalNotifier = Provider.of<ClubGlobalProvider>(context, listen: false);
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier = Provider.of<MatchDayBannerForClubNotifier>(context, listen: false);
    _fetchMatchDayBannerForClubAndUpdateNotifier(matchDayBannerForClubNotifier, clubGlobalNotifier);

    super.initState();
  }

  Future<void> _fetchMatchDayBannerForClubAndUpdateNotifier(
      MatchDayBannerForClubNotifier matchDayBannerForClubNotifier, ClubGlobalProvider clubGlobalNotifier) async {
    await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }
}
