import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/c_match_day_banner_for_location_api.dart';
import '../../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../../model/c_match_day_banner_for_location.dart';
import '../../../notifier/c_match_day_banner_for_location_notifier.dart';

late MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier;

class MyRemoveNewLocationPage extends StatefulWidget implements NavigationStates {
  const MyRemoveNewLocationPage({super.key});

  @override
  State<MyRemoveNewLocationPage> createState() => MyRemoveNewLocationPageState();
}

class MyRemoveNewLocationPageState extends State<MyRemoveNewLocationPage> {
  bool isEditing = false; // Flag to determine if the user is in "Edit" mode
  List<MatchDayBannerForLocation> selectedLocations = []; // List to store selected locations

  @override
  Widget build(BuildContext context) {
    matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.accessibility, color: Colors.black38),
          onPressed: () {},
        ),
        title: const Text('Remove Locations'),
        actions: [
          // Add a button to toggle "Edit" mode
          IconButton(
            icon: Icon(
              isEditing ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              // Toggle "Edit" mode and clear selected locations list
              setState(() {
                isEditing = !isEditing;
                selectedLocations.clear();
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
                itemCount: matchDayBannerForLocationNotifier.matchDayBannerForLocationList.length,
                itemBuilder: (context, index) {
                  final locationName = matchDayBannerForLocationNotifier.matchDayBannerForLocationList[index];
                  return ListTile(
                    title: Text(locationName.location!),
                    trailing: isEditing
                        ? Checkbox(
                            activeColor: const Color.fromRGBO(147, 165, 193, 1.0),
                            checkColor: Colors.white,
                            value: selectedLocations.contains(locationName),
                            onChanged: (value) {
                              setState(() {
                                if (value != null && value) {
                                  selectedLocations.add(locationName);
                                } else {
                                  selectedLocations.remove(locationName);
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
                    //   'Selected\nLocations:',
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
                          children: selectedLocations.map((location) {
                            return Chip(
                              label: Text(
                                location.location ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setState(() {
                                  selectedLocations.remove(location);
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
                        // Implement logic to delete selected locations
                        await deleteSelectedLocations(selectedLocations);
                        // Clear selected locations list after deletion
                        setState(() {
                          selectedLocations.clear();
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
          : null, // Show selected locations at the bottom only in "Edit" mode
    );
  }

  // Implement your logic to delete selected locations
  Future<void> deleteSelectedLocations(List<MatchDayBannerForLocation> selectedLocations) async {
    final firestore = FirebaseFirestore.instance;

    // Create a list to hold updated locations after deletion
    final updatedList = List<MatchDayBannerForLocation>.from(matchDayBannerForLocationNotifier.matchDayBannerForLocationList);

    // Iterate through the selected locations and delete them
    for (final locations in selectedLocations) {
      final locationsName = locations.location; // Get the name of the location
      if (locationsName != null) {
        // Delete locations with matching names
        await firestore.collection('MatchDayBannerForLocation').where('location', isEqualTo: locationsName).get().then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });

        // Remove the location from the updated list
        updatedList.remove(locations);
      }
    }

    // Update the locations list in the notifier
    matchDayBannerForLocationNotifier.matchDayBannerForLocationList = updatedList;
  }

  @override
  void initState() {
    MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context, listen: false);
    _fetchMatchDayBannerForLocationNotifier(matchDayBannerForLocationNotifier);

    super.initState();
  }

  Future<void> _fetchMatchDayBannerForLocationNotifier(MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getMatchDayBannerForLocation(matchDayBannerForLocationNotifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {}); // Refresh the UI if needed
  }
}
