import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../model/c_match_day_banner_for_locations_model.dart';
import '../../notifier/c_match_day_banner_for_location_notifier.dart';

class MyChangeTrialDatesPage extends StatefulWidget {
  final String clubId;
  const MyChangeTrialDatesPage({super.key, required this.clubId});

  @override
  State<MyChangeTrialDatesPage> createState() => MyChangeTrialDatesPageState();
}

class MyChangeTrialDatesPageState extends State<MyChangeTrialDatesPage> {
  MatchDayBannerForLocation? selectedLocation;
  TimeOfDay? selectedFromTime;
  TimeOfDay? selectedToTime;
  String? selectedDate;
  String? pleaseNote;
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    var matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Modify Trial Dates')),
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

              // Button for selecting a date
              ListTile(
                title: Text(selectedDate != null ? selectedDate! : 'Select Date'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  String? date = await showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('Select Date'),
                        children: daysOfWeek.map((date) {
                          return SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, date);
                            },
                            child: Text(date),
                          );
                        }).toList(),
                      );
                    },
                  );

                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListTile(
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
                  ),
                  Expanded(
                    child: ListTile(
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
                  ),
                ],
              ),

              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: "Come on time, prepare to be tested and we wish you good luck.",
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                onChanged: (value) {
                  pleaseNote = value;
                },
              ),

              // Button to add the trial date
              ElevatedButton(
                onPressed: () {
                  if (selectedLocation != null && selectedFromTime != null && selectedToTime != null && selectedDate != null) {
                    addTrialDate(selectedLocation!, selectedDate!, selectedFromTime!, selectedToTime!);

                    // Show toast notification
                    Fluttertoast.showToast(
                      msg: "Trial date added successfully!",
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
                  'Add Trial Dates',
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              // Displaying the newly added trial date
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrialDates').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var trialDates = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: trialDates.length,
                      itemBuilder: (context, index) {
                        var trialDate = trialDates[index];
                        final fromTime = trialDate['from_time'] ?? '';
                        final toTime = trialDate['to_time'] ?? '';

                        return ListTile(
                          title: Text('${trialDate['location']} (${trialDate['post_code']})'),
                          subtitle: Text('${trialDate['date']} [${formatTime(fromTime)} - ${formatTime(toTime)}]'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this trial date?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteTrialDate(trialDate.id);
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
          content: Column(
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
    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('MatchDayBannerForLocation').add({
      'location': location,
      'post_code': postCode,
    }).then((value) {
      Fluttertoast.showToast(msg: "New location added successfully!");
      notifier.refreshLocations(widget.clubId);
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to add new location: $error");
    });
  }

  void addTrialDate(MatchDayBannerForLocation location, String date, TimeOfDay fromTime, TimeOfDay toTime) {
    // Generate a numeric ID based on the current timestamp
    String numericId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrialDates').doc(numericId).set({
      'location': location.location,
      'post_code': location.postCode,
      'date': date,
      'from_time': '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}',
      'to_time': '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}',
    });
  }

  void deleteTrialDate(String id) {
    FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('TrialDates').doc(id).delete();
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
