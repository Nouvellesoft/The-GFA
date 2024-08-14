// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '/api/club_sponsors_api.dart';
// import '/bloc_navigation_bloc/navigation_bloc.dart';
// import '/club_admin/add_club_member/a_tabview_add_club_member_page.dart';
// import '/club_admin/modify_member/modify_coaches_page.dart';
// import '/club_admin/modify_member/modify_management_page.dart';
// import '/club_admin/sm_posts/create_announcement_sm_post.dart';
// import '/club_admin/sm_posts/create_matchday_sm_post.dart';
// import '/club_admin/sm_posts/create_new_sponsors_so_sm_post.dart';
// import '/club_admin/sm_posts/create_sponsors_so_sm_post.dart';
// import '/club_admin/sm_posts/create_upcoming_event_sm_post.dart';
// import '/notifier/club_sponsors_notifier.dart';
// import '/thrown_pages/club_sponsors_thrown_page.dart';
// import '../api/c_match_day_banner_for_club_api.dart';
// import '../api/c_match_day_banner_for_club_opp_api.dart';
// import '../api/c_match_day_banner_for_league_api.dart';
// import '../api/c_match_day_banner_for_location_api.dart';
// import '../api/club_captains_api.dart';
// import '../api/coaching_staff_api.dart';
// import '../api/first_team_class_api.dart';
// import '../api/management_body_api.dart';
// import '../api/second_team_class_api.dart';
// import '../notifier/all_club_members_notifier.dart';
// import '../notifier/all_fc_teams_notifier.dart';
// import '../notifier/c_match_day_banner_for_club_notifier.dart';
// import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
// import '../notifier/c_match_day_banner_for_league_notifier.dart';
// import '../notifier/c_match_day_banner_for_location_notifier.dart';
// import '../notifier/club_captains_notifier.dart';
// import '../notifier/club_global_notifier.dart';
// import '../notifier/coaching_staff_notifier.dart';
// import '../notifier/first_team_class_notifier.dart';
// import '../notifier/management_body_notifier.dart';
// import '../notifier/players_notifier.dart';
// import '../notifier/second_team_class_notifier.dart';
// import 'modify_captains/a_tabview_modify_club_captains_page.dart';
// import 'modify_club_sponsors/a_tabview_modify_club_sponsors_page.dart';
// import 'modify_member/modify_players_page.dart';
// import 'modify_motm/a_tabview_modify_motm_page.dart';
// import 'modify_mvp/a_tabview_modify_mvp_page.dart';
// import 'more_comm/modify_home_teams/a_tabview_modify_home_team_page.dart';
// import 'more_comm/modify_leagues/a_tabview_modify_league_page.dart';
// import 'more_comm/modify_locations/a_tabview_modify_location_page.dart';
// import 'more_comm/modify_opp_teams/a_tabview_modify_opp_team_page.dart';
// import 'others/add_monthly_photos_page.dart';
// import 'others/change_pages_cover_photo_page.dart';
// import 'others/change_vision_statement_and_more_page.dart';
// import 'others/modify_red_card/a_tabview_modify_red_card_page.dart';
// import 'others/modify_yellow_card/a_tabview_modify_yellow_card_page.dart';
// import 'others/record_club_achievement_page.dart';
// import 'others/view_club_population_page.dart';
//
// class MyClubAdminPage extends StatefulWidget implements NavigationStates {
//   final String clubId;
//   const MyClubAdminPage({super.key, required this.clubId});
//
//   @override
//   State<MyClubAdminPage> createState() => MyClubAdminPageState();
// }
//
// class MyClubAdminPageState extends State<MyClubAdminPage> {
//   late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;
//   late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscription;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: <Widget>[
//               const SizedBox(
//                 height: 30,
//               ),
//               Divider(
//                 height: 5,
//                 thickness: 0.5,
//                 color: dividerColor.withOpacity(0.3),
//                 indent: 12,
//                 endIndent: 15,
//               ),
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   splashColor: splashColorThree,
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           backgroundColor: containerBackgroundColor,
//                           title: const Text(
//                             'Select an Option',
//                             style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
//                           ),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               ListTile(
//                                 title: const Text(
//                                   'Publish MatchDay Fixtures',
//                                   style: TextStyle(color: Colors.cyan, fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   Navigator.pop(context); // Close the dialog
//                                   fetchAndNavigateToCreateSMPost(context); // Navigate to the appropriate page
//                                 },
//                               ),
//                               ListTile(
//                                 title: const Text(
//                                   'Publish an Upcoming Event',
//                                   style: TextStyle(color: Colors.cyan, fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   fetchAndNavigateToCreateUpcomingEventSMPost(context);
//                                 },
//                               ),
//                               ListTile(
//                                 title: const Text(
//                                   'Shout Out Current Sponsor',
//                                   style: TextStyle(color: Colors.blueAccent, fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   fetchAndNavigateToCreateSponsorsShoutOutSMPost(context);
//                                 },
//                               ),
//                               ListTile(
//                                 title: const Text(
//                                   'Shout Out New Sponsor',
//                                   style: TextStyle(color: Colors.blueAccent, fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   fetchAndNavigateToCreateNewSponsorsShoutOutSMPost(context);
//                                 },
//                               ),
//                               ListTile(
//                                 title: const Text(
//                                   'Publish an Announcement',
//                                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                                 ),
//                                 onTap: () {
//                                   // Navigator.pop(context);
//                                   // navigateToCreateAnnouncementSMPost(context);
//
//                                   Fluttertoast.showToast(
//                                     msg: 'Coming Soon',
//                                     // Show success message (you can replace it with actual banner generation logic)
//                                     gravity: ToastGravity.BOTTOM,
//                                     backgroundColor: Colors.deepOrangeAccent,
//                                     textColor: Colors.white,
//                                     fontSize: 16.0,
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: MediaQuery.of(context).size.width / 8,
//                             height: MediaQuery.of(context).size.width / 8,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: blueColor.withAlpha(80),
//                             ),
//                             child: IconButton(
//                               icon: const FaIcon(
//                                 FontAwesomeIcons.handsAslInterpreting,
//                                 color: Colors.blue,
//                                 size: 25,
//                               ),
//                               onPressed: () {},
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Text(
//                             createSMPostTitle,
//                             style: TextStyle(color: gradientColorTwo, fontSize: 16),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     firestoreStream = FirebaseFirestore.instance
//         .collection('clubs')
//         .doc(widget.clubId)
//         .collection('AboutClub')
//         .doc('about_club_page')
//         .snapshots()
//         .distinct(); // Ensure distinct events
//
//     // Listen to the stream
//     streamSubscription = firestoreStream.listen((snapshot) {
//       if (snapshot.exists && mounted) {
//         var data = snapshot.data()!;
//         final clubGlobalProvider = Provider.of<ClubGlobalProvider>(context, listen: false);
//         clubGlobalProvider.setClubName(data['club_name']);
//         clubGlobalProvider.setClubLogo(data['club_logo']);
//         clubGlobalProvider.setClubIcon(data['club_icon']);
//       }
//     });
//
//     // Populate the PlayersNotifier with data from both teams
//     PlayersNotifier playersNotifier = Provider.of<PlayersNotifier>(context, listen: false);
//
//     playersNotifier.setFirstTeamPlayers(firstTeamClassNotifier.firstTeamClassList);
//     playersNotifier.setSecondTeamPlayers(secondTeamClassNotifier.secondTeamClassList);
//
//     // Populate the AllClubMembersNotifier with data from both teams
//     AllClubMembersNotifier allClubMembersNotifier = Provider.of<AllClubMembersNotifier>(context, listen: false);
//
//     allClubMembersNotifier.setFirstTeamMembers(firstTeamClassNotifier.firstTeamClassList);
//     allClubMembersNotifier.setSecondTeamMembers(secondTeamClassNotifier.secondTeamClassList);
//     allClubMembersNotifier.setCoachesList(coachesNotifier.coachesList);
//     allClubMembersNotifier.setMGMTBodyList(managementBodyNotifier.managementBodyList);
//
//     AllFCTeamsNotifier allFCTeamsNotifier = Provider.of<AllFCTeamsNotifier>(context, listen: false);
//
//     allFCTeamsNotifier.setMatchDayBannerForClubAllFCTeams(matchDayBannerForClubNotifier.matchDayBannerForClubList);
//     allFCTeamsNotifier.setMatchDayBannerForClubOppAllFCTeams(matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList);
//
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyAllClubPlayers(BuildContext context) async {
//     navigateToModifyAllClubPlayers(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToAddClubMember(BuildContext context) async {
//     navigateToAddClubMember(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyHomeTeam(BuildContext context) async {
//     navigateToModifyHomeTeam(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyOppTeam(BuildContext context) async {
//     navigateToModifyOppTeam(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyLeague(BuildContext context) async {
//     navigateToModifyLeague(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyLocation(BuildContext context) async {
//     navigateToModifyLocation(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyMVP(BuildContext context) async {
//     navigateToModifyMVP(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyPOTM(BuildContext context) async {
//     navigateToModifyPOTM(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyYellowCard(BuildContext context) async {
//     navigateToModifyYellowCard(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToModifyRedCard(BuildContext context) async {
//     navigateToModifyRedCard(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToAddMonthlyPhotos(BuildContext context) async {
//     navigateToAddMonthlyPhotos(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToChangePagesCoverPhoto(BuildContext context) async {
//     navigateToChangePagesCoverPhoto(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToChangeVisionStatementAndMore(BuildContext context) async {
//     navigateToChangeVisionStatementAndMore(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToRecordClubAchievement(BuildContext context) async {
//     navigateToRecordClubAchievement(context, widget.clubId);
//     setState(() {});
//   }
//
//   Future<void> fetchAndNavigateToViewClubPopulation(BuildContext context) async {
//     navigateToViewClubPopulation(context, widget.clubId);
//     setState(() {});
//   }
// }
//
// Future navigateToModifyAllClubPlayers(BuildContext context, String clubId) async {
//   Navigator.push(context, MaterialPageRoute(builder: (context) => MyModifyClubPlayersPage(clubId: clubId)));
// }
//
// Future navigateToAddClubMember(BuildContext context, String clubId) async {
//   Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewClubMemberPage(clubId: clubId)));
// }
