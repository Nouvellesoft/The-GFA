import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../api/first_team_class_api.dart';
import '../bloc_navigation_bloc/navigation_bloc.dart';
import '../details_pages/first_team_details_page.dart';
import '../notifier/first_team_class_notifier.dart';

String clubName = "Coventry Phoenix FC";
// String postcode = "CV1 3WQ";
String city = "Coventry";
String stateName = "West Midlands";
String countryName = "The UK";
String thrownName = "All Players List - A";

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
  const MyFirstTeamClassPage({Key? key, this.title, required this.clubId}) : super(key: key);

  final String? title;

  @override
  State<MyFirstTeamClassPage> createState() => _MyFirstTeamClassPage();
}

class _MyFirstTeamClassPage extends State<MyFirstTeamClassPage> {
  final TextEditingController bugController = TextEditingController();

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

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
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
                      stream: FirebaseFirestore.instance
                          .collection('clubs')
                          .doc(widget.clubId)
                          .collection('SliversPages')
                          .doc('slivers_pages')
                          .snapshots(),
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

  Future navigateToSubPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubPage()));
  }

  @override
  void initState() {
    super.initState();

    _fetchFirstTeamClassAndUpdateNotifier(firstTeamClassNotifier);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchFirstTeamClassAndUpdateNotifier(FirstTeamClassNotifier firstTeamNotifier) async {
    await getFirstTeamClass(firstTeamNotifier, widget.clubId);
    setState(() {}); // Refresh the UI after fetching the data
  }
}
