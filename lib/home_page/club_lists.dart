import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gfa/sidebar/sidebar_layout.dart';

import '../api/all_clubs_api.dart';
import '../home_page/home_page_deux.dart';

class ClubSelectionPage extends StatefulWidget {
  const ClubSelectionPage({super.key});

  @override
  State<ClubSelectionPage> createState() => ClubSelectionPageState();
}

class ClubSelectionPageState extends State<ClubSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _allClubs = [];
  List<String> _filteredClubs = [];
  Map<String, String> _clubNames = {}; // Mapping of clubId to club_name
  Map<String, String> _clubLogos = {}; // Mapping of clubId to club_logo

  @override
  void initState() {
    super.initState();
    _checkSelectedClub();
    _loadClubs();
    Firebase.initializeApp().whenComplete(() {
      if (kDebugMode) {
        print("Firebase initialized");
      }
      setState(() {});
    });
  }

  Future<void> _loadClubs() async {
    try {
      // Fetch all club IDs
      List<String> clubIds = await getClubs();
      Map<String, String> fetchedClubNames = {};
      Map<String, String> fetchedClubLogos = {};

      for (String clubId in clubIds) {
        // Fetch the club_name and club_logo for each clubId from Firestore
        var clubData = await _fetchClubData(clubId);
        if (clubData != null) {
          fetchedClubNames[clubId] = clubData['club_name'] ?? "Unknown Club";
          fetchedClubLogos[clubId] = clubData['club_logo'] ?? ""; // Default to empty if no logo
        } else {
          fetchedClubNames[clubId] = "Unknown Club"; // Fallback if club_name is missing
          fetchedClubLogos[clubId] = ""; // Fallback if club_logo is missing
        }
      }

      // Update state with fetched data
      setState(() {
        _allClubs = clubIds;
        _filteredClubs = clubIds;
        _clubNames = fetchedClubNames;
        _clubLogos = fetchedClubLogos;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading clubs: $e");
      }
    }
  }

  Future<Map<String, String>?> _fetchClubData(String clubId) async {
    try {
      var doc = await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('AboutClub').doc('about_club_page').get();

      return {
        'club_name': doc.data()?['club_name'] as String? ?? "Unknown Club",
        'club_logo': doc.data()?['club_logo'] as String? ?? "",
      };
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching club data for $clubId: $e");
      }
      return null;
    }
  }

  void _filterClubs(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredClubs = _clubNames.entries
          .where((entry) => entry.value.toLowerCase().contains(_searchQuery))
          .map((entry) => entry.key) // Extract clubId of matching entries
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _checkSelectedClub() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clubId = prefs.getString('selectedClub');

    if (clubId != null) {
      if (clubId == 'coventryphoenixfc') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PandCTransitions(clubId: clubId)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SideBarLayout(clubId: clubId)),
        );
      }
    }
  }

  Future<void> saveSelectedClub(String clubId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          if (kDebugMode) {
            print('User declined notification permissions');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error requesting notification permissions: $e');
        }
      }
    }

    String? previousClub = prefs.getString('selectedClub');

    try {
      if (!(defaultTargetPlatform == TargetPlatform.iOS && kDebugMode)) {
        if (previousClub != null && previousClub != clubId) {
          await FirebaseMessaging.instance.unsubscribeFromTopic(previousClub);
          if (kDebugMode) {
            print("Unsubscribed from $previousClub");
          }
        }
      }

      await FirebaseMessaging.instance.subscribeToTopic(clubId);
      if (kDebugMode) {
        print("Subscribed to $clubId");
      }

      await prefs.setString('selectedClub', clubId);
    } catch (e) {
      if (kDebugMode) {
        print("Error in saveSelectedClub: $e");
      }
      await prefs.setString('selectedClub', clubId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // Colors.black54.withOpacity(0.3),
                  // Colors.black54.withOpacity(0.3),
                  const Color.fromRGBO(29, 31, 31, 0.34),
                  const Color.fromRGBO(29, 31, 31, 0.34),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Select Your Club',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.82,
                        borderRadius: 10,
                        blur: 20,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.5),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Search Box with Clay Container
                              ClayContainer(
                                emboss: true,
                                spread: 300,
                                curveType: CurveType.concave,
                                depth: 15,
                                color: const Color.fromRGBO(29, 31, 31, 0.34),
                                borderRadius: 10,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _searchController,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search clubs...',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    onChanged: _filterClubs,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              Expanded(
                                child: ClayContainer(
                                  // emboss: true,
                                  spread: 300,
                                  curveType: CurveType.concave,
                                  depth: 20,
                                  color: const Color.fromRGBO(29, 31, 31, 0.34),
                                  borderRadius: 10,
                                  child: _allClubs.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(12),
                                          itemCount: _filteredClubs.length,
                                          itemBuilder: (context, index) {
                                            var clubId = _filteredClubs[index];
                                            var clubName = _clubNames[clubId] ?? clubId;
                                            String clubLogo = _clubLogos[clubId] ?? "";
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                              child: GlassmorphicContainer(
                                                width: double.infinity,
                                                height: 80,
                                                borderRadius: 15,
                                                blur: 10,
                                                alignment: Alignment.center,
                                                border: 1,
                                                linearGradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.1),
                                                    Colors.white.withOpacity(0.05),
                                                  ],
                                                ),
                                                borderGradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.white.withOpacity(0.1),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: ListTile(
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                    leading: clubLogo.isNotEmpty
                                                        ? Image.network(clubLogo, width: 40, height: 40)
                                                        : Icon(Icons.sports_soccer),
                                                    title: Text(
                                                      clubName.toLowerCase(),
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    trailing: const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    onTap: () async {
                                                      await saveSelectedClub(clubId);

                                                      Fluttertoast.showToast(
                                                        msg: "Welcome to $clubName!",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        backgroundColor: Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0,
                                                      );

                                                      if (clubId == 'coventryphoenixfc') {
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => PandCTransitions(clubId: clubId),
                                                          ),
                                                        );
                                                      } else {
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => SideBarLayout(clubId: clubId),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
