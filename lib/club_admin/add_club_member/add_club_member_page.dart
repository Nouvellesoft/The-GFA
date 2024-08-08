import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  String _selectedRole = ''; // Default value is now an empty string
  final _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  List<String> _roleOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchRoleOptions();
  }

  final Map<String, String> roleMapping = {
    'FirstTeamClass': 'First Team Players',
    'SecondTeamClass': 'Second Team Players',
    'ThirdTeamClass': 'Third Team Players',
    'FourthTeamClass': 'Fourth Team Players',
    'FifthTeamClass': 'Fifth Team Players',
    'SixthTeamClass': 'Sixth Team Players',
    'Coaches': 'Coaches',
    'ManagementBody': 'Management Body',
  };

  // Function to fetch role options dynamically from Firestore
  Future<void> _fetchRoleOptions() async {
    try {
      final snapshot = await firestore.collection('clubs').doc(widget.clubId).collection('TeamClassVisibility').get();

      final roles = snapshot.docs.where((doc) => doc['isVisible'] == true).map((doc) {
        final id = doc['id'] as String;
        return roleMapping[id] ?? id; // Use the mapped name or the id if no mapping exists
      }).toList();

      // Remove "Captains" from the list if it exists
      roles.remove('Captains');

      // Sort roles with players first, then coaches, then management
      roles.sort((a, b) {
        const playerRoles = [
          'First Team Players',
          'Second Team Players',
          'Third Team Players',
          'Fourth Team Players',
          'Fifth Team Players',
          'Sixth Team Players'
        ];
        const coachRoles = ['Coaches'];
        const managementRoles = ['ManagementBody'];

        int getRolePriority(String role) {
          if (playerRoles.contains(role)) return 1;
          if (coachRoles.contains(role)) return 2;
          if (managementRoles.contains(role)) return 3;
          return 4; // Default priority for other roles
        }

        return getRolePriority(a).compareTo(getRolePriority(b));
      });

      setState(() {
        _roleOptions = roles;
        if (_roleOptions.isNotEmpty) {
          _selectedRole = _roleOptions.first; // Set the default selected role
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching role options: $e');
      }
    }
  }

  Future<bool> doesNameExist(String fullName, String collectionName) async {
    final querySnapshot = await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).where('name', isEqualTo: fullName).get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final lastName = _lastNameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final fullName = '$firstName $lastName';
      final role = _selectedRole;
      String collectionName = '';
      Map<String, dynamic> data = {};

      switch (role) {
        case 'First Team Players':
          collectionName = 'FirstTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Second Team Players':
          collectionName = 'SecondTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Third Team Players':
          collectionName = 'ThirdTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Fourth Team Players':
          collectionName = 'FourthTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Fifth Team Players':
          collectionName = 'FifthTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Sixth Team Players':
          collectionName = 'SixthTeamClassPlayers';
          data = {
            'id': '10',
            'autobio': '',
            'best_moment': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_1.jpg?alt=media&token=585caeeb-2d2c-4dd9-a298-c802f9998356',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff0',
            'instagram': '',
            'name': fullName,
            'nickname': '',
            'phone': '',
            'team_captaining': '',
            'captain': '',
            'constituent_country': '',
            'region_from': '',
            'twitter': '',
            'd_o_b': '',
            'dream_fc': '',
            'position_playing': '',
            'snapchat': '',
            'tiktok': '',
            'linkedIn': '',
            'other_positions_of_play': '',
            'fav_football_legend': '',
            'year_of_inception': '',
            'adidas_or_nike': '',
            'ronaldo_or_messi': '',
            'left_or_right': '',
            'hobbies': '',
            'my_dropline': '',
            'philosophy': '',
            'worst_moment': '',
          };
          break;
        case 'Coaches':
          collectionName = 'Coaches';
          data = {
            'id': '10',
            'autobio': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_coach_1.jpg?alt=media&token=d5960c59-a7b7-4556-87e3-4095c638a056',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_coach_2.jpg?alt=media&token=487a3e8c-2692-4d3d-92a4-471a2a547920',
            'instagram': '',
            'name': fullName,
            'phone': '',
            'twitter': '',
            'linkedIn': '',
            'year_of_inception': '',
            'region_of_origin': '',
            'nationality': '',
            'hobbies': '',
            'best_moment': '',
            'worst_moment': '',
            'd_o_b': '',
            'staff_position': '',
            'philosophy': '',
            'why_you_love_coaching_or_fc_management': '',
            'fav_sporting_icon': '',
          };
          break;
        case 'Manager':
          collectionName = 'ManagementBody';
          data = {
            'id': '10',
            'autobio': '',
            'email': '',
            'facebook': '',
            'image':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_manager_2.jpg?alt=media&token=afc23732-5674-4008-9662-9b756b66e9f6',
            'image_two':
                'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_manager_1.jpg?alt=media&token=eb2ce227-a66b-4fa3-a642-f4742f3ad40e',
            'instagram': '',
            'name': fullName,
            'phone': '',
            'twitter': '',
            'linkedIn': '',
            'year_of_inception': '',
            'region_of_origin': '',
            'nationality': '',
            'hobbies': '',
            'best_moment': '',
            'worst_moment': '',
            'd_o_b': '',
            'staff_position': '',
            'philosophy': '',
            'why_you_love_coaching_or_fc_management': '',
            'fav_sporting_icon': '',
          };
          break;
        default:
          break;
      }

      // Check if the name exists in any of the player collections
      bool nameExists = false;
      const playerCollections = [
        'FirstTeamClassPlayers',
        'SecondTeamClassPlayers',
        'ThirdTeamClassPlayers',
        'FourthTeamClassPlayers',
        'FifthTeamClassPlayers',
        'SixthTeamClassPlayers'
      ];

      // Loop through each player collection to check if the name exists
      for (var collection in playerCollections) {
        if (await doesNameExist(fullName, collection)) {
          nameExists = true;
          break;
        }
      }

      // If the name exists, show a Snackbar and do not proceed
      if (nameExists && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The name "$fullName" already exists in one of the player collections.'),
          ),
        );
        return; // Exit early
      }

      // If name does not exist, proceed to add the data
      try {
        if (collectionName.isNotEmpty) {
          await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).add(data);

          // Adding player to PlayersTable collection for statistics
          await firestore.collection('clubs').doc(widget.clubId).collection('PllayersTable').add({
            'age': 0,
            'assists': 0,
            'clean_sheets_gk': 0,
            'goals_conceded_gk_def': 0,
            'goals_scored': 0,
            'id': '10', // Assuming 'id' is a string, adjust as needed
            'image': data['image'], // Use the same image URL as above
            'man_of_the_match': '',
            'man_of_the_match_cum': 0,
            'matches_benched': 0,
            'matches_played': 0,
            'matches_started': 0,
            'nationality': '',
            'player_name': fullName,
            'player_of_the_month': '0',
            'player_position': '',
            'player_value': 0,
            'potm_cum': 0,
            'preferred_foot': '',
            'red_card': 0,
            'yellow_card': 0,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$fullName has been added to the $collectionName collection and PlayersTable for statistics'),
              ),
            );
          }

          _firstNameController.clear();
          _lastNameController.clear();
          setState(() {
            _selectedRole = _roleOptions.first;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unsupported role: $role'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding member: $e'),
            ),
          );
        }
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
              if (_roleOptions.isNotEmpty)
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
                const Center(child: CircularProgressIndicator()),
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
