import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../api/cum_motm_players_stats_info_api.dart';
import '../api/most_assists_players_stats_info_api.dart';
import '../api/most_fouled_rc_players_stats_info_api.dart';
import '../api/most_fouled_yc_players_stats_info_api.dart';
import '../api/motm_players_stats_info_api.dart';
import '../api/player_of_the_month_stats_info_api.dart';
import '../api/top_defensive_players_stats_info_api.dart';
import '../api/top_gk_players_stats_info_api.dart';
import '../api/top_goals_players_stats_info_api.dart';
import '../api/trainings_games_reels_api.dart';
import '../notifier/cum_motm_players_stats_info_notifier.dart';
import '../notifier/most_assists_players_stats_info_notifier.dart';
import '../notifier/most_fouled_rc_players_stats_info_notifier.dart';
import '../notifier/most_fouled_yc_players_stats_info_notifier.dart';
import '../notifier/motm_players_stats_info_notifier.dart';
import '../notifier/player_of_the_month_stats_info_notifier.dart';
import '../notifier/top_defensive_players_stats_info_notifier.dart';
import '../notifier/top_gk_players_stats_info_notifier.dart';
import '../notifier/top_goals_players_stats_info_notifier.dart';
import '../notifier/trainings_games_reels_notifier.dart';
import 'matches_page/a_tabview_matches_page.dart';
import 'players_stats_info_page.dart';
import 'players_table_page.dart';
import 'social_media/b_tabview_social_media_page.dart';
import 'trainings_games_reels_page.dart';

late TrainingsAndGamesReelsNotifier trainingsAndGamesReelsNotifier;
late PlayerOfTheMonthStatsAndInfoNotifier playerOfTheMonthStatsAndInfoNotifier;
late MostFouledYCPlayersStatsAndInfoNotifier mostFouledYCPlayersStatsAndInfoNotifier;
late MostFouledRCPlayersStatsAndInfoNotifier mostFouledRCPlayersStatsAndInfoNotifier;
late TopGKPlayersStatsAndInfoNotifier topGKPlayersStatsAndInfoNotifier;
late TopDefensivePlayersStatsAndInfoNotifier topDefensivePlayersStatsAndInfoNotifier;
late TopGoalsPlayersStatsAndInfoNotifier topGoalsPlayersStatsAndInfoNotifier;
late MostAssistsPlayersStatsAndInfoNotifier mostAssistsPlayersStatsAndInfoNotifier;
late MOTMPlayersStatsAndInfoNotifier motmPlayersStatsAndInfoNotifier;
late CumMOTMPlayersStatsAndInfoNotifier cumMOTMPlayersStatsAndInfoNotifier;

