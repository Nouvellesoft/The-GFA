import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/bloc_navigation_bloc/navigation_bloc.dart';
import '../../api/coaching_staff_api.dart';
import '../../api/fifth_team_class_api.dart';
import '../../api/first_team_class_api.dart';
import '../../api/fourth_team_class_api.dart';
import '../../api/get_teams_visibility.dart';
import '../../api/management_body_api.dart';
import '../../api/second_team_class_api.dart';
import '../../api/sixth_team_class_api.dart';
import '../../api/third_team_class_api.dart';
import '../../model/coaches.dart';
import '../../model/fifth_team_class.dart';
import '../../model/first_team_class.dart';
import '../../model/fourth_team_class.dart';
import '../../model/management_body.dart';
import '../../model/second_team_class.dart';
import '../../model/sixth_team_class.dart';
import '../../model/third_team_class.dart';
import '../../notifier/all_club_members_notifier.dart';
import '../../notifier/coaching_staff_notifier.dart';
import '../../notifier/fifth_team_class_notifier.dart';
import '../../notifier/first_team_class_notifier.dart';
import '../../notifier/fourth_team_class_notifier.dart';
import '../../notifier/management_body_notifier.dart';
import '../../notifier/second_team_class_notifier.dart';
import '../../notifier/sixth_team_class_notifier.dart';
import '../../notifier/third_team_class_notifier.dart';

Color conColor = const Color.fromRGBO(194, 194, 220, 1.0);
Color conColorTwo = const Color.fromRGBO(151, 147, 151, 1.0);
Color textColor = const Color.fromRGBO(222, 214, 214, 1.0);
Color whiteColor = const Color.fromRGBO(255, 253, 253, 1.0);
Color twitterColor = const Color.fromRGBO(36, 81, 149, 1.0);
Color instagramColor = const Color.fromRGBO(255, 255, 255, 1.0);
Color facebookColor = const Color.fromRGBO(43, 103, 195, 1.0);
Color snapchatColor = const Color.fromRGBO(222, 163, 36, 1.0);
Color youtubeColor = const Color.fromRGBO(220, 45, 45, 1.0);
Color websiteColor = const Color.fromRGBO(104, 79, 178, 1.0);
Color emailColor = const Color.fromRGBO(230, 45, 45, 1.0);
Color phoneColor = const Color.fromRGBO(20, 134, 46, 1.0);
Color backgroundColor = const Color.fromRGBO(237, 241, 241, 1.0);

// Define colors for different departments
Color playerColor = Colors.black; // Change the color based on your preference
Color coachColor = phoneColor; // Change the color based on your preference
Color managerColor = Colors.orange; // Change the color based on your preference

class MyShowAllClubMemberPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyShowAllClubMemberPage({super.key, required this.clubId});

  @override
  State<MyShowAllClubMemberPage> createState() => MyShowAllClubMemberPageState();
}

class MyShowAllClubMemberPageState extends State<MyShowAllClubMemberPage> {
  bool isDeptSelected = false;
  bool isEditing = false; // Flag to determine if the user is in "Edit" mode
  List<String> selectedMemberNames = []; // List to store selected player names
  Map<String, String> memberDept = {}; // Map to store player-team mapping
  String selectedDept = ''; // Variable to store the selected team

  Map<String, bool> teamClassVisibility = {};

