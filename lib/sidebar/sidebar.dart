import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_icons/simple_icons.dart';

import '/bottom_nav_stats_pages/players_stats_info_page.dart';
import '/bottom_nav_stats_pages/players_table_page.dart';
import '../api/get_teams_classes_visibility_api.dart';
import '../bloc_navigation_bloc/navigation_bloc.dart';
import '../bottom_nav_stats_pages/bottom_navigator.dart';
import '../bottom_nav_stats_pages/matches_page/a_tabview_matches_page.dart';
import '../bottom_nav_stats_pages/social_media/b_tabview_social_media_page.dart';
import '../notifier/a_club_global_notifier.dart';
import '../notifier/sidebar_notifier.dart';
import '../sidebar/menu_item.dart';

String clubName = "";
String sidebarSubtitle = "";
String sidebarClubLogo = "";

const String defaultReturningPlayersTitle = "First Team Players";
const String defaultNewPlayersTitle = "Second Team Players";
const String defaultThirdTeamClassTitle = "Reserve Team Players";
const String defaultFourthTeamClassTitle = "Fourth Team Players";
const String defaultFifthTeamClassTitle = "Fifth Team Players";
const String defaultSixthTeamClassTitle = "Sixth Team Players";
const String defaultCaptainsTitle = "CPFC Captains";
const String defaultCoachesTitle = "Coaching Staff";
const String defaultManagementBodyTitle = "Management Body";
String sponsorsTitle = "Club Sponsors";
// String adminTitle = "Club Admin";

String aiStatsTitle = "Ask ChatGFA";

String exitAppStatement = "Exit from App";
String exitAppTitle = "Come on!";
String exitAppSubtitle = "Do you really really want to?";
String exitAppNo = "Oh No";
String exitAppYes = "I Have To";

String fmTitle = "CPFC More";
String tmTitle = "Teams";
String ytTitle = "Youtube Page";
String aptTitle = "All Players Table";
String tppTitle = "Top Performing Players";
String pmTitle = "Past Matches";
String umTitle = "Upcoming Fixtures";
String cbTitle = "Club Background";

Color gradientColor = const Color.fromRGBO(24, 26, 36, 1.0);
Color gradientColorTwo = Colors.white;
Color gradientColorThree = const Color.fromRGBO(215, 71, 108, 1.0);
Color gradientColorFour = const Color.fromRGBO(255, 107, 53, 1.0);
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
Color splashColorThree = Colors.white;
Color textColor = Colors.white;
Color textColorTwo = const Color.fromRGBO(24, 26, 36, 1.0);
Color textShadowColor = Colors.white;

class SideBar extends StatefulWidget {
  final String clubId;

  const SideBar({super.key, required this.clubId});

