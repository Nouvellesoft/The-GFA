import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_gfa/sidebar/sidebar_layout.dart';
import 'package:the_gfa/thrown_pages/club_lists.dart';

import '/notifier/a_upcoming_matches_notifier.dart';
import '/notifier/all_club_members_notifier.dart';
import '/notifier/all_fc_teams_notifier.dart';
import '/notifier/b_youtube_notifier.dart';
import '/notifier/c_match_day_banner_for_club_notifier.dart';
import '/notifier/c_match_day_banner_for_club_opp_notifier.dart';
import '/notifier/c_match_day_banner_for_league_notifier.dart';
import '/notifier/c_match_day_banner_for_location_notifier.dart';
import '/notifier/club_sponsors_notifier.dart';
import '/notifier/players_notifier.dart';
import '/notifier/players_table_notifier.dart';
import 'api/PushNotificationService.dart';
import 'club_admin/club_admin_page.dart';
import 'notifier/a_past_matches_notifier.dart';
import 'notifier/achievement_images_notifier.dart';
import 'notifier/club_arial_notifier.dart';
import 'notifier/club_captains_notifier.dart';
import 'notifier/coaches_reviews_comment_notifier.dart';
import 'notifier/coaching_staff_notifier.dart';
import 'notifier/cum_motm_players_stats_info_notifier.dart';
import 'notifier/first_team_class_notifier.dart';
import 'notifier/founders_reviews_comment_notifier.dart';
import 'notifier/management_body_notifier.dart';
import 'notifier/most_assists_players_stats_info_notifier.dart';
import 'notifier/most_fouled_rc_players_stats_info_notifier.dart';
import 'notifier/most_fouled_yc_players_stats_info_notifier.dart';
import 'notifier/motm_players_stats_info_notifier.dart';
import 'notifier/player_of_the_month_stats_info_notifier.dart';
import 'notifier/second_team_class_notifier.dart';
import 'notifier/sidebar_notifier.dart';
import 'notifier/third_team_class_notifier.dart';
import 'notifier/top_defensive_players_stats_info_notifier.dart';
import 'notifier/top_gk_players_stats_info_notifier.dart';
import 'notifier/top_goals_players_stats_info_notifier.dart';
import 'notifier/trainings_games_reels_notifier.dart';

Color? backgroundColor = Colors.indigo[400];
Color? appBarIconColor = Colors.indigo[200];
Color? appBarBackgroundColor = Colors.indigo[400];
Color? secondStudentChartColor = Colors.indigo[400];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService().setupInteractedMessage();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runZonedGuarded(() async {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => FirstTeamClassNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => SecondTeamClassNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => ThirdTeamClassNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => CaptainsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => CoachesNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => ManagementBodyNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => ClubArialNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => AchievementsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => SideBarNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MostAssistsPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MostFouledYCPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MostFouledRCPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => TopGoalsPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => TopGKPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => TopDefensivePlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MOTMPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => CumMOTMPlayersStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => TrainingsAndGamesReelsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => PlayerOfTheMonthStatsAndInfoNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => CoachesReviewsCommentNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => FoundersReviewsCommentNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => PastMatchesNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => UpcomingMatchesNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => YouTubeNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => ClubSponsorsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => PlayersNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => AllClubMembersNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => AllFCTeamsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MatchDayBannerForClubNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MatchDayBannerForClubOppNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MatchDayBannerForLeagueNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => MatchDayBannerForLocationNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => PlayersTableNotifier(),
      ),
    ], child: const MyApp()));

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // App received a notification when it was killed
    }
  }, FirebaseCrashlytics.instance.recordError);

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("6b1cda87-62bf-44d0-9243-9088805b7909");
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   // print("Accepted permission: $accepted");
  // });
  OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football Clubs App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Football Clubs App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Fluttertoast.showToast(
              msg: 'Welcome, Admin',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClubSelectionPage()),
            );
          },
          child: const Text('Select a Club'),
        ),
      ),
    );
  }
}

class PandCTransitions extends StatelessWidget {
  const PandCTransitions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildBackgroundImage(),
            _buildTranslucentOverlay(context),
            _buildButtonContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cpfc_logo_android_ios.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTranslucentOverlay(context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.55,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          color: Colors.white.withOpacity(0.35),
        ),
      ),
    );
  }

  Widget _buildButtonContainer(context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.55,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const SizedBox(height: 60),
          const Text(
            'Welcome to\n Coventry Phoenix FC App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.2),
          const Text(
            'Please, choose your path',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.1),
          ElevatedButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: 'Welcome to CPFC App!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                fontSize: 16.0,
              );
              Navigator.push(
                context,
                SlideTransition1(const SideBarLayout()),
              );
              // You can navigate here if needed
            },
            child: const Text(
              'CPFC Access',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAdminDialog(context),
            child: const Text(
              'Admin Access',
              style: TextStyle(
                color: Colors.teal,
              ),
            ),
          ),
        ],
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
          'Awesome, Enter the passcode',
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
              controller: passcodeController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Passcode',
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredPasscode = passcodeController.text.trim();

                // Retrieve the stored passcode from Firestore
                DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
                    .collection('SliversPages') // Replace with your Firestore collection
                    .doc('non_slivers_pages') // Replace with your Firestore document
                    .get();

                String storedPasscode = snapshot.data()!['admin_passcode'] ?? '';

                // Check if the entered passcode matches the stored passcode
                if (enteredPasscode == storedPasscode) {
                  Navigator.pop(context);
                  _showAdminWelcomeToast();
                  Navigator.push(context, SlideTransition1(MyClubAdminPage()));
                } else {
                  // Show a toast for incorrect passcode
                  Fluttertoast.showToast(
                    msg: 'Incorrect passcode',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminWelcomeToast() {
    Fluttertoast.showToast(
      msg: 'Welcome, Admin',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

class SlideTransition1 extends PageRouteBuilder {
  final Widget page;

  SlideTransition1(this.page)
      : super(
            pageBuilder: (context, animation, anotherAnimation) => page,
            transitionDuration: const Duration(milliseconds: 1000),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(curve: Curves.fastLinearToSlowEaseIn, parent: animation, reverseCurve: Curves.fastOutSlowIn);
              return SlideTransition(
                position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(animation),
                child: page,
              );
            });
}

class SlideTransition2 extends PageRouteBuilder {
  final Widget page;

  SlideTransition2(this.page)
      : super(
            pageBuilder: (context, animation, anotherAnimation) => page,
            transitionDuration: const Duration(milliseconds: 1000),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(curve: Curves.fastLinearToSlowEaseIn, parent: animation, reverseCurve: Curves.fastOutSlowIn);
              return SlideTransition(
                position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(animation),
                textDirection: TextDirection.rtl,
                child: page,
              );
            });
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // brightness: Brightness.dark,
        centerTitle: true,
        title: const Text('Slide Transition'),
      ),
    );
  }
}