  @override
  Widget build(BuildContext context) {
    // Use the AllClubMembersNotifier to access the combined list of allClubMembers
    AllClubMembersNotifier allClubMembersNotifier = Provider.of<AllClubMembersNotifier>(context);

    // Check if visibility data has been loaded
    if (teamClassVisibility.isEmpty) {
      return const CircularProgressIndicator(); // Or any other loading widget
    }

    // Create a copy of the allClubMembersList and sort it alphabetically by name
    List<dynamic> sortedMembers = List.from(allClubMembersNotifier.allClubMembersList);
    sortedMembers.sort((a, b) => (a.name ?? 'No Name').toLowerCase().compareTo((b.name ?? 'No Name').toLowerCase()));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Hide the keyboard when tapping outside the text field
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // You can add logic here to show/hide the scrollbar based on scroll position
              return true;
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: sortedMembers.length,
                itemBuilder: (context, index) {
                  final teamMember = sortedMembers[index];
                  final memberName = teamMember.name ?? 'No Name';
                  String deptForMember = '';

                  // Determine the department based on the type of teamMember and visibility
                  if (teamMember is FirstTeamClass && teamClassVisibility['FirstTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is SecondTeamClass && teamClassVisibility['SecondTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is ThirdTeamClass && teamClassVisibility['ThirdTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is FourthTeamClass && teamClassVisibility['FourthTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is FifthTeamClass && teamClassVisibility['FifthTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is SixthTeamClass && teamClassVisibility['SixthTeamClass'] == true) {
                    deptForMember = 'Player';
                  } else if (teamMember is Coaches && teamClassVisibility['Coaches'] == true) {
                    deptForMember = 'Coaches';
                  } else if (teamMember is ManagementBody && teamClassVisibility['ManagementBody'] == true) {
                    deptForMember = 'ManagementBody';
                  } else {
                    return const SizedBox.shrink(); // Hide the item if it's not visible
                  }

                  // Assign color based on the department
                  Color memberColor = _getMemberColor(deptForMember);

                  return ListTile(
                    title: Text(
                      '$memberName (${deptForMember.isNotEmpty ? deptForMember : 'No Department'})',
                      style: TextStyle(color: memberColor),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getMemberColor(String department) {
    // Return the color based on the department
    switch (department) {
      case 'Player':
        return playerColor;
      case 'Coach':
        return coachColor;
      case 'Manager':
        return managerColor;
      default:
        return Colors.blue; // Change the default color based on your preference
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchVisibilityData();

    // Fetch data for the first and second teams using their notifiers
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
    _fetchFirstTeamClassAndUpdateNotifier(firstTeamClassNotifier);

    SecondTeamClassNotifier secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);
    _fetchSecondTeamClassAndUpdateNotifier(secondTeamClassNotifier);

    ThirdTeamClassNotifier thirdTeamClassNotifier = Provider.of<ThirdTeamClassNotifier>(context, listen: false);
    _fetchThirdTeamClassAndUpdateNotifier(thirdTeamClassNotifier);

    FourthTeamClassNotifier fourthTeamClassNotifier = Provider.of<FourthTeamClassNotifier>(context, listen: false);
    _fetchFourthTeamClassAndUpdateNotifier(fourthTeamClassNotifier);

    FifthTeamClassNotifier fifthTeamClassNotifier = Provider.of<FifthTeamClassNotifier>(context, listen: false);
    _fetchFifthTeamClassAndUpdateNotifier(fifthTeamClassNotifier);

    SixthTeamClassNotifier sixthTeamClassNotifier = Provider.of<SixthTeamClassNotifier>(context, listen: false);
    _fetchSixthTeamClassAndUpdateNotifier(sixthTeamClassNotifier);

    CoachesNotifier coachesNotifier = Provider.of<CoachesNotifier>(context, listen: false);
    _fetchCoachesAndUpdateNotifier(coachesNotifier);

    ManagementBodyNotifier managementBodyNotifier = Provider.of<ManagementBodyNotifier>(context, listen: false);
    _fetchManagementBodyAndUpdateNotifier(managementBodyNotifier);

    // Populate the AllClubMembersNotifier with data from both teams
    AllClubMembersNotifier allClubMembersNotifier = Provider.of<AllClubMembersNotifier>(context, listen: false);

    allClubMembersNotifier.setFirstTeamMembers(firstTeamClassNotifier.firstTeamClassList);
    allClubMembersNotifier.setSecondTeamMembers(secondTeamClassNotifier.secondTeamClassList);
    allClubMembersNotifier.setThirdTeamMembers(thirdTeamClassNotifier.thirdTeamClassList);
    allClubMembersNotifier.setFourthTeamMembers(fourthTeamClassNotifier.fourthTeamClassList);
    allClubMembersNotifier.setFifthTeamMembers(fifthTeamClassNotifier.fifthTeamClassList);
    allClubMembersNotifier.setSixthTeamMembers(sixthTeamClassNotifier.sixthTeamClassList);
    allClubMembersNotifier.setCoachesList(coachesNotifier.coachesList);
    allClubMembersNotifier.setMGMTBodyList(managementBodyNotifier.managementBodyList);
  }

  Future<void> _fetchVisibilityData() async {
    teamClassVisibility = await getTeamClassVisibility(widget.clubId);
    setState(() {}); // Trigger a rebuild to reflect the visibility changes
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

  Future<void> _fetchCoachesAndUpdateNotifier(CoachesNotifier coachesNotifier) async {
    await getCoaches(coachesNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchManagementBodyAndUpdateNotifier(ManagementBodyNotifier managementBodyNotifier) async {
    await getManagementBody(managementBodyNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }
}
