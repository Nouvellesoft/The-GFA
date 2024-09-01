import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../model/c_match_day_banner_for_locations_model.dart';
import '../../notifier/c_match_day_banner_for_location_notifier.dart';

class MyChangeTrainingDaysPage extends StatefulWidget {
  final String clubId;
  const MyChangeTrainingDaysPage({super.key, required this.clubId});

  @override
  State<MyChangeTrainingDaysPage> createState() => MyChangeTrainingDaysPageState();
}

class MyChangeTrainingDaysPageState extends State<MyChangeTrainingDaysPage> {
  MatchDayBannerForLocation? selectedLocation;
  TimeOfDay? selectedFromTime;
  TimeOfDay? selectedToTime;
  String? selectedDay;
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    var matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Modify Training Days')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Button for selecting a location
              ListTile(
                title: Text(selectedLocation != null ? '${selectedLocation!.location} (${selectedLocation!.postCode})' : 'Select Location'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  MatchDayBannerForLocation? location = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Location'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children: matchDayBannerForLocationNotifier.matchDayBannerForLocationList.map((location) {
                              return ListTile(
                                title: Text('${location.location} (${location.postCode})'),
                                onTap: () {
                                  Navigator.pop(context, location);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddNewLocationDialog(context);
                            },
                            child: const Text('Add New Location'),
                          ),
                        ],
                      );
                    },
                  );

                  if (location != null) {
                    setState(() {
                      selectedLocation = location;
                    });
                  }
                },
              ),

              // Button for selecting a day
              ListTile(
                title: Text(selectedDay != null ? selectedDay! : 'Select Day'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  String? day = await showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('Select Day'),
                        children: daysOfWeek.map((day) {
                          return SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, day);
                            },
                            child: Text(day),
                          );
                        }).toList(),
                      );
                    },
                  );

                  if (day != null) {
                    setState(() {
                      selectedDay = day;
                    });
                  }
                },
              ),

              // Time picker for 'From' time
              ListTile(
                title: const Text('From Time'),
                subtitle: Text(selectedFromTime != null ? selectedFromTime!.format(context) : 'Select Time'),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedFromTime ?? const TimeOfDay(hour: 19, minute: 0),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedFromTime = picked;
                    });
                  }
                },
              ),

              // Time picker for 'To' time
              ListTile(
                title: const Text('To Time'),
                subtitle: Text(selectedToTime != null ? selectedToTime!.format(context) : 'Select Time'),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedToTime ?? const TimeOfDay(hour: 21, minute: 0),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedToTime = picked;
                    });
                  }
                },
              ),

              // Button to add the training day
              ElevatedButton(
                onPressed: () {
                  if (selectedLocation != null && selectedFromTime != null && selectedToTime != null && selectedDay != null) {
                    addTrainingDay(selectedLocation!, selectedDay!, selectedFromTime!, selectedToTime!);

                    // Show toast notification
                    Fluttertoast.showToast(
                      msg: "Training day added successfully!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Oh oh, one or more steps missing!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: const Text(
                  'Add Training Day',
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              // Displaying the newly added training day
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrainingDays').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var trainingDays = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: trainingDays.length,
                      itemBuilder: (context, index) {
                        var trainingDay = trainingDays[index];
                        final fromTime = trainingDay['from_time'] ?? '';
                        final toTime = trainingDay['to_time'] ?? '';

                        return ListTile(
                          title: Text('${trainingDay['location']} (${trainingDay['post_code']})'),
                          subtitle: Text('${trainingDay['day']} [${formatTime(fromTime)} - ${formatTime(toTime)}]'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this training day?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteTrainingDay(trainingDay.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNewLocationDialog(BuildContext context) {
    String newLocation = '';
    String newPostCode = '';

    var matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Location'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.addressCity],
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: "Ashton New Road, Manchester",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  onChanged: (value) {
                    newLocation = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  autofillHints: const [AutofillHints.postalCode],
                  decoration: const InputDecoration(
                    labelText: 'Post Code',
                    hintText: "M11 3FF",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  onChanged: (value) {
                    newPostCode = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a post code';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (newLocation.isNotEmpty && newPostCode.isNotEmpty) {
                  _saveNewLocation(newLocation, newPostCode, matchDayBannerForLocationNotifier);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "Please fill all fields");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNewLocation(String location, String postCode, MatchDayBannerForLocationNotifier notifier) {
    // Generate a numeric ID based on the current timestamp
    String numericId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('MatchDayBannerForLocation').doc(numericId).set({
      'location': location,
      'post_code': postCode,
    }).then((value) {
      Fluttertoast.showToast(msg: "New location added successfully!");
      notifier.refreshLocations(widget.clubId);
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to add new location: $error");
    });
  }

  void addTrainingDay(MatchDayBannerForLocation location, String day, TimeOfDay fromTime, TimeOfDay toTime) {
    // Generate a numeric ID based on the current timestamp
    String numericId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrainingDays').doc(numericId).set({
      'location': location.location,
      'post_code': location.postCode,
      'day': day,
      'from_time': '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}',
      'to_time': '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}',
    });
  }

  void deleteTrainingDay(String id) {
    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrainingDays').doc(id).delete();
  }

  String formatTime(String time24) {
    if (time24.isEmpty) return 'N/A';

    final parts = time24.split(':');
    if (parts.length != 2) return 'Invalid time format';

    final hour24 = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final isPM = hour24 >= 12;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minute ${isPM ? 'PM' : 'AM'}';
  }
}
