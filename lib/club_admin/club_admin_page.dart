import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_gfa/club_admin/others/change_training_days_page.dart';
import 'package:the_gfa/club_admin/others/change_trial_dates_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/club_sponsors_api.dart';
import '/bloc_navigation_bloc/navigation_bloc.dart';
import '/club_admin/add_club_member/a_tabview_add_club_member_page.dart';
import '/club_admin/modify_member/modify_coaches_page.dart';
import '/club_admin/modify_member/modify_management_page.dart';
import '/club_admin/sm_posts/create_announcement_sm_post.dart';
import '/club_admin/sm_posts/create_matchday_sm_post.dart';
import '/club_admin/sm_posts/create_new_sponsors_so_sm_post.dart';
import '/club_admin/sm_posts/create_sponsors_so_sm_post.dart';
import '/club_admin/sm_posts/create_upcoming_event_sm_post.dart';
import '/notifier/club_sponsors_notifier.dart';
import '/thrown_pages/club_sponsors_thrown_page.dart';
import '../api/c_match_day_banner_for_club_api.dart';
import '../api/c_match_day_banner_for_club_opp_api.dart';
import '../api/c_match_day_banner_for_league_api.dart';
import '../api/c_match_day_banner_for_location_api.dart';
import '../api/club_captains_api.dart';
import '../api/coaching_staff_api.dart';
import '../api/fifth_team_class_api.dart';
import '../api/first_team_class_api.dart';
import '../api/fourth_team_class_api.dart';
import '../api/management_body_api.dart';
import '../api/second_team_class_api.dart';
import '../api/sixth_team_class_api.dart';
import '../api/third_team_class_api.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/all_club_members_notifier.dart';
import '../notifier/all_fc_teams_notifier.dart';
import '../notifier/c_match_day_banner_for_club_notifier.dart';
import '../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import '../notifier/c_match_day_banner_for_league_notifier.dart';
import '../notifier/c_match_day_banner_for_location_notifier.dart';
import '../notifier/club_captains_notifier.dart';
import '../notifier/coaching_staff_notifier.dart';
import '../notifier/fifth_team_class_notifier.dart';
import '../notifier/first_team_class_notifier.dart';
import '../notifier/fourth_team_class_notifier.dart';
import '../notifier/management_body_notifier.dart';
import '../notifier/players_notifier.dart';
import '../notifier/second_team_class_notifier.dart';
import '../notifier/sixth_team_class_notifier.dart';
import '../notifier/third_team_class_notifier.dart';
import 'modify_captains/a_tabview_modify_club_captains_page.dart';
import 'modify_club_sponsors/a_tabview_modify_club_sponsors_page.dart';
import 'modify_member/modify_players_page.dart';
import 'modify_motm/a_tabview_modify_motm_page.dart';
import 'modify_mvp/a_tabview_modify_mvp_page.dart';
import 'more_comm/modify_home_teams/a_tabview_modify_home_team_page.dart';
import 'more_comm/modify_leagues/a_tabview_modify_league_page.dart';
import 'more_comm/modify_locations/a_tabview_modify_location_page.dart';
import 'more_comm/modify_opp_teams/a_tabview_modify_opp_team_page.dart';
import 'others/add_monthly_photos_page.dart';
import 'others/change_pages_cover_photo_page.dart';
import 'others/change_vision_statement_and_more_page.dart';
import 'others/modify_red_card/a_tabview_modify_red_card_page.dart';
import 'others/modify_yellow_card/a_tabview_modify_yellow_card_page.dart';
import 'others/record_club_achievement_page.dart';
import 'others/view_club_population_page.dart';

String chooseMVPOfTheMonthTitle = "Select MVP of the Month";
String chooseMOTMTitle = "Select Man of the Match";
String createSMPostTitle = "Create a Social Media Post";
String addMemberTitle = "Add Player(s), Coach(es) or Manager(s)";
String removeMemberTitle = "Remove Player(s), Coach(es) or Manager(s)";
String sponsorsTitle = "View Club Sponsors";
String commsTitle = "More Communications";
String selectedCaptainsTitle = "Select Club Captains";
String othersTitle = "Others";