Color? backgroundColor = const Color.fromRGBO(34, 40, 49, 1);
Color? cardBackgroundColorTwo = const Color.fromRGBO(34, 40, 49, 0.6);
Color? cardBackgroundColor = const Color.fromRGBO(57, 62, 70, 1);
Color? goalsScoredTextColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarIconColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarBackgroundColor = const Color.fromRGBO(34, 40, 49, 1);

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key, required this.mainPage, required this.initialPage});

  final Widget mainPage;
  final int initialPage;

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  bool toggle = false;
  int selectedPage = 0;

  final _pageOption = [
    const PlayersTablePage(),
    const PlayersStatsAndInfoPage(),
    const TabviewMatchesPage(initialPage: 1),
    // const SeasonTimeline(),
    const TabviewSocialMediaPage(),
    TrainingsAndGamesReelsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOption[selectedPage],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: backgroundColor, boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))]),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GNav(
                    tabBorderRadius: 5,
                    rippleColor: Colors.blueGrey,
                    hoverColor: Colors.white30,
                    gap: 2,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: const Duration(microseconds: 400),
                    tabBackgroundColor: (cardBackgroundColor)!,
                    color: Colors.black,
                    haptic: true,
                    tabs: [
                      const GButton(
                          gap: 2,
                          icon: Icons.query_stats,
                          textColor: Color.fromRGBO(247, 246, 242, 1),
                          iconColor: Colors.white30,
                          iconActiveColor: Color.fromRGBO(247, 246, 242, 1),
                          rippleColor: Colors.blueGrey,
                          text: 'A.P.T.'),
                      const GButton(
                        gap: 2,
                        icon: Icons.workspace_premium,
                        textColor: Color.fromRGBO(247, 246, 242, 1),
                        iconColor: Colors.white30,
                        iconActiveColor: Color.fromRGBO(247, 246, 242, 1),
                        text: 'Top Players',
                        rippleColor: Colors.blueGrey,
                      ),
                      GButton(
                        gap: 2,
                        icon: MdiIcons.soccerField,
                        textColor: const Color.fromRGBO(247, 246, 242, 1),
                        iconColor: Colors.white30,
                        iconActiveColor: const Color.fromRGBO(247, 246, 242, 1),
                        text: 'Matches',
                        rippleColor: Colors.blueGrey,
                      ),
                      // const GButton(
                      //   gap: 2,
                      //   icon: Icons.leaderboard,
                      //   textColor: Color.fromRGBO(247, 246, 242, 1),
                      //   iconColor: Colors.white30,
                      //   iconActiveColor: Color.fromRGBO(247, 246, 242, 1),
                      //   text: 'Timeline',
                      //   rippleColor: Colors.blueGrey,
                      // ),
                      const GButton(
                        gap: 2,
                        icon: Icons.featured_play_list,
                        textColor: Color.fromRGBO(247, 246, 242, 1),
                        iconColor: Colors.white30,
                        iconActiveColor: Color.fromRGBO(247, 246, 242, 1),
                        text: 'Social Media',
                        rippleColor: Colors.blueGrey,
                      ),
                      GButton(
                        gap: 2,
                        icon: Icons.view_carousel_outlined,
                        textColor: const Color.fromRGBO(255, 141, 41, 0.7),
                        iconColor: Colors.white30,
                        iconActiveColor: const Color.fromRGBO(255, 141, 41, 0.7),
                        text: 'Reels',
                        activeBorder: Border.all(color: const Color.fromRGBO(255, 141, 41, 0.7), width: 1),
                        border: Border.all(color: Colors.transparent),
                        rippleColor: Colors.white30,
                      ),
                    ],
                    selectedIndex: selectedPage,
                    onTabChange: (index) {
                      setState(() {
                        selectedPage = index;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    TrainingsAndGamesReelsNotifier trainingsAndGamesNotifier = Provider.of<TrainingsAndGamesReelsNotifier>(context, listen: false);
    _fetchTrainingsAndGamesReelsAndUpdateNotifier(trainingsAndGamesNotifier);

    PlayerOfTheMonthStatsAndInfoNotifier playerOfTheMonthNotifier = Provider.of<PlayerOfTheMonthStatsAndInfoNotifier>(context, listen: false);
    _fetchPlayerOfTheMonthStatsAndUpdateNotifier(playerOfTheMonthNotifier);

    MostFouledYCPlayersStatsAndInfoNotifier mostFouledYCNotifier = Provider.of<MostFouledYCPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostFouledYCPlayersStatsAndUpdateNotifier(mostFouledYCNotifier);

    MostFouledRCPlayersStatsAndInfoNotifier mostFouledRCNotifier = Provider.of<MostFouledRCPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostFouledRCPlayersStatsAndUpdateNotifier(mostFouledRCNotifier);

    TopGKPlayersStatsAndInfoNotifier topGKNotifier = Provider.of<TopGKPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopGKPlayersStatsAndUpdateNotifier(topGKNotifier);

    TopDefensivePlayersStatsAndInfoNotifier topDefensiveNotifier = Provider.of<TopDefensivePlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopDefensivePlayersStatsAndUpdateNotifier(topDefensiveNotifier);

    MOTMPlayersStatsAndInfoNotifier mOTMNotifier = Provider.of<MOTMPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMOTMPlayersStatsAndUpdateNotifier(mOTMNotifier);

    cumMOTMPlayersStatsAndInfoNotifier = Provider.of<CumMOTMPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchCumMOTMPlayersStatsAndUpdateNotifier(cumMOTMPlayersStatsAndInfoNotifier);

    topGoalsPlayersStatsAndInfoNotifier = Provider.of<TopGoalsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopGoalsPlayersStatsAndUpdateNotifier(topGoalsPlayersStatsAndInfoNotifier);

    mostAssistsPlayersStatsAndInfoNotifier = Provider.of<MostAssistsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostAssistsPlayersStatsAndUpdateNotifier(mostAssistsPlayersStatsAndInfoNotifier);

    setState(() {
      selectedPage = widget.initialPage;
    });

    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchTrainingsAndGamesReelsAndUpdateNotifier(TrainingsAndGamesReelsNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getTrainingsAndGamesReels(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchPlayerOfTheMonthStatsAndUpdateNotifier(PlayerOfTheMonthStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getPlayerOfTheMonthStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchMostFouledYCPlayersStatsAndUpdateNotifier(MostFouledYCPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getMostFouledYCPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchMostFouledRCPlayersStatsAndUpdateNotifier(MostFouledRCPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getMostFouledRCPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchTopGKPlayersStatsAndUpdateNotifier(TopGKPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getTopGKPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchTopDefensivePlayersStatsAndUpdateNotifier(TopDefensivePlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getTopDefensivePlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchMOTMPlayersStatsAndUpdateNotifier(MOTMPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getMOTMPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchCumMOTMPlayersStatsAndUpdateNotifier(CumMOTMPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getCumMOTMPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchTopGoalsPlayersStatsAndUpdateNotifier(TopGoalsPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getTopGoalsPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  Future<void> _fetchMostAssistsPlayersStatsAndUpdateNotifier(MostAssistsPlayersStatsAndInfoNotifier notifier) async {
    // Fetch the collection of club IDs from Firestore
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    // Process each club ID
    for (String clubId in clubIds) {
      await getMostAssistsPlayersStatsAndInfo(notifier, clubId);
    }

    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }
}