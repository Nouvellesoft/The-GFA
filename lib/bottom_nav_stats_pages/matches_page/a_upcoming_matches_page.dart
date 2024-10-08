import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/a_upcoming_matches_api.dart';
import '../../notifier/a_club_global_notifier.dart';
import '../../notifier/a_upcoming_matches_notifier.dart';
import '../../notifier/c_match_day_banner_for_club_notifier.dart';
import '../../notifier/c_match_day_banner_for_club_opp_notifier.dart';
import 'a_past_matches_page.dart';

Color nabColor = const Color.fromRGBO(56, 56, 60, 1);
Color splashColorTwo = Colors.black87;

class UpcomingMatchesPage extends StatefulWidget {
  final String clubId;
  const UpcomingMatchesPage({super.key, required this.clubId});

  @override
  UpcomingMatchesPageState createState() => UpcomingMatchesPageState();
}

class UpcomingMatchesPageState extends State<UpcomingMatchesPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color;

  late Stream<DocumentSnapshot<Map<String, dynamic>>> firestoreStream;

  String results = 'Results';

  Future<void> _fetchUpcomingMatchesAndUpdateNotifier(
    UpcomingMatchesNotifier upcomingMatchesNotifier,
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier,
    MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier,
    ClubGlobalProvider clubGlobalProvider,
  ) async {
    await getUpcomingMatches(
        upcomingMatchesNotifier, matchDayBannerForClubNotifier, matchDayBannerForClubOppNotifier, clubGlobalProvider, widget.clubId);

    setState(() {}); // Refresh the UI if needed
  }

  @override
  void initState() {
    ClubGlobalProvider clubGlobalProvider = Provider.of<ClubGlobalProvider>(context, listen: false);
    UpcomingMatchesNotifier upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context, listen: false);
    MatchDayBannerForClubNotifier matchDayBannerForClubNotifier = Provider.of<MatchDayBannerForClubNotifier>(context, listen: false);
    MatchDayBannerForClubOppNotifier matchDayBannerForClubOppNotifier = Provider.of<MatchDayBannerForClubOppNotifier>(context, listen: false);

    _fetchUpcomingMatchesAndUpdateNotifier(
      upcomingMatchesNotifier,
      matchDayBannerForClubNotifier,
      matchDayBannerForClubOppNotifier,
      clubGlobalProvider,
    );

    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _color = ColorTween(begin: Colors.black, end: Colors.white).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future navigateTablesAndStatsDetails(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PastMatchesPage(clubId: widget.clubId)));
  }

  @override
  Widget build(BuildContext context) {
    UpcomingMatchesNotifier upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _color,
        builder: (BuildContext _, Widget? __) {
          return Container(
            padding: const EdgeInsets.only(bottom: 5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: _color.value, shape: BoxShape.rectangle),
            child: SafeArea(
              // ((){
              //
              // }()),

              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return AnimCard(
                    const Color.fromRGBO(98, 103, 112, 1.0),
                    '',
                    '',
                    '',
                    index: index,
                  );
                },
                itemCount: upcomingMatchesNotifier.upcomingMatchesList.length,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimCard extends StatefulWidget {
  final Color color;
  final String num;
  final int index;
  final String numEng;
  final String content;

  const AnimCard(this.color, this.num, this.numEng, this.content, {super.key, required this.index});

  @override
  AnimCardState createState() => AnimCardState();
}

class AnimCardState extends State<AnimCard> {
  var padding = 0.0;
  var bottomPadding = 0.0;

  @override
  Widget build(BuildContext context) {
    UpcomingMatchesNotifier upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context);

    String homeTeamIcon = upcomingMatchesNotifier.upcomingMatchesList[widget.index].homeTeamIcon!;
    String awayTeamIcon = upcomingMatchesNotifier.upcomingMatchesList[widget.index].awayTeamIcon!;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPadding(
              padding: EdgeInsets.only(top: padding, bottom: bottomPadding),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.fastLinearToSlowEaseIn,
              child: CardItem(
                widget.color,
                widget.num,
                widget.numEng,
                widget.content,
                () {
                  setState(() {
                    padding = padding == 10 ? 120.0 : 0.0;
                    bottomPadding = bottomPadding == 0 ? 120 : 0.0;
                  });
                },
                index: widget.index,
                // }, index: widget.index,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 10, left: 10, top: 40),
                height: 90,
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30)],
                  color: const Color.fromRGBO(57, 62, 70, 1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15, bottom: 5, top: 5),
                            height: 55,
                            width: 53,
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                            child: Center(
                              child: Container(
                                width: 42.0,
                                height: 42.0,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    image: DecorationImage(
                                        // image: CachedNetworkImageProvider(upcomingMatchesNotifier.upcomingMatchesList[widget.index].homeTeamIcon!),
                                        image: homeTeamIcon.startsWith('assets/')
                                            ? AssetImage(homeTeamIcon) as ImageProvider
                                            : CachedNetworkImageProvider(homeTeamIcon),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            margin: const EdgeInsets.only(left: 7),
                            child: Text(
                              upcomingMatchesNotifier.upcomingMatchesList[widget.index].homeTeam!,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.allertaStencil(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w300),
                              textAlign: TextAlign.start,
                            ),
                          )
                        ],
                      ),
                    ),
                    Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(DateFormat('dd-MM-yyyy HH:mm:ss').format(upcomingMatchesNotifier.upcomingMatchesList[widget.index].matchDate!),
                            style: GoogleFonts.electrolize(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: Colors.white54,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                upcomingMatchesNotifier.upcomingMatchesList[widget.index].matchDayKickOff!,
                                style: GoogleFonts.jura(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 15, bottom: 5, top: 5),
                            height: 55,
                            width: 53,
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                            child: Center(
                              child: Container(
                                width: 42.0,
                                height: 42.0,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    image: DecorationImage(
                                        // image: CachedNetworkImageProvider(upcomingMatchesNotifier.upcomingMatchesList[widget.index].awayTeamIcon!),
                                        image: awayTeamIcon.startsWith('assets/')
                                            ? AssetImage(awayTeamIcon) as ImageProvider
                                            : CachedNetworkImageProvider(awayTeamIcon),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              upcomingMatchesNotifier.upcomingMatchesList[widget.index].awayTeam!,
                              style: GoogleFonts.allertaStencil(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class CardItem extends StatefulWidget {
  final Color color;
  final String num;
  final String numEng;
  final String content;
  final int index;
  final dynamic onTap;

  const CardItem(this.color, this.num, this.numEng, this.content, this.onTap, {super.key, required this.index});

  @override
  CardItemState createState() => CardItemState();
}

class CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    UpcomingMatchesNotifier upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context);

    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 90,
        width: width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: const Color(0xff667b80).withOpacity(0.2), blurRadius: 25),
          ],
          color: widget.color.withOpacity(1.0),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tap to view more',
                style: GoogleFonts.ptMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black.withAlpha(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          'Venue: ${upcomingMatchesNotifier.upcomingMatchesList[widget.index].venue!}',
                          style: GoogleFonts.saira(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black.withAlpha(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          'Competition: ${upcomingMatchesNotifier.upcomingMatchesList[widget.index].competition!}',
                          style: GoogleFonts.saira(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
