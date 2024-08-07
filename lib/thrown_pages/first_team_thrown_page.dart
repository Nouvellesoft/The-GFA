import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/api/a_upcoming_matches_api.dart';
import '/api/club_sponsors_api.dart';
import '/api/second_team_class_api.dart';
import '/notifier/achievement_images_notifier.dart';
import '/notifier/club_arial_notifier.dart';
import '/notifier/club_captains_notifier.dart';
import '/notifier/coaching_staff_notifier.dart';
import '/notifier/management_body_notifier.dart';
import '/notifier/most_assists_players_stats_info_notifier.dart';
import '/notifier/second_team_class_notifier.dart';
import '../about_menu_details_pages/about_app.dart';
import '../about_menu_details_pages/about_club.dart';
import '../about_menu_details_pages/acronyms_meanings.dart';
import '../about_menu_details_pages/who_we_are.dart';
import '../api/achievement_images_api.dart';
import '../api/club_arial_images_api.dart';
import '../api/club_captains_api.dart';
import '../api/coaching_staff_api.dart';
import '../api/cum_motm_players_stats_info_api.dart';
import '../api/fifth_team_class_api.dart';
import '../api/first_team_class_api.dart';
import '../api/founders_reviews_comment_api.dart';
import '../api/fourth_team_class_api.dart';
import '../api/management_body_api.dart';
import '../api/most_assists_players_stats_info_api.dart';
import '../api/most_fouled_rc_players_stats_info_api.dart';
import '../api/most_fouled_yc_players_stats_info_api.dart';
import '../api/motm_players_stats_info_api.dart';
import '../api/player_of_the_month_stats_info_api.dart';
import '../api/sixth_team_class_api.dart';
import '../api/third_team_class_api.dart';
import '../api/top_defensive_players_stats_info_api.dart';
import '../api/top_gk_players_stats_info_api.dart';
import '../api/top_goals_players_stats_info_api.dart';
import '../api/trainings_games_reels_api.dart';
import '../bloc_navigation_bloc/navigation_bloc.dart';
import '../bottom_nav_stats_pages/bottom_navigator.dart';
import '../bottom_nav_stats_pages/players_table_page.dart';
import '../club_admin/club_admin_page.dart';
import '../details_pages/first_team_details_page.dart';
import '../home_page/home_page_deux.dart';
import '../notifier/a_upcoming_matches_notifier.dart';
import '../notifier/club_sponsors_notifier.dart';
import '../notifier/cum_motm_players_stats_info_notifier.dart';
import '../notifier/fifth_team_class_notifier.dart';
import '../notifier/first_team_class_notifier.dart';
import '../notifier/founders_reviews_comment_notifier.dart';
import '../notifier/fourth_team_class_notifier.dart';
import '../notifier/most_fouled_rc_players_stats_info_notifier.dart';
import '../notifier/most_fouled_yc_players_stats_info_notifier.dart';
import '../notifier/motm_players_stats_info_notifier.dart';
import '../notifier/player_of_the_month_stats_info_notifier.dart';
import '../notifier/sixth_team_class_notifier.dart';
import '../notifier/third_team_class_notifier.dart';
import '../notifier/top_defensive_players_stats_info_notifier.dart';
import '../notifier/top_gk_players_stats_info_notifier.dart';
import '../notifier/top_goals_players_stats_info_notifier.dart';
import '../notifier/trainings_games_reels_notifier.dart';
import '../thrown_searches/first_team_thrown_search.dart';

String clubName = "Coventry Phoenix FC";
// String postcode = "CV1 3WQ";
String city = "Coventry";
String stateName = "West Midlands";
String countryName = "The UK";
String thrownName = "All Players List - A";

String exitAppStatement = "Exit from App";
String exitAppTitle = "Come on!";
String exitAppSubtitle = "Do you really really want to?";
String exitAppNo = "Oh No";
String exitAppYes = "I Have To";

String whoWeAre = "Who We Are";
String aboutClub = "About $clubName";
// String tablesAndStats = "Tables and Stats";
String clubAdmin = "Go to Club Admin";
String acronymMeanings = "Acronym Meanings";
String aboutApp = "About App";