Color backgroundColor = const Color.fromRGBO(34, 36, 54, 1.0);
Color gradientColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color gradientColorTwo = Colors.white;
Color gradientColorThree = const Color.fromRGBO(197, 33, 75, 1.0);
Color gradientColorFour = const Color.fromRGBO(70, 94, 213, 1.0);
Color linearGradientColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color linearGradientColorTwo = const Color.fromRGBO(24, 26, 36, 1.0);
Color boxShadowColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color dividerColor = Colors.white;
Color materialBackgroundColor = Colors.transparent;
Color shimmerBaseColor = Colors.white;
Color shimmerHighlightColor = Colors.white;
Color shapeDecorationTextColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color containerBackgroundColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color containerIconColor = Colors.white;
Color dialogBackgroundColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color dialogTextColor = Colors.white;
Color splashColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color splashColorTwo = Colors.white;
Color splashColorThree = Colors.black;
Color textColor = Colors.white;
Color textColorTwo = const Color.fromRGBO(24, 26, 36, 1.0);
Color textShadowColor = Colors.white;

Color blueColor = Colors.blueAccent;
Color redColor = Colors.red;
Color greenColor = Colors.green;
Color yellowColor = Colors.yellow;
Color brownColor = Colors.brown;
Color cyanColor = Colors.cyan;
Color whiteColor = Colors.white;
Color deepOrangeColor = Colors.deepOrange;
Color tealColor = Colors.teal;

class MyClubAdminPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyClubAdminPage({super.key, required this.clubId});

  @override
  State<MyClubAdminPage> createState() => MyClubAdminPageState();
}

