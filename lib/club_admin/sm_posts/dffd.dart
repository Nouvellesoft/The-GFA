import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/bloc_navigation_bloc/navigation_bloc.dart';

Color backgroundColor = const Color.fromRGBO(237, 241, 241, 1.0);

class MyAddClubMemberPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyAddClubMemberPage({super.key, required this.clubId});

  @override
  State<MyAddClubMemberPage> createState() => MyAddClubMemberPageState();
}

class MyAddClubMemberPageState extends State<MyAddClubMemberPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _selectedRole = '';
  final _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  List<String> _roleOptions = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchRoleOptions();
  }

  Future<void> _fetchRoleOptions() async {
    try {
      // Fetch role options from Firestore
      final snapshot = await firestore.collection('clubs').doc(widget.clubId).collection('TeamClassVisibility').get();
      final roles = snapshot.docs.map((doc) => doc['id'] as String).toList();

      setState(() {
        _roleOptions = roles;
        if (_roleOptions.isNotEmpty) {
          _selectedRole = _roleOptions.first; // Set default role
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching role options: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> doesNameExist(String fullName, String collectionName) async {
    final querySnapshot = await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).where('name', isEqualTo: fullName).get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final fullName = '$firstName $lastName';
      final role = _selectedRole;
      String collectionName = ''; // Map the role to collection
      Map<String, dynamic> data = {}; // Define data based on role

      // Define collections for each role
      final roleCollections = {
        'First Team Players': 'FirstTeamClassPlayers',
        'Second Team Players': 'SecondTeamClassPlayers',
        'Third Team Players': 'ThirdTeamClassPlayers',
        'Fourth Team Players': 'FourthTeamClassPlayers',
        'Fifth Team Players': 'FifthTeamClassPlayers',
        'Sixth Team Players': 'SixthTeamClassPlayers',
        'Coach': 'Coaches',
        'Manager': 'ManagementBody',
      };

      collectionName = roleCollections[role] ?? '';
      // Define data based on role if necessary
      data = {
        'name': fullName,
        // Add other fields as needed
      };

      try {
        if (collectionName.isNotEmpty) {
          bool nameExists = await doesNameExist(fullName, collectionName);

          if (nameExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('The name "$fullName" already exists in the $collectionName collection.'),
              ),
            );
          } else {
            await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).add(data);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New member added to $collectionName collection'),
              ),
            );

            _firstNameController.clear();
            _lastNameController.clear();
            setState(() {
              _selectedRole = _roleOptions.isNotEmpty ? _roleOptions.first : ''; // Reset role if needed
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unsupported role: $role'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding member: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Second Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_roleOptions.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: _roleOptions.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Role'),
                )
              else
                const Center(child: Text('No roles available')),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(147, 165, 193, 1.0),
                ),
                child: const Text(
                  'Add Club Member',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