String fabStats = "Stats";

String networkSharedPreferencesKey = "first_time";
String networkSharedPreferencesTitle = "Welcome! 😎";
String networkSharedPreferencesContent = "Enjoy the GFA App and Stay Awesome.";
String networkSharedPreferencesButton = "Okay";

String welcomeOverviewSharedPreferencesKey = "toast_initial";

String appOverviewSharedPreferencesKey = "overview_time";
String appOverviewSharedPreferencesTitle = "APP OVERVIEW";
String appOverviewSharedPreferencesContentOne = "This App was developed for $clubName, a Football Club in $city, $stateName. $countryName.\n";
// String appOverviewSharedPreferencesContentTwo = "Our vision is to raise the total youth through comprehensive education.\n";
String appOverviewSharedPreferencesContentThree = "Welcome to our app, do check through and know more!";
String appOverviewSharedPreferencesButton = "Awesome";

Color backgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color appBarTextColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color appBarBackgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color appBarIconColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color modalColor = Colors.transparent;
Color modalBackgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color materialBackgroundColor = Colors.transparent;
Color cardBackgroundColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color splashColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color splashColorTwo = const Color.fromRGBO(215, 145, 119, 1.0);
Color iconColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color textColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color textColorTwo = Colors.white70;
Color dialogBackgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color borderColor = Colors.black;

class MyFirstTeamClassPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyFirstTeamClassPage({super.key, this.title, required this.clubId});

  final String? title;

  @override
  State<MyFirstTeamClassPage> createState() => _MyFirstTeamClassPage();
}

class _MyFirstTeamClassPage extends State<MyFirstTeamClassPage> {
  final TextEditingController bugController = TextEditingController();

  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;

  bool _isVisible = true;
  bool isLoading = true;

