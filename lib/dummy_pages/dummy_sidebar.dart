import 'dart:async';

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

import '../bloc_navigation_bloc/navigation_bloc.dart';
import '../notifier/sidebar_notifier.dart';
import '../sidebar/menu_item.dart';

String clubName = "Coventry Phoenix FC";
String subtitle = "We breed elite players here";

String returningPlayersTitle = "Coventry Phoenix I";
String newPlayersTitle = "Coventry Phoenix II";
// String thirdTeamClassTitle = "Reserve Team Players";
String captainsTitle = "CPFC Captains";
String coachesTitle = "Coaching Staff";
String managementBodyTitle = "Management Body";
String sponsorsTitle = "Club Sponsors";
// String adminTitle = "Club Admin";

String aiStatsTitle = "Ask ChatGFA";

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

  _onSelected(int index) {
    if (index == 7 /**|| index == 8 */) {
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

  // Stream<DocumentSnapshot<Map<String, dynamic>>> getDataFromFirestore() {
  //   // return FirebaseFirestore.instance.collection('SliversPages').doc('non_slivers_pages').snapshots();
  //   return FirebaseFirestore.instance
  //       .collection('clubs')
  //       .doc(widget.clubId)
  //       // .doc('anafc')
  //       .collection('SliversPages')
  //       .doc('slivers_pages')
  //       .snapshots()
  //       .distinct(); // Ensure distinct events
  // }

  @override
  void initState() {
    super.initState();

    // getDataFromFirestore();

    firestoreStream = FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .collection('SliversPages')
        .doc('slivers_pages')
        .snapshots()
        .distinct(); // Ensure distinct events

    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                                      // stream: getDataFromFirestore(),
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
                                                  // snapshot.data?.data()!['sidebar_page'],
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
                                                      subtitle,
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
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: Container(
                                          width: 140.0,
                                          height: 140.0,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/cpfc_logo.jpeg'))),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: dividerColor.withOpacity(0.3),
                                indent: 32,
                                endIndent: 32,
                              ),
                              Material(
                                color: _currentNAVSelected == 0 ? gradientColorTwo.withOpacity(0.3) : materialBackgroundColor,
                                child: InkWell(
                                  splashColor: splashColorThree,
                                  onTap: () {
                                    _onSelected(0);
                                    onIconPressed();
                                    BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.myFirstTeamClassPageClickedEvent);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: MenuItems(
                                      icon: MdiIcons.soccer,
                                      title: returningPlayersTitle,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: _currentNAVSelected == 1 ? gradientColorTwo.withOpacity(0.3) : materialBackgroundColor,
                                child: InkWell(
                                  splashColor: splashColorThree,
                                  onTap: () {
                                    _onSelected(1);
                                    onIconPressed();
                                    BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.mySecondTeamClassPageClickedEvent);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: MenuItems(
                                      icon: MdiIcons.soccer,
                                      title: newPlayersTitle,
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