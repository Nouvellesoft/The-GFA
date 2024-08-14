import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../bloc_navigation_bloc/navigation_bloc.dart';
import '../../../notifier/club_global_notifier.dart';

class MyAddNewHomeTeamPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyAddNewHomeTeamPage({super.key, required this.clubId});

  @override
  State<MyAddNewHomeTeamPage> createState() => MyAddNewHomeTeamPageState();
}

class MyAddNewHomeTeamPageState extends State<MyAddNewHomeTeamPage> {
  final TextEditingController _homeTeamNameController = TextEditingController();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  String clubName = '';
  String clubIcon = '';

  @override
  Widget build(BuildContext context) {
    clubName = Provider.of<ClubGlobalProvider>(context).clubName;
    clubIcon = Provider.of<ClubGlobalProvider>(context).clubIcon;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              TextFormField(
                controller: _homeTeamNameController,
                decoration: InputDecoration(
                  labelText: 'Home Team Name',
                  hintText: "$clubName U14",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(147, 165, 193, 1.0), // Change this color to your desired background color
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Add Home Team',
                        style: TextStyle(color: Colors.white70),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      final homeTeamName = _homeTeamNameController.text;

      try {
        // Check if the home team name already exists
        bool teamExists = await doesHomeTeamExist(homeTeamName);
        if (teamExists) {
          _showErrorToast('Home team name already exists.');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        // Update Firestore document with data
        await FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('MatchDayBannerForClub').add({
          'id': '10',
          'team_name': homeTeamName,
          'club_icon': clubIcon,
          // Provide a default URL if image is not selected
        });

        // Show success toast
        _showSuccessToast();

        // Reset form and UI
        _formKey.currentState!.reset();
        setState(() {
          _homeTeamNameController.text = '';
          _isSubmitting = false;
        });
      } catch (e) {
        // Show error toast
        _showErrorToast(e.toString());

        // Update UI to stop submitting
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> doesHomeTeamExist(String homeTeamName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('MatchDayBannerForClub')
        .where('team_name', isEqualTo: homeTeamName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "Home Team added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: "Error: $message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
