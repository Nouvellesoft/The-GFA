import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import './a_upcoming_matches_page.dart';
import 'a_past_matches_all_clubs_page.dart';
import 'a_past_matches_page.dart';
import 'a_upcoming_matches_all_clubs_page.dart';

String resultsTitle = 'Club Results';
String fixturesTitle = 'Club Fixtures';
String allClubsResultsTitle = 'All Results';
String allClubsFixturesTitle = 'All Fixtures';

String footballMatchesSubjectTitle = 'Football Matches';

Color? backgroundColor = const Color.fromRGBO(34, 40, 49, 1);
Color? selectedTabColor = Colors.indigo[200];

class TabviewMatchesPage extends StatefulWidget {
  final String clubId;
  const TabviewMatchesPage({super.key, required this.initialPage, required this.clubId});

  final int initialPage;

  @override
  State<TabviewMatchesPage> createState() => TabviewMatchesPageState();
}

class TabviewMatchesPageState extends State<TabviewMatchesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialPage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(footballMatchesSubjectTitle, style: GoogleFonts.jura(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: appBarIconColor),
          onPressed: () {
            navigateMyApp(context);
          },
        ),
        bottom: TabBar(
          labelColor: selectedTabColor,
          unselectedLabelColor: Colors.orange,
          indicatorColor: Colors.white,
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 14), // Set the size for selected tab
          unselectedLabelStyle: const TextStyle(fontSize: 11), // Set the size for unselected tabs
          tabs: [
            Tab(text: allClubsFixturesTitle),
            Tab(text: allClubsResultsTitle),
            Tab(text: fixturesTitle),
            Tab(text: resultsTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UpcomingMatchesForAllClubsPage(clubId: widget.clubId),
          PastMatchesForAllClubsPage(clubId: widget.clubId),
          UpcomingMatchesPage(clubId: widget.clubId),
          PastMatchesPage(clubId: widget.clubId),
        ],
      ),
    );
  }
}

Future navigateMyApp(context) async {
  Navigator.of(context).pop(false);
}