  @override
  State<StatefulWidget> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar> {
  int _currentNAVSelected = 0;
  bool _isClubSponsorsClicked = false; // New variable to track the "Club Sponsors" click

  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStreamTwo;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscriptionTwo;
  late Future<Map<String, Map<String, dynamic>>> _teamVisibilityFuture;

  _onSelected(int index) {
    if (index == 10 /**|| index == 8 */) {
      // Check if the selected item is "Club Sponsors"
      _isClubSponsorsClicked = true;
      // showToast("Club Sponsors Clicked"); // Show the toast message
    } else {
      _isClubSponsorsClicked = false;
    }
    setState(() => _currentNAVSelected = index);
  }

  late AnimationController _animationController;
  late StreamController<bool> isSidebarOpenedStreamController;
  late Stream<bool> isSidebarOpenedStream;
  late StreamSink<bool> isSidebarOpenedSink;
  final bool isSidebarOpened = true;
  final _animationDuration = const Duration(milliseconds: 500);

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

    firestoreStreamTwo = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('AboutClub')
        .doc('about_club_page')
        .snapshots()
        .distinct(); // Ensure distinct events

    // Listen to the stream
    streamSubscriptionTwo = firestoreStreamTwo.listen((snapshot) {
      if (snapshot.exists && mounted) {
        var data = snapshot.data()!;
        final clubGlobalProvider = Provider.of<ClubGlobalProvider>(context, listen: false);
        clubGlobalProvider.setClubName(data['club_name']);
        clubGlobalProvider.setClubLogo(data['club_logo']);
        clubGlobalProvider.setClubIcon(data['club_icon']);
        clubGlobalProvider.setClubYID(data['youtube_name']);

        clubName = data['club_name'];
        sidebarSubtitle = data['sidebar_subtitle'];
        sidebarClubLogo = data['club_logo'];
      }
    });

    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;

    _teamVisibilityFuture = getTeamClassVisibilityAndTitles(widget.clubId);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      Provider.of<SideBarNotifier>(context, listen: false).setIsOpened(false);
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      Provider.of<SideBarNotifier>(context, listen: false).setIsOpened(true);
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    var screeWidthLeft = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSidebarOpenedAsync) {
        return Visibility(
          visible: !_isClubSponsorsClicked, // Hide the sidebar when "Club Sponsors" is clicked,
          child: AnimatedPositioned(
            duration: _animationDuration,
            top: 0,
            bottom: 0,
            left: isSidebarOpenedAsync.data! ? -screeWidthLeft : 0,
            right: isSidebarOpenedAsync.data! ? screeWidthLeft - 55 : 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    color: containerBackgroundColor,
                    elevation: 20,
                    margin: const EdgeInsets.all(0),
                    child: Align(
                      alignment: const Alignment(0, -1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [gradientColor, gradientColor])),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(
                                height: 60,
                              ),
                              Stack(
                                children: <Widget>[
                                  Opacity(
                                    opacity: 0.7,
                                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: firestoreStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else {
                                          return Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height * 0.4,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                alignment: const Alignment(0, -0.8),
                                                image: CachedNetworkImageProvider(
                                                  snapshot.data?.data()!['slivers_page_7'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [linearGradientColor, linearGradientColorTwo.withAlpha(50)],
                                                stops: const [0.3, 1],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: boxShadowColor,
                                                  blurRadius: 12,
                                                  offset: const Offset(3, 12),
                                                )
                                              ],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Material(
                                              color: materialBackgroundColor,
                                              child: InkWell(
                                                splashColor: splashColor,
                                                onTap: () {},
                                                child: Align(
                                                  alignment: const Alignment(0, 0.9),
                                                  child: ListTile(
                                                    title: Text(
                                                      clubName.toUpperCase(),
                                                      style: GoogleFonts.gorditas(
                                                          color: textColor,
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w700,
                                                          shadows: <Shadow>[
                                                            Shadow(blurRadius: 50, color: textShadowColor, offset: Offset.fromDirection(100, 12))
                                                          ]),
                                                    ),
                                                    subtitle: Text(
                                                      sidebarSubtitle,
                                                      style: GoogleFonts.varela(
                                                        color: textColor,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: firestoreStreamTwo,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Opacity(
                                                opacity: 0.6,
                                                child: Container(
                                                  width: 140.0,
                                                  height: 140.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: CachedNetworkImageProvider(
                                                        snapshot.data?.data()!['club_logo'],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ],
                              ),

                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: dividerColor.withOpacity(0.3),
                                indent: 32,
                                endIndent: 32,
                              ),

                              FutureBuilder<Map<String, Map<String, dynamic>>>(
                                future: _teamVisibilityFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text("No visibility data available"));
                                  }

                                  final teamData = snapshot.data!;
                                  final visibleTeams = teamData.values.where((data) => data['isVisible'] as bool).toList();

                                  // Define titles based on fetched data or default to hardcoded ones
                                  final String returningPlayersTitle =
                                      teamData['FirstTeamClass']?['title'] as String? ?? defaultReturningPlayersTitle;
                                  final String newPlayersTitle = teamData['SecondTeamClass']?['title'] as String? ?? defaultNewPlayersTitle;
                                  final String thirdTeamClassTitle = teamData['ThirdTeamClass']?['title'] as String? ?? defaultThirdTeamClassTitle;
                                  final String fourthTeamClassTitle = teamData['FourthTeamClass']?['title'] as String? ?? defaultFourthTeamClassTitle;
                                  final String fifthTeamClassTitle = teamData['FifthTeamClass']?['title'] as String? ?? defaultFifthTeamClassTitle;
                                  final String sixthTeamClassTitle = teamData['SixthTeamClass']?['title'] as String? ?? defaultSixthTeamClassTitle;
                                  final String captainsTitle = teamData['Captains']?['title'] as String? ?? defaultCaptainsTitle;
                                  final String coachesTitle = teamData['Coaches']?['title'] as String? ?? defaultCoachesTitle;
                                  final String managementBodyTitle = teamData['ManagementBody']?['title'] as String? ?? defaultManagementBodyTitle;

                                  // If 5 or fewer teams are visible, don't use Theme and ExpansionTile
                                  if (visibleTeams.length <= 5) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (teamData['FirstTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 0,
                                            icon: MdiIcons.soccer,
                                            title: returningPlayersTitle,
                                            event: NavigationEvents.myFirstTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['SecondTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 1,
                                            icon: MdiIcons.soccer,
                                            title: newPlayersTitle,
                                            event: NavigationEvents.mySecondTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['ThirdTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 2,
                                            icon: MdiIcons.soccer,
                                            title: thirdTeamClassTitle,
                                            event: NavigationEvents.myThirdTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['FourthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 3,
                                            icon: MdiIcons.soccer,
                                            title: fourthTeamClassTitle,
                                            event: NavigationEvents.myFourthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['FifthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 4,
                                            icon: MdiIcons.soccer,
                                            title: fifthTeamClassTitle,
                                            event: NavigationEvents.myFifthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['SixthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 5,
                                            icon: MdiIcons.soccer,
                                            title: sixthTeamClassTitle,
                                            event: NavigationEvents.mySixthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['Captains']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 6,
                                            icon: MdiIcons.accountStar,
                                            title: captainsTitle,
                                            event: NavigationEvents.myCaptainsPageClickedEvent,
                                          ),
                                        if (teamData['Coaches']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 7,
                                            icon: MdiIcons.podiumSilver,
                                            title: coachesTitle,
                                            event: NavigationEvents.myCoachesPageClickedEvent,
                                          ),
                                        if (teamData['ManagementBody']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 8,
                                            icon: MdiIcons.accountTie,
                                            title: managementBodyTitle,
                                            event: NavigationEvents.myManagementBodyPageClickedEvent,
                                          ),
                                      ],
                                    );
                                  }

                                  // If more than 5 teams are visible, use Theme and ExpansionTile
                                  return Theme(
                                    data: ThemeData.dark().copyWith(primaryColor: Colors.white),
                                    child: ExpansionTile(
                                      title: MenuItems(
                                        icon: SimpleIcons.spond,
                                        title: tmTitle,
                                      ),
                                      children: [
                                        if (teamData['FirstTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 0,
                                            icon: MdiIcons.soccer,
                                            title: returningPlayersTitle,
                                            event: NavigationEvents.myFirstTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['SecondTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 1,
                                            icon: MdiIcons.soccer,
                                            title: newPlayersTitle,
                                            event: NavigationEvents.mySecondTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['ThirdTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 2,
                                            icon: MdiIcons.soccer,
                                            title: thirdTeamClassTitle,
                                            event: NavigationEvents.myThirdTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['FourthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 3,
                                            icon: MdiIcons.soccer,
                                            title: fourthTeamClassTitle,
                                            event: NavigationEvents.myFourthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['FifthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 4,
                                            icon: MdiIcons.soccer,
                                            title: fifthTeamClassTitle,
                                            event: NavigationEvents.myFifthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['SixthTeamClass']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 5,
                                            icon: MdiIcons.soccer,
                                            title: sixthTeamClassTitle,
                                            event: NavigationEvents.mySixthTeamClassPageClickedEvent,
                                          ),
                                        if (teamData['Captains']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 6,
                                            icon: MdiIcons.accountStar,
                                            title: captainsTitle,
                                            event: NavigationEvents.myCaptainsPageClickedEvent,
                                          ),
                                        if (teamData['Coaches']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 7,
                                            icon: MdiIcons.podiumSilver,
                                            title: coachesTitle,
                                            event: NavigationEvents.myCoachesPageClickedEvent,
                                          ),
                                        if (teamData['ManagementBody']?['isVisible'] ?? true)
                                          _buildTeamMenuItem(
                                            context,
                                            index: 8,
                                            icon: MdiIcons.accountTie,
                                            title: managementBodyTitle,
                                            event: NavigationEvents.myManagementBodyPageClickedEvent,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              Divider(
                                height: 5,
                                thickness: 0.5,
                                color: dividerColor.withOpacity(0.3),
                                indent: 12,
                                endIndent: 15,
                              ),
                              Material(
                                color: _currentNAVSelected == 9 ? gradientColorTwo.withOpacity(0.3) : materialBackgroundColor,
                                child: InkWell(
                                  splashColor: splashColorThree,
                                  onTap: () {
                                    // _onSelected(7);
                                    // onIconPressed();
                                    // BlocProvider.of<NavigationBloc>(context).add(
                                    //     NavigationEvents
                                    //         .myClubSponsorsPageClickedEvent);

                                    showToast();
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: MenuItems(icon: SimpleIcons.rubysinatra, title: aiStatsTitle, textColor: gradientColorFour),
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
                                color: _currentNAVSelected == 10 ? gradientColorTwo.withOpacity(0.3) : materialBackgroundColor,
                                child: InkWell(
                                  splashColor: splashColorThree,
                                  onTap: () {
                                    _onSelected(10);
                                    onIconPressed();
                                    BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.myClubSponsorsPageClickedEvent);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: MenuItems(icon: SimpleIcons.icinga, title: sponsorsTitle, textColor: gradientColorThree),
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
                              Theme(
                                  data: ThemeData.dark().copyWith(primaryColor: Colors.white),
                                  child: ExpansionTile(
                                      title: MenuItems(
                                        icon: SimpleIcons.mobxstatetree,
                                        title: fmTitle,
                                      ),
                                      children: <Widget>[
                                        Material(
                                          color: _currentNAVSelected == 11 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                          child: InkWell(
                                            splashColor: splashColorTwo,
                                            onTap: () {
                                              _onSelected(11);
                                              onIconPressed();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BottomNavigator(
                                                    mainPage: TabviewSocialMediaPage(clubId: widget.clubId),
                                                    initialPage: 3,
                                                    clubId: widget.clubId,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: MenuItems(
                                                icon: SimpleIcons.youtube,
                                                title: ytTitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: _currentNAVSelected == 12 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                          child: InkWell(
                                            splashColor: splashColorTwo,
                                            onTap: () {
                                              _onSelected(12);
                                              onIconPressed();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BottomNavigator(
                                                    mainPage: PlayersTablePage(clubId: widget.clubId),
                                                    initialPage: 0,
                                                    clubId: widget.clubId,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: MenuItems(
                                                icon: MdiIcons.accountGroup,
                                                title: aptTitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: _currentNAVSelected == 13 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                          child: InkWell(
                                            splashColor: splashColorTwo,
                                            onTap: () {
                                              _onSelected(13);
                                              onIconPressed();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BottomNavigator(
                                                    mainPage: PlayersStatsAndInfoPage(clubId: widget.clubId),
                                                    initialPage: 1,
                                                    clubId: widget.clubId,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: MenuItems(
                                                icon: SimpleIcons.starz,
                                                title: tppTitle,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Material(
                                        //   color: _currentNAVSelected == 11 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                        //   child: InkWell(
                                        //     splashColor: splashColorTwo,
                                        //     onTap: () {
                                        //       _onSelected(11);
                                        //       onIconPressed();
                                        //       Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //           builder: (context) => const BottomNavigator(mainPage: TabviewMatchesPage(initialPage: 0), initialPage: 2), // Set initialPage to 0 for 'Results'
                                        //         ),
                                        //       );
                                        //     },
                                        //     child: Align(
                                        //       alignment: Alignment.centerLeft,
                                        //       child: MenuItems(
                                        //         icon: SimpleIcons.strongswan,
                                        //         title: pmTitle,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),

                                        Material(
                                          color: _currentNAVSelected == 14 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                          child: InkWell(
                                            splashColor: splashColorTwo,
                                            onTap: () {
                                              _onSelected(14);
                                              onIconPressed();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BottomNavigator(
                                                    mainPage: TabviewMatchesPage(initialPage: 1, clubId: widget.clubId),
                                                    initialPage: 2,
                                                    clubId: widget.clubId,
                                                  ), // Set initialPage to 1 for 'Fixtures'
                                                ),
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: MenuItems(
                                                icon: SimpleIcons.googlecolab,
                                                title: umTitle,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Material(
                                        //   color: _currentNAVSelected == 13 ? containerBackgroundColor.withOpacity(0.3) : materialBackgroundColor,
                                        //   child: InkWell(
                                        //     splashColor: splashColorTwo,
                                        //     onTap: () {
                                        //       _onSelected(13);
                                        //       onIconPressed();
                                        //       Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //           builder: (context) => const AboutClubDetails(),
                                        //         ),
                                        //       );
                                        //     },
                                        //     child: Align(
                                        //       alignment: Alignment.centerLeft,
                                        //       child: MenuItems(
                                        //         icon: MdiIcons.accountGroup,
                                        //         title: cbTitle,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ])),
                              // Material(
                              //   color: _currentNAVSelected == 8
                              //       ? gradientColorTwo.withOpacity(0.3)
                              //       : materialBackgroundColor,
                              //   child: InkWell(
                              //     splashColor: splashColorThree,
                              //     onTap: () {
                              //       _onSelected(8);
                              //       onIconPressed();
                              //       BlocProvider.of<NavigationBloc>(context).add(
                              //           NavigationEvents
                              //               .myClubAdminPageClickedEvent);
                              //     },
                              //     child: Align(
                              //       alignment: Alignment.centerLeft,
                              //       child: MenuItems(
                              //           icon: MdiIcons.security,
                              //           title: adminTitle,
                              //           textColor: gradientColorTwo
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 50, top: 10),
                                child: Material(
                                  color: materialBackgroundColor,
                                  child: InkWell(
                                    splashColor: splashColorThree,
                                    onTap: () {
                                      _onWillPop();
                                      onIconPressed();
                                    },
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: MenuItems(
                                        icon: MdiIcons.logout,
                                        title: exitAppStatement,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(-0.1, -0.9),
                  child: GestureDetector(
                    onTap: () {
                      onIconPressed();
                    },
                    child: ClipPath(
                      clipper: CustomMenuClipper(),
                      child: Card(
                        elevation: 20,
                        margin: const EdgeInsets.all(0),
                        child: Container(
                          width: 35,
                          height: 110,
                          color: containerBackgroundColor,
                          alignment: Alignment.centerLeft,
                          child: AnimatedIcon(
                            progress: _animationController.view,
                            icon: _animationController.status == AnimationStatus.completed ? AnimatedIcons.menu_home : AnimatedIcons.close_menu,
                            color: containerIconColor,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamMenuItem(BuildContext context,
      {required int index, required IconData icon, required String title, required NavigationEvents event}) {
    return Material(
      color: _currentNAVSelected == index ? gradientColorTwo.withOpacity(0.3) : materialBackgroundColor,
      child: InkWell(
        splashColor: splashColorThree,
        onTap: () {
          _onSelected(index);
          onIconPressed();
          BlocProvider.of<NavigationBloc>(context).add(event);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: MenuItems(
            icon: icon,
            title: title,
          ),
        ),
      ),
    );
  }

  Future<bool>? _onWillPop() async {
    //moves the screen up
    // if (Provider.of<SideBarNotifier>(context, listen: false).isOpened) {
    //   onIconPressed();
    //   return false;
    // }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            backgroundColor: dialogBackgroundColor,
            title: Text(
              exitAppTitle,
              style: TextStyle(color: dialogTextColor),
            ),
            content: Text(
              exitAppSubtitle,
              style: TextStyle(color: dialogTextColor),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  exitAppNo,
                  style: TextStyle(color: dialogTextColor),
                ),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text(
                  exitAppYes,
                  style: TextStyle(color: dialogTextColor),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = materialBackgroundColor;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 10);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CustomPILLCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomPILLCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 24.0;

    var david = Paint();
    david.shader = ui.Gradient.linear(
        const Offset(0, 0), Offset(size.width, size.height), [HSLColor.fromColor(startColor).withLightness(0.8).toColor(), endColor]);

    var jesus = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(jesus, david);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

void showToast() {
  Fluttertoast.showToast(
    msg: "Coming Soon  ⚽️💎💎",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.deepOrangeAccent,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
