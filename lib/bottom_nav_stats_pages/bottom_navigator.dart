import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../api/coaches_reviews_comment_api.dart';
import '../api/cum_motm_players_stats_info_api.dart';
import '../api/founders_reviews_comment_api.dart';
import '../api/most_assists_players_stats_info_api.dart';
import '../api/most_fouled_rc_players_stats_info_api.dart';
import '../api/most_fouled_yc_players_stats_info_api.dart';
import '../api/motm_players_stats_info_api.dart';
import '../api/player_of_the_month_stats_info_api.dart';
import '../api/top_defensive_players_stats_info_api.dart';
import '../api/top_gk_players_stats_info_api.dart';
import '../api/top_goals_players_stats_info_api.dart';
import '../api/trainings_games_reels_api.dart';
import '../notifier/coaches_reviews_comment_notifier.dart';
import '../notifier/cum_motm_players_stats_info_notifier.dart';
import '../notifier/founders_reviews_comment_notifier.dart';
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

Color? backgroundColor = const Color.fromRGBO(34, 40, 49, 1);
Color? cardBackgroundColorTwo = const Color.fromRGBO(34, 40, 49, 0.6);
Color? cardBackgroundColor = const Color.fromRGBO(57, 62, 70, 1);
Color? goalsScoredTextColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarIconColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarBackgroundColor = const Color.fromRGBO(34, 40, 49, 1);

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key, required this.mainPage, required this.initialPage, required this.clubId});

  final Widget mainPage;
  final int initialPage;
  final String clubId;

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  bool toggle = false;
  int selectedPage = 0;

  late List<Widget> _pageOption;

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
    super.initState();

    _pageOption = [
      PlayersTablePage(
        clubId: widget.clubId,
      ),
      PlayersStatsAndInfoPage(clubId: widget.clubId),
      TabviewMatchesPage(initialPage: 1, clubId: widget.clubId),
      // const SeasonTimeline(),
      TabviewSocialMediaPage(clubId: widget.clubId),
      TrainingsAndGamesReelsPage(clubId: widget.clubId),
    ];

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

    CumMOTMPlayersStatsAndInfoNotifier cumMOTMPlayersStatsAndInfoNotifier = Provider.of<CumMOTMPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchCumMOTMPlayersStatsAndUpdateNotifier(cumMOTMPlayersStatsAndInfoNotifier);

    TopGoalsPlayersStatsAndInfoNotifier topGoalsPlayersStatsAndInfoNotifier =
        Provider.of<TopGoalsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchTopGoalsPlayersStatsAndUpdateNotifier(topGoalsPlayersStatsAndInfoNotifier);

    MostAssistsPlayersStatsAndInfoNotifier mostAssistsPlayersStatsAndInfoNotifier =
        Provider.of<MostAssistsPlayersStatsAndInfoNotifier>(context, listen: false);
    _fetchMostAssistsPlayersStatsAndUpdateNotifier(mostAssistsPlayersStatsAndInfoNotifier);

    CoachesReviewsCommentNotifier coachesReviewsCommentNotifier = Provider.of<CoachesReviewsCommentNotifier>(context, listen: false);
    _fetchCoachesReviewsCommentAndUpdateNotifier(coachesReviewsCommentNotifier);

    FoundersReviewsCommentNotifier foundersReviewsCommentNotifier = Provider.of<FoundersReviewsCommentNotifier>(context, listen: false);
    _fetchFoundersReviewsCommentAndUpdateNotifier(foundersReviewsCommentNotifier);

    setState(() {
      selectedPage = widget.initialPage;
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchTrainingsAndGamesReelsAndUpdateNotifier(TrainingsAndGamesReelsNotifier notifier) async {
    await getTrainingsAndGamesReels(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchPlayerOfTheMonthStatsAndUpdateNotifier(PlayerOfTheMonthStatsAndInfoNotifier notifier) async {
    await getPlayerOfTheMonthStatsAndInfo(notifier, widget.clubId);
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

  Future<void> _fetchTopGoalsPlayersStatsAndUpdateNotifier(TopGoalsPlayersStatsAndInfoNotifier notifier) async {
    await getTopGoalsPlayersStatsAndInfo(notifier, widget.clubId);
    setState(() {});
  }

  Future<void> _fetchMostAssistsPlayersStatsAndUpdateNotifier(MostAssistsPlayersStatsAndInfoNotifier notifier) async {
    await getMostAssistsPlayersStatsAndInfo(notifier, widget.clubId);
    setState(() {});
  }

  Future<void> _fetchCoachesReviewsCommentAndUpdateNotifier(CoachesReviewsCommentNotifier notifier) async {
    await getCoachesReviewsComment(notifier, widget.clubId);

    setState(() {});
  }

  Future<void> _fetchFoundersReviewsCommentAndUpdateNotifier(FoundersReviewsCommentNotifier notifier) async {
    await getFoundersReviewsComment(notifier, widget.clubId);

    setState(() {});
  }
}