class MyClubAdminPageState extends State<MyClubAdminPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscription;

  Future launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("The required App not installed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Club Admin',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 10,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            navigateMyApp(context);
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: containerBackgroundColor,
                          title: const Text(
                            'Select an Option',
                            style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: const Text(
                                  'Publish MatchDay Fixtures',
                                  style: TextStyle(color: Colors.cyan, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context); // Close the dialog
                                  fetchAndNavigateToCreateSMPost(context); // Navigate to the appropriate page
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Publish an Upcoming Event',
                                  style: TextStyle(color: Colors.cyan, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchAndNavigateToCreateUpcomingEventSMPost(context);
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Shout Out Current Sponsor',
                                  style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchAndNavigateToCreateSponsorsShoutOutSMPost(context);
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Shout Out New Sponsor',
                                  style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchAndNavigateToCreateNewSponsorsShoutOutSMPost(context);
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Publish an Announcement',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                onTap: () {
                                  // Navigator.pop(context);
                                  // navigateToCreateAnnouncementSMPost(context);

                                  Fluttertoast.showToast(
                                    msg: 'Coming Soon',
                                    // Show success message (you can replace it with actual banner generation logic)
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.deepOrangeAccent,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: blueColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.handsAslInterpreting,
                                color: Colors.blue,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            createSMPostTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: containerBackgroundColor,
                            title: const Text(
                              'Select an Option',
                              style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: const Text(
                                    'See Club Sponsors',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    fetchClubSponsorsAndNavigate(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    'Modify Club Sponsors',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    fetchAndNavigateToModifyClubSponsors(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: greenColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.jedi,
                                color: greenColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            sponsorsTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    fetchAndNavigateToModifyClubCaptains(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: brownColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.om,
                                color: redColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            selectedCaptainsTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    fetchAndNavigateToAddClubMember(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: whiteColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.spider,
                                color: whiteColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            addMemberTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: containerBackgroundColor,
                          title: const Text(
                            'Select an Option',
                            style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: const Text(
                                  'Remove Player(s)',
                                  style: TextStyle(color: Colors.cyan, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context); // Close the dialog
                                  fetchAndNavigateToModifyAllClubPlayers(context); // Navigate to the appropriate page
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Remove Coaching Staff',
                                  style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchAndNavigateToModifyCoaches(context);
                                },
                              ),
                              ListTile(
                                title: const Text(
                                  'Removing Club Manager(s)',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchAndNavigateToModifyManagementBody(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: yellowColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.leaf,
                                color: yellowColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            removeMemberTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    fetchAndNavigateToModifyMVP(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: cyanColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.vrCardboard,
                                color: cyanColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            chooseMVPOfTheMonthTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    fetchAndNavigateToModifyPOTM(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: deepOrangeColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.dragon,
                                color: deepOrangeColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            chooseMOTMTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: containerBackgroundColor,
                            title: const Text(
                              'Select an Option',
                              style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: const Text(
                                    // 'Select Player of the Month',
                                    'Add new Home Team',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    fetchAndNavigateToModifyHomeTeam(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    // 'Add Monthly Reels',
                                    'Add new Opposition Team',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    fetchAndNavigateToModifyOppTeam(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    // 'Report an issue',
                                    'Add new League',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    fetchAndNavigateToModifyLeague(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    // 'Request a feature',
                                    'Add new Location',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context); // Close the dialog
                                    fetchAndNavigateToModifyLocation(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tealColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.tree,
                                color: tealColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            commsTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: splashColorThree,
                  onTap: () {
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: containerBackgroundColor,
                            title: const Text(
                              'Select an Option',
                              style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            content: SizedBox(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: const Text(
                                        "Generate Club Monthly Statement",
                                        style: TextStyle(color: Colors.cyan, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        // Show the confirmation dialog
                                        showConfirmationDialogForStatementGeneration(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "View Club's Population",
                                        style: TextStyle(color: Colors.greenAccent, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToViewClubPopulation(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "Record Training Days",
                                        style: TextStyle(color: Colors.blue, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToRecordTrainingDays(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "Record Trial Dates",
                                        style: TextStyle(color: Colors.blue, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToRecordTrialDates(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Record Yellow Card(s)    🟨',
                                        style: TextStyle(color: Colors.orange, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToModifyYellowCard(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Record Red Card(s)    🟥',
                                        style: TextStyle(color: Colors.orange, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToModifyRedCard(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "Record Club Achievement(s)",
                                        style: TextStyle(color: Colors.green, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToRecordClubAchievement(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "Add Monthly Photos",
                                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToAddMonthlyPhotos(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        "Change Page(s) Cover Photo(s) ",
                                        style: TextStyle(color: Colors.yellowAccent, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        fetchAndNavigateToChangePagesCoverPhoto(context);
                                      },
                                    ),
                                    // ListTile(
                                    //   title: const Text(
                                    //     "Change Vision Statement and More",
                                    //     style: TextStyle(color: Colors.pinkAccent, fontSize: 13),
                                    //   ),
                                    //   onTap: () {
                                    //     Navigator.pop(context); // Close the dialog
                                    //     navigateToChangeVisionStatementAndMore(context);
                                    //   },
                                    // ),
                                    ListTile(
                                      title: const Text(
                                        "Go To Video Tutorials",
                                        style: TextStyle(color: Colors.pinkAccent, fontSize: 13),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context); // Close the dialog
                                        dynamic videoUrl = 'https://www.youtube.com/@nouvellesoftinc/videos';
                                        launchURL(videoUrl);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: brownColor.withAlpha(80),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.wandMagicSparkles,
                                color: brownColor,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            othersTitle,
                            style: TextStyle(color: gradientColorTwo, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 0.5,
                color: dividerColor.withOpacity(0.3),
                indent: 12,
                endIndent: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    firestoreStream = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('AboutClub')
        .doc('about_club_page')
        .snapshots()
        .distinct(); // Ensure distinct events

    // Listen to the stream
    streamSubscription = firestoreStream.listen((snapshot) {
      if (snapshot.exists && mounted) {
        var data = snapshot.data()!;
        final clubGlobalProvider = Provider.of<ClubGlobalProvider>(context, listen: false);
        clubGlobalProvider.setClubName(data['club_name']);
        clubGlobalProvider.setClubLogo(data['club_logo']);
        clubGlobalProvider.setClubIcon(data['club_icon']);
        clubGlobalProvider.setClubYID(data['youtube_name']);
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Initialize Firebase first
    Firebase.initializeApp().whenComplete(() {
      if (kDebugMode) {
        print("Firebase initialized");
      }
    });

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

    CaptainsNotifier captainsNotifier = Provider.of<CaptainsNotifier>(context, listen: false);
    _fetchCaptainsAndUpdateNotifier(captainsNotifier);

    CoachesNotifier coachesNotifier = Provider.of<CoachesNotifier>(context, listen: false);
    _fetchCoachesAndUpdateNotifier(coachesNotifier);

    ManagementBodyNotifier managementBodyNotifier = Provider.of<ManagementBodyNotifier>(context, listen: false);
    _fetchManagementBodyAndUpdateNotifier(managementBodyNotifier);

    ClubSponsorsNotifier clubSponsorsNotifier = Provider.of<ClubSponsorsNotifier>(context, listen: false);
    _fetchClubSponsorsAndUpdateNotifier(clubSponsorsNotifier);

    // Use WidgetsBinding to defer setState calls until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Populate the PlayersNotifier with data from six teams
      PlayersNotifier playersNotifier = Provider.of<PlayersNotifier>(context, listen: false);

      playersNotifier.setFirstTeamPlayers(firstTeamClassNotifier.firstTeamClassList);
      playersNotifier.setSecondTeamPlayers(secondTeamClassNotifier.secondTeamClassList);
      playersNotifier.setThirdTeamPlayers(thirdTeamClassNotifier.thirdTeamClassList);
      playersNotifier.setFourthTeamPlayers(fourthTeamClassNotifier.fourthTeamClassList);
      playersNotifier.setFifthTeamPlayers(fifthTeamClassNotifier.fifthTeamClassList);
      playersNotifier.setSixthTeamPlayers(sixthTeamClassNotifier.sixthTeamClassList);

      // Populate the AllClubMembersNotifier with data from six teams
      AllClubMembersNotifier allClubMembersNotifier = Provider.of<AllClubMembersNotifier>(context, listen: false);

      allClubMembersNotifier.setFirstTeamMembers(firstTeamClassNotifier.firstTeamClassList);
      allClubMembersNotifier.setSecondTeamMembers(secondTeamClassNotifier.secondTeamClassList);
      allClubMembersNotifier.setThirdTeamMembers(thirdTeamClassNotifier.thirdTeamClassList);
      allClubMembersNotifier.setFourthTeamMembers(fourthTeamClassNotifier.fourthTeamClassList);
      allClubMembersNotifier.setFifthTeamMembers(fifthTeamClassNotifier.fifthTeamClassList);
      allClubMembersNotifier.setSixthTeamMembers(sixthTeamClassNotifier.sixthTeamClassList);
      allClubMembersNotifier.setCoachesList(coachesNotifier.coachesList);
      allClubMembersNotifier.setMGMTBodyList(managementBodyNotifier.managementBodyList);

      // Fetch and set match day banners
      ClubGlobalProvider clubGlobalProvider = Provider.of<ClubGlobalProvider>(context, listen: false);
      MatchDayBannerForClubNotifier matchDayBannerForClubNotifier = Provider.of<MatchDayBannerForClubNotifier>(context, listen: false);
      MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier = Provider.of<MatchDayBannerForClubOppNotifier>(context, listen: false);
      MatchDayBannerForLeagueNotifier matchDayBannerForLeagueNotifier = Provider.of<MatchDayBannerForLeagueNotifier>(context, listen: false);
      MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier = Provider.of<MatchDayBannerForLocationNotifier>(context, listen: false);

      _fetchMatchDayBannerForClubNotifier(matchDayBannerForClubNotifier, clubGlobalProvider);
      _fetchMatchDayBannerForClubOppNotifier(matchDayBannerForClubOppNotifier);
      _fetchMatchDayBannerForLeagueNotifier(matchDayBannerForLeagueNotifier);
      _fetchMatchDayBannerForLocationNotifier(matchDayBannerForLocationNotifier);

      // Update all teams
      AllFCTeamsNotifier allFCTeamsNotifier = Provider.of<AllFCTeamsNotifier>(context, listen: false);
      allFCTeamsNotifier.setMatchDayBannerForClubAllFCTeams(matchDayBannerForClubNotifier.matchDayBannerForClubList);
      allFCTeamsNotifier.setMatchDayBannerForClubOppAllFCTeams(matchDayBannerForClubOppNotifier.matchDayBannerForClubOppList);

      // Trigger UI update
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchMatchDayBannerForClubNotifier(
      MatchDayBannerForClubNotifier matchDayBannerForClubNotifier, ClubGlobalProvider clubGlobalProvider) async {
    await getMatchDayBannerForClub(matchDayBannerForClubNotifier, clubGlobalProvider, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchMatchDayBannerForClubOppNotifier(MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier) async {
    await getMatchDayBannerForClubOpp(matchDayBannerForClubOppNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchMatchDayBannerForLeagueNotifier(MatchDayBannerForLeagueNotifier matchDayBannerForLeagueNotifier) async {
    await getMatchDayBannerForLeague(matchDayBannerForLeagueNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchMatchDayBannerForLocationNotifier(MatchDayBannerForLocationNotifier matchDayBannerForLocationNotifier) async {
    await getMatchDayBannerForLocation(matchDayBannerForLocationNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchFirstTeamClassAndUpdateNotifier(FirstTeamClassNotifier firstTeamNotifier) async {
    await getFirstTeamClass(firstTeamNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchSecondTeamClassAndUpdateNotifier(SecondTeamClassNotifier secondTeamNotifier) async {
    await getSecondTeamClass(secondTeamNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchThirdTeamClassAndUpdateNotifier(ThirdTeamClassNotifier thirdTeamNotifier) async {
    await getThirdTeamClass(thirdTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchFourthTeamClassAndUpdateNotifier(FourthTeamClassNotifier fourthTeamNotifier) async {
    await getFourthTeamClass(fourthTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchFifthTeamClassAndUpdateNotifier(FifthTeamClassNotifier fifthTeamNotifier) async {
    await getFifthTeamClass(fifthTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchSixthTeamClassAndUpdateNotifier(SixthTeamClassNotifier sixthTeamNotifier) async {
    await getSixthTeamClass(sixthTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchCaptainsAndUpdateNotifier(CaptainsNotifier captainsNotifier) async {
    await getCaptains(captainsNotifier, widget.clubId);

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

  Future<void> _fetchClubSponsorsAndUpdateNotifier(ClubSponsorsNotifier notifier) async {
    await getClubSponsors(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> fetchClubSponsorsAndNavigate(BuildContext context) async {
    navigateToClubSponsors(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToCreateSMPost(BuildContext context) async {
    navigateToCreateSMPost(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToCreateUpcomingEventSMPost(BuildContext context) async {
    navigateToCreateUpcomingEventSMPost(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToCreateAnnouncementSMPost(BuildContext context) async {
    navigateToCreateAnnouncementSMPost(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToCreateSponsorsShoutOutSMPost(BuildContext context) async {
    navigateToCreateSponsorsShoutOutSMPost(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToCreateNewSponsorsShoutOutSMPost(BuildContext context) async {
    navigateToCreateNewSponsorsShoutOutSMPost(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyClubSponsors(BuildContext context) async {
    navigateToModifyClubSponsors(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyClubCaptains(BuildContext context) async {
    navigateToModifyClubCaptains(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyCoaches(BuildContext context) async {
    navigateToModifyCoaches(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyManagementBody(BuildContext context) async {
    navigateToModifyManagementBody(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyAllClubPlayers(BuildContext context) async {
    navigateToModifyAllClubPlayers(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToAddClubMember(BuildContext context) async {
    navigateToAddClubMember(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyHomeTeam(BuildContext context) async {
    navigateToModifyHomeTeam(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyOppTeam(BuildContext context) async {
    navigateToModifyOppTeam(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyLeague(BuildContext context) async {
    navigateToModifyLeague(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyLocation(BuildContext context) async {
    navigateToModifyLocation(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyMVP(BuildContext context) async {
    navigateToModifyMVP(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyPOTM(BuildContext context) async {
    navigateToModifyPOTM(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyYellowCard(BuildContext context) async {
    navigateToModifyYellowCard(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToModifyRedCard(BuildContext context) async {
    navigateToModifyRedCard(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToAddMonthlyPhotos(BuildContext context) async {
    navigateToAddMonthlyPhotos(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToChangePagesCoverPhoto(BuildContext context) async {
    navigateToChangePagesCoverPhoto(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToChangeVisionStatementAndMore(BuildContext context) async {
    navigateToChangeVisionStatementAndMore(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToRecordClubAchievement(BuildContext context) async {
    navigateToRecordClubAchievement(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToViewClubPopulation(BuildContext context) async {
    navigateToViewClubPopulation(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToRecordTrainingDays(BuildContext context) async {
    navigateToRecordTrainingDays(context, widget.clubId);
    setState(() {});
  }

  Future<void> fetchAndNavigateToRecordTrialDates(BuildContext context) async {
    navigateToRecordTrialDates(context, widget.clubId);
    setState(() {});
  }
}

void showConfirmationDialogForStatementGeneration(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: const Text(
          'Generate Club Monthly Statement',
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will generate a statement about the club\'s activities so far this month. \n\nClick \'Yes\' to proceed.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'No',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () {
              // Implement the logic to proceed with generating the statement
              Navigator.of(context).pop(); // Close the dialog
              // Add your logic to generate the statement here
              // navigateToGenerateStatement(context);
              Fluttertoast.showToast(
                msg: 'Statement generated!',
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );
}

Future navigateToCreateSMPost(BuildContext context, String clubId) async {
  // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMatchDaySocialMediaPost()));
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMatchDaySocialMediaPost(clubId: clubId)));
}

Future navigateToCreateUpcomingEventSMPost(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUpcomingEventSMPost(clubId: clubId)));
}

Future navigateToCreateAnnouncementSMPost(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAnnouncementSMPost(clubId: clubId)));
}

Future navigateToCreateSponsorsShoutOutSMPost(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSponsorsShoutOutSMPost(clubId: clubId)));
}

Future navigateToCreateNewSponsorsShoutOutSMPost(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewSponsorsShoutOutSMPost(clubId: clubId)));
}

Future navigateToClubSponsors(BuildContext context, String clubId) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MyClubSponsorsPage(fromPage1: true, clubId: clubId), // Pass clubId here
    ),
  );
}

Future navigateToModifyClubSponsors(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewClubSponsorsPage(clubId: clubId)));
}

Future navigateToModifyClubCaptains(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewCaptainsPage(clubId: clubId)));
}

Future navigateToModifyCoaches(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyModifyCoachesPage(clubId: clubId)));
}

Future navigateToModifyManagementBody(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyModifyManagementBodyPage(clubId: clubId)));
}

Future navigateToModifyAllClubPlayers(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyModifyClubPlayersPage(clubId: clubId)));
}

Future navigateToAddClubMember(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewClubMemberPage(clubId: clubId)));
}

Future navigateToModifyHomeTeam(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewHomeTeamPage(clubId: clubId)));
}

Future navigateToModifyOppTeam(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewOppTeamPage(clubId: clubId)));
}

Future navigateToModifyLeague(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewLeaguePage(clubId: clubId)));
}

Future navigateToModifyLocation(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewLocationPage(clubId: clubId)));
}

Future navigateToModifyMVP(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewMVPPage(clubId: clubId)));
}

Future navigateToModifyPOTM(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewMOTMPage(clubId: clubId)));
}

Future navigateToModifyYellowCard(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewYellowCardPage(clubId: clubId)));
}

Future navigateToModifyRedCard(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TabviewRedCardPage(clubId: clubId)));
}

Future navigateToAddMonthlyPhotos(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyAddMonthlyPhotosPage(clubId: clubId)));
}

Future navigateToChangePagesCoverPhoto(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyChangePagesCoverPhotoPage(clubId: clubId)));
}

Future navigateToChangeVisionStatementAndMore(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyChangeVisionStatementAndMorePage(clubId: clubId)));
}

Future navigateToRecordClubAchievement(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyRecordClubAchievementPage(clubId: clubId)));
}

Future navigateToViewClubPopulation(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyViewClubPopulationPage(clubId: clubId)));
}

Future navigateToRecordTrainingDays(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyChangeTrainingDaysPage(clubId: clubId)));
}

Future navigateToRecordTrialDates(BuildContext context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyChangeTrialDatesPage(clubId: clubId)));
}

Future navigateMyApp(context) async {
  Navigator.of(context).pop(false);
}
