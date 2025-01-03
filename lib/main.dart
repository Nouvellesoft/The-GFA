import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:the_gfa/notifier/a_past_matches_all_clubs_notifier.dart';
import 'package:the_gfa/notifier/b_ftc_okaybutton_pressed_notifier.dart';
import 'package:the_gfa/notifier/b_training_days_notifier.dart';
import 'package:the_gfa/notifier/b_trial_dates_notifier.dart';
import 'package:the_gfa/notifier/fifth_team_class_notifier.dart';
import 'package:the_gfa/notifier/fourth_team_class_notifier.dart';
import 'package:the_gfa/notifier/sixth_team_class_notifier.dart';

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
import 'api/club_sponsors_api.dart';
import 'api/d_birthday_push_notification_service.dart';
import 'api/d_push_notification_service.dart';
import 'home_page/club_lists.dart';
import 'notifier/a_club_global_notifier.dart';
import 'notifier/a_past_matches_notifier.dart';
import 'notifier/a_upcoming_matches_all_clubs_notifier.dart';
import 'notifier/a_upcoming_matches_notifier.dart';
import 'notifier/achievement_images_notifier.dart';
import 'notifier/b_app_theme_notifier.dart';
import 'notifier/b_sidebar_notifier.dart';
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
import 'notifier/third_team_class_notifier.dart';
import 'notifier/top_defensive_players_stats_info_notifier.dart';
import 'notifier/top_gk_players_stats_info_notifier.dart';
import 'notifier/top_goals_players_stats_info_notifier.dart';
import 'notifier/trainings_games_reels_notifier.dart';

Color? backgroundColor = Colors.indigo[400];
Color? appBarIconColor = Colors.indigo[200];
Color? appBarBackgroundColor = Colors.indigo[400];
Color? secondStudentChartColor = Colors.indigo[400];

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationService().setupInteractedMessage();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Access the keys after dotenv is loaded
  String? publishableStripeKey = dotenv.env['PUBLISHABLE_STRIPE_KEY'];
  String? secretStripeKey = dotenv.env['SECRET_STRIPE_KEY'];

  if (publishableStripeKey == null || secretStripeKey == null) {
    throw Exception("Missing PUBLISHABLE_STRIPE_KEY or SECRET_STRIPE_KEY in .env file");
  }

  // Configure Stripe
  Stripe.publishableKey = publishableStripeKey;
  await Stripe.instance.applySettings();

  // Request notification permissions
  if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Check if it's a physical device, not a simulator
    if (!kDebugMode || (Platform.isIOS && !Platform.environment.containsKey('SIMULATOR_IDENTIFIER'))) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permissions');
        }
      } else {
        if (kDebugMode) {
          print('User declined notification permissions');
        }
      }
    } else {
      if (kDebugMode) {
        print('Running on iOS simulator - skipping notification permissions');
      }
    }
  } else {
    if (kDebugMode) {
      print('Running on non-iOS platform, no explicit notification permission needed');
    }
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('A new onMessageOpenedApp event was published');
    }

    // Use the global navigation key to get the current context
    BirthdayNotificationService.handleBirthdayNotification(navigatorKey.currentContext!, message);
  });

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("6b1cda87-62bf-44d0-9243-9088805b7909");

  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   // print("Accepted permission: $accepted");
  // });

  OneSignal.Notifications.requestPermission(true);

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
        create: (context) => FourthTeamClassNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => FifthTeamClassNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => SixthTeamClassNotifier(),
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
        create: (context) => PastMatchesForAllClubsNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => UpcomingMatchesNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => UpcomingMatchesForAllClubsNotifier(),
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
      ChangeNotifierProvider(
        create: (context) => TrainingDaysNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => TrialDatesNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => ClubGlobalProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => FTClassOkayDialogButtonPressedNotifier(),
      ),
      ChangeNotifierProvider(
        create: (context) => AppThemeProvider(),
      ),
    ], child: ShowCaseWidget(builder: (context) => const MyApp())));

    // Handle initial message
    // FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
    //   if (initialMessage != null) {
    //     // Handle the initial message
    //   }
    // });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // App received a notification when it was killed
    }
  }, FirebaseCrashlytics.instance.recordError);
}

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
    // return PandCTransitions();
  }
}

class MyAppState extends State<MyApp> {
  bool _isDataLoaded = false;

  static Map<int, Color> color = {
    50: const Color.fromRGBO(136, 14, 79, .1),
    100: const Color.fromRGBO(136, 14, 79, .2),
    200: const Color.fromRGBO(136, 14, 79, .3),
    300: const Color.fromRGBO(136, 14, 79, .4),
    400: const Color.fromRGBO(136, 14, 79, .5),
    500: const Color.fromRGBO(136, 14, 79, .6),
    600: const Color.fromRGBO(136, 14, 79, .7),
    700: const Color.fromRGBO(136, 14, 79, .8),
    800: const Color.fromRGBO(136, 14, 79, .9),
    900: const Color.fromRGBO(136, 14, 79, 1),
  };
  MaterialColor primeColor = MaterialColor(0xFF337C36, color);
  MaterialColor accentColor = MaterialColor(0xFF337C36, color);

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp().whenComplete(() {
      if (kDebugMode) {
        print("completed");
      }
      setState(() {});
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      ClubSponsorsNotifier clubSponsorsNotifier = Provider.of<ClubSponsorsNotifier>(context, listen: false);
      _fetchClubSponsorsAndUpdateNotifier(clubSponsorsNotifier).then((_) {
        setState(() {
          _isDataLoaded = true; // Data loading completed
        });
      });
    }
  }

  Future<void> _fetchClubSponsorsAndUpdateNotifier(ClubSponsorsNotifier notifier) async {
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance.collection('clubs').get();
    List<String> clubIds = clubSnapshot.docs.map((doc) => doc.id).toList();

    for (String clubId in clubIds) {
      await getClubSponsors(notifier, clubId);
    }
    // Optionally, notify listeners or update UI after fetching
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Live', // 'Not Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      // theme: MyAppThemes.lightTheme,
      // darkTheme: MyAppThemes.darkTheme,
      // themeMode: ThemeMode.system, // Default mode
      home: const ClubSelectionPage(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      // initialRoute: '/',
      // routes: {
      //   '/MyChatGFAPage': (context) => MyChatGFAPage(clubId: ModalRoute.of(context)!.settings.arguments as String),
      // },
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Football Clubs App',
//       theme: ThemeData(
//         primarySwatch: Colors.deepOrange,
//       ),
//       home: const HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Football Clubs App')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Fluttertoast.showToast(
//               msg: 'Welcome, Admin',
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.BOTTOM,
//               backgroundColor: Colors.blueAccent,
//               textColor: Colors.white,
//               fontSize: 16.0,
//             );
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const ClubSelectionPage()),
//             );
//           },
//           child: const Text('Select a Club'),
//         ),
//       ),
//     );
//   }
// }