  void showToast() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // return false;
          Navigator.of(context).pop();
        }
        await _onWillPop();
      },
      canPop: true, // Allow the pop action
      child: Scaffold(
        body: Container(
          color: backgroundColor,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(MdiIcons.formatFloatLeft, color: iconColor),
                      onPressed: () {
                        showModalBottomSheet(
                            backgroundColor: modalColor,
                            context: context,
                            builder: (context) => Container(
                                  // height: 250,
                                  decoration: BoxDecoration(
                                    color: modalBackgroundColor,
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                  ),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColor,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0, bottom: 35.0, right: 8.0, left: 8.0),
                                        child: Wrap(
                                          children: <Widget>[
                                            ListTile(
                                                leading: Icon(
                                                  MdiIcons.tableMultiple,
                                                  color: iconColor,
                                                ),
                                                title: Text(
                                                  clubAdmin,
                                                  style: GoogleFonts.zillaSlab(color: textColor),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop(false);
                                                  _showAdminDialog(context);
                                                }),
                                            // ListTile(
                                            //     leading: Icon(MdiIcons.atom,
                                            //         color: iconColor),
                                            //     title: Text(
                                            //       whoWeAre,
                                            //       style: GoogleFonts.zillaSlab(
                                            //         color: textColor,
                                            //       ),
                                            //     ),
                                            //     onTap: () {
                                            //       Navigator.of(context)
                                            //           .pop(false);
                                            //       navigateToWhoWeArePage(
                                            //           context);
                                            //     }),
                                            ListTile(
                                              leading: Icon(MdiIcons.accountGroup, color: iconColor),
                                              title: Text(
                                                aboutClub,
                                                style: GoogleFonts.zillaSlab(
                                                  color: textColor,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop(false);
                                                navigateToAboutClubDetailsPage(context);
                                              },
                                            ),
                                            ListTile(
                                                leading: Icon(MdiIcons.sortAlphabeticalAscending, color: iconColor),
                                                title: Text(
                                                  acronymMeanings,
                                                  style: GoogleFonts.zillaSlab(
                                                    color: textColor,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop(false);
                                                  navigateToAcronymsMeaningsPage(context);
                                                }),
                                            ListTile(
                                              leading: Icon(MdiIcons.opacity, color: iconColor),
                                              title: Text(
                                                aboutApp,
                                                style: GoogleFonts.zillaSlab(
                                                  color: textColor,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop(false);
                                                navigateToAboutAppDetailsPage(context);
                                              },
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    navigateToAppStore(context);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                                                    child: Text(
                                                      'Give App Review',
                                                      style: GoogleFonts.quantico(
                                                        fontSize: 15,
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white70, // Change the color as needed
                                                        // decoration: TextDecoration.underline,
                                                        //   decorationColor: Colors.blueAccent,
                                                        //   decorationThickness: 2.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).pop(false);
                                                    openReportAppBugDialog(context);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                                                    child: Text(
                                                      'Report an App Bug',
                                                      style: GoogleFonts.quantico(
                                                        fontSize: 15,
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white70, // Change the color as needed
                                                        // decoration: TextDecoration.underline,
                                                        // decorationColor: textColor,
                                                        // decorationThickness: 2.0
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                      },
                    ),
                    IconButton(
                      icon: Icon(MdiIcons.magnify, color: iconColor),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: MyFirstTeamClassSearch(all: firstTeamClassNotifier.firstTeamClassList, clubId: widget.clubId),
                        );
                      },
                      tooltip: "Search",
                    ),
                  ],
                  backgroundColor: appBarBackgroundColor,
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(thrownName,
                            textAlign: TextAlign.start, style: GoogleFonts.abel(color: appBarTextColor, fontSize: 26.0, fontWeight: FontWeight.bold)),
                      ),
                      stretchModes: const [StretchMode.blurBackground],
                      background: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: firestoreStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), // Adjust the opacity as needed
                              BlendMode.darken,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        snapshot.data?.data()!['slivers_page_1'] ?? 0,
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          );
                        },
                      )),
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(left: 25, right: 10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ListView.builder(
                  itemBuilder: _buildProductItem,
                  itemCount: firstTeamClassNotifier.firstTeamClassList.length,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateTablesAndStatsDetails(context);
          },
          label: Text(
            fabStats,
            style: TextStyle(color: iconColor),
          ),
          icon: Icon(MdiIcons.alphaSBoxOutline, color: iconColor),
          splashColor: splashColorTwo,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: borderColor.withAlpha(50),
        ),
        child: Material(
          color: materialBackgroundColor,
          child: InkWell(
            splashColor: splashColor,
            onTap: () {
              firstTeamClassNotifier.currentFirstTeamClass = firstTeamClassNotifier.firstTeamClassList[index];
              navigateToSubPage(context);
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                        image: DecorationImage(
                            alignment: const Alignment(0, -1),
                            image: CachedNetworkImageProvider(firstTeamClassNotifier.firstTeamClassList[index].image!),
                            fit: BoxFit.cover)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              Text(firstTeamClassNotifier.firstTeamClassList[index].name!,
                                  style: GoogleFonts.tenorSans(color: textColor, fontSize: 17, fontWeight: FontWeight.w600)),
                              (() {
                                if (firstTeamClassNotifier.firstTeamClassList[index].captain == "Yes") {
                                  return Row(
                                    children: <Widget>[
                                      const SizedBox(width: 10),
                                      Icon(
                                        MdiIcons.shieldCheck,
                                        color: iconColor,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Visibility(
                                    visible: !_isVisible,
                                    child: Icon(
                                      MdiIcons.shieldCheck,
                                      color: iconColor,
                                    ),
                                  );
                                }
                              }()),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(firstTeamClassNotifier.firstTeamClassList[index].positionPlaying!,
                              style: GoogleFonts.varela(color: textColorTwo, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            backgroundColor: dialogBackgroundColor,
            title: Text(
              exitAppTitle,
              style: TextStyle(color: textColor),
            ),
            content: Text(
              exitAppSubtitle,
              style: TextStyle(color: textColor),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  exitAppNo,
                  style: TextStyle(color: textColor),
                ),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text(
                  exitAppYes,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future navigateToSubPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SubPage(clubId: widget.clubId)));
  }

  Future navigateTablesAndStatsDetails(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigator(
          mainPage: PlayersTablePage(clubId: widget.clubId), // Ensure that clubId is provided
          initialPage: 0, // Set the initial page as needed
          clubId: widget.clubId, // Pass the clubId to BottomNavigator
        ),
      ),
    );
    setState(() {}); // Refresh the UI if needed
  }

  Future navigateToAboutAppDetailsPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutAppDetails(clubId: widget.clubId)));
  }

  Future navigateToAcronymsMeaningsPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AcronymsMeanings(clubId: widget.clubId)));
  }

  Future navigateToAboutClubDetailsPage(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AboutClubDetails(
                  clubId: widget.clubId,
                )));
    setState(() {}); // Refresh the UI after fetching the data
  }

  Future navigateToWhoWeArePage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WhoWeAre()));
  }

  void navigateToAppStore(context) async {
    LaunchReview.launch(androidAppId: 'com.icdatinnovations.coventry_phoenix_fc', iOSAppId: '1637554276');
    Navigator.of(context).pop(false);
  }

  void openReportAppBugDialog(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: const Color.fromRGBO(57, 62, 70, 1),
        title: const Text(
          'Enter the Bug found please',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bugController,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                hintStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(
                color: Colors.white70,
              ),
              cursorColor: Colors.white,
              // Set cursor color here
              maxLines: 2, // Allow multiple lines for bug description
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String bugDescription = bugController.text.trim();

                bugController.clear();

                // Check if bugDescription is not empty before storing
                if (bugDescription.isNotEmpty) {
                  // Store bug report in Firestore
                  await FirebaseFirestore.instance
                      .collection('clubs')
                      .doc(widget.clubId)
                      .collection('BugReports') // Collection under specific clubId
                      .add({
                    'bug_description': bugDescription,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    // You can add a toast or any other UI feedback for successful bug submission
                    Fluttertoast.showToast(
                      msg: 'Bug report submitted!',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    );
                  }
                } else {
                  // Show a toast for empty bug description
                  Fluttertoast.showToast(
                    msg: 'Please enter a bug description',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminDialog(BuildContext context) {
    TextEditingController passcodeController = TextEditingController(); // Controller for the passcode TextField

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: const Color.fromRGBO(57, 62, 70, 1),
        title: const Text(
          'Enter the passcode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passcodeController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Passcode',
                hintStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(
                color: Colors.white70,
              ),
              cursorColor: Colors.white, // Set cursor color here
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredPasscode = passcodeController.text.trim();

                try {
                  // Retrieve the stored passcode from Firestore
                  DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
                      .collection('clubs')
                      .doc(widget.clubId)
                      .collection('SliversPages')
                      .doc('non_slivers_pages')
                      .get();

                  // Check if the document exists and retrieve the passcode
                  if (snapshot.exists) {
                    String storedPasscode = snapshot.data()?['admin_passcode'] ?? '';

                    // Check if the entered passcode matches the stored passcode
                    if (enteredPasscode == storedPasscode && context.mounted) {
                      Navigator.pop(context);
                      _showAdminWelcomeToast();
                      Navigator.push(context, SlideTransition1(MyClubAdminPage(clubId: widget.clubId)));
                    } else {
                      // Show a toast for incorrect passcode
                      Fluttertoast.showToast(
                        msg: 'Incorrect passcode',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  } else {
                    // Handle the case where the document does not exist
                    Fluttertoast.showToast(
                      msg: 'Passcode document does not exist',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                } catch (e) {
                  // Handle any errors that occur during the fetch
                  Fluttertoast.showToast(
                    msg: 'Error fetching passcode: $e',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminWelcomeToast() {
    Fluttertoast.showToast(
      msg: 'Welcome, Admin',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void startTime(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');

    if (firstTime != null && !firstTime) {
      // Not first time
    } else {
      // First time
      prefs.setBool(networkSharedPreferencesKey, false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          backgroundColor: dialogBackgroundColor,
          title: Text(
            networkSharedPreferencesTitle,
            style: TextStyle(color: textColor),
          ),
          content: Text(
            networkSharedPreferencesContent,
            style: TextStyle(color: textColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                networkSharedPreferencesButton,
                style: TextStyle(color: textColor),
              ),
            )
          ],
        ),
      );
    }
  }

  aboutAppWelcomeDialog() async {
    SharedPreferences appOverviewPrefs = await SharedPreferences.getInstance();
    bool? appOverviewChecked = appOverviewPrefs.getBool('overview_time');

    if (appOverviewChecked != null && !appOverviewChecked) {
      // Not first time
    } else {
      // First time
      appOverviewPrefs.setBool(appOverviewSharedPreferencesKey, false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          backgroundColor: dialogBackgroundColor,
          title: Text(
            appOverviewSharedPreferencesTitle,
            style: TextStyle(color: textColor),
          ),
          content: SizedBox(
            // height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Text(
                    appOverviewSharedPreferencesContentOne,
                    style: TextStyle(color: textColor),
                  ),
                  // Text(
                  //   appOverviewSharedPreferencesContentTwo,
                  //   style: TextStyle(
                  //       color: textColor
                  //   ),
                  // ),
                  Text(
                    appOverviewSharedPreferencesContentThree,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                appOverviewSharedPreferencesButton,
                style: TextStyle(color: textColor),
              ),
            )
          ],
        ),
      );
    }
  }

  // toastInitial() async {
  //   SharedPreferences appInitialPrefs = await SharedPreferences.getInstance();
  //   bool? appInitialChecked = appInitialPrefs.getBool('toast_initial');
  //
  //   if (appInitialChecked != null && !appInitialChecked) {
  //     // Not first time
  //   }
  //   else {
  //     // First time
  //     appInitialPrefs.setBool(welcomeOverviewSharedPreferencesKey, false);
  //     Toast.show("You are awesome, welcome. 😎",
  //         duration: Toast.lengthLong,
  //         gravity: Toast.bottom,
  //         webTexColor: cardBackgroundColor,
  //         backgroundColor: textColorTwo,
  //         backgroundRadius: 10
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();

    firestoreStream = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('SliversPages')
        .doc('slivers_pages')
        .snapshots()
        .distinct(); // Ensure distinct events

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

    ClubArialNotifier clubArialNotifier = Provider.of<ClubArialNotifier>(context, listen: false);
    _fetchClubArialAndUpdateNotifier(clubArialNotifier);

    AchievementsNotifier achievementsNotifier = Provider.of<AchievementsNotifier>(context, listen: false);
    _fetchAchievementsAndUpdateNotifier(achievementsNotifier);

    MostAssistsPlayersStatsAndInfoNotifier mostAssistsNotifier = Provider.of<MostAssistsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostAssistsPlayersStatsAndUpdateNotifier(mostAssistsNotifier);

    MostFouledYCPlayersStatsAndInfoNotifier mostFouledYCNotifier = Provider.of<MostFouledYCPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostFouledYCPlayersStatsAndUpdateNotifier(mostFouledYCNotifier);

    MostFouledRCPlayersStatsAndInfoNotifier mostFouledRCNotifier = Provider.of<MostFouledRCPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostFouledRCPlayersStatsAndUpdateNotifier(mostFouledRCNotifier);

    TopGoalsPlayersStatsAndInfoNotifier topGoalsNotifier = Provider.of<TopGoalsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopGoalsPlayersStatsAndUpdateNotifier(topGoalsNotifier);

    TopGKPlayersStatsAndInfoNotifier topGKNotifier = Provider.of<TopGKPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopGKPlayersStatsAndUpdateNotifier(topGKNotifier);

    TopDefensivePlayersStatsAndInfoNotifier topDefensiveNotifier = Provider.of<TopDefensivePlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopDefensivePlayersStatsAndUpdateNotifier(topDefensiveNotifier);

    MOTMPlayersStatsAndInfoNotifier mOTMNotifier = Provider.of<MOTMPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMOTMPlayersStatsAndUpdateNotifier(mOTMNotifier);

    CumMOTMPlayersStatsAndInfoNotifier cumMOTMNotifier = Provider.of<CumMOTMPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchCumMOTMPlayersStatsAndUpdateNotifier(cumMOTMNotifier);

    TrainingsAndGamesReelsNotifier trainingsAndGamesNotifier = Provider.of<TrainingsAndGamesReelsNotifier>(context, listen: false);
    _fetchTrainingsAndGamesReelsAndUpdateNotifier(trainingsAndGamesNotifier);

    PlayerOfTheMonthStatsAndInfoNotifier playerOfTheMonthNotifier = Provider.of<PlayerOfTheMonthStatsAndInfoNotifier>(context, listen: false);
    _fetchPlayerOfTheMonthStatsAndUpdateNotifier(playerOfTheMonthNotifier);

    FoundersReviewsCommentNotifier foundersReviewsNotifier = Provider.of<FoundersReviewsCommentNotifier>(context, listen: false);
    _fetchFoundersReviewsCommentAndUpdateNotifier(foundersReviewsNotifier);

    UpcomingMatchesNotifier upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context, listen: false);
    _fetchUpcomingMatchesAndUpdateNotifier(upcomingMatchesNotifier);

    ClubSponsorsNotifier clubSponsorsNotifier = Provider.of<ClubSponsorsNotifier>(context, listen: false);
    _fetchClubSponsorsAndUpdateNotifier(clubSponsorsNotifier);

    setState(() {
      isLoading = false;
    });

    startTime(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchFirstTeamClassAndUpdateNotifier(FirstTeamClassNotifier firstTeamNotifier) async {
    await getFirstTeamClass(firstTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI after fetching the data
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

  Future<void> _fetchClubArialAndUpdateNotifier(ClubArialNotifier clubArialNotifier) async {
    await getClubArial(clubArialNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchAchievementsAndUpdateNotifier(AchievementsNotifier achievementsNotifier) async {
    await getAchievements(achievementsNotifier, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  Future<void> _fetchMostAssistsPlayersStatsAndUpdateNotifier(MostAssistsPlayersStatsAndInfoNotifier notifier) async {
    await getMostAssistsPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchMostFouledYCPlayersStatsAndUpdateNotifier(MostFouledYCPlayersStatsAndInfoNotifier notifier) async {
    await getMostFouledYCPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchMostFouledRCPlayersStatsAndUpdateNotifier(MostFouledRCPlayersStatsAndInfoNotifier notifier) async {
    await getMostFouledRCPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchTopGoalsPlayersStatsAndUpdateNotifier(TopGoalsPlayersStatsAndInfoNotifier notifier) async {
    await getTopGoalsPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchTopGKPlayersStatsAndUpdateNotifier(TopGKPlayersStatsAndInfoNotifier notifier) async {
    await getTopGKPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchTopDefensivePlayersStatsAndUpdateNotifier(TopDefensivePlayersStatsAndInfoNotifier notifier) async {
    await getTopDefensivePlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchMOTMPlayersStatsAndUpdateNotifier(MOTMPlayersStatsAndInfoNotifier notifier) async {
    await getMOTMPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchCumMOTMPlayersStatsAndUpdateNotifier(CumMOTMPlayersStatsAndInfoNotifier notifier) async {
    await getCumMOTMPlayersStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchTrainingsAndGamesReelsAndUpdateNotifier(TrainingsAndGamesReelsNotifier notifier) async {
    await getTrainingsAndGamesReels(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchPlayerOfTheMonthStatsAndUpdateNotifier(PlayerOfTheMonthStatsAndInfoNotifier notifier) async {
    await getPlayerOfTheMonthStatsAndInfo(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchFoundersReviewsCommentAndUpdateNotifier(FoundersReviewsCommentNotifier notifier) async {
    await getFoundersReviewsComment(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchUpcomingMatchesAndUpdateNotifier(UpcomingMatchesNotifier notifier) async {
    await getUpcomingMatches(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchClubSponsorsAndUpdateNotifier(ClubSponsorsNotifier notifier) async {
    await getClubSponsors(notifier, widget.clubId);

    setState(() {});
  }
}
