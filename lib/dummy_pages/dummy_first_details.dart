import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../notifier/first_team_class_notifier.dart';

String clubName = "Coventry Phoenix FC";

String callFIRST = "tel:+44";
String smsFIRST = "sms:+44";
String whatsAppFIRST = "https://api.whatsapp.com/send?phone=+44";
String whatsAppSECOND = "&text=Hello%20";
String whatsAppTHIRD = ",%20How%20are%20you%20doing%20today?";
String mailFIRST = "mailto:";
String mailSECOND = "?subject=Hello ";
String urlTwitter = "https://twitter.com/";
String urlFacebook = "https://facebook.com/";
String urlLinkedIn = "https://linkedin.com/";
String urlInstagram = "https://www.instagram.com/";
String urlSnapchat = "https://www.snapchat.com/add/";
String urlTikTok = "https://www.tiktok.com/@";

String reachDetails = "Contacts";
String autoBioDetails = "  AutoBiography";

String callButton = "Call me";
String messageButton = "Send me a Message";
String whatsAppButton = "Send me a WhatsApp Message";
String emailButton = "Send me an Email";
String twitterButton = "My Twitter";
String instagramButton = "My Instagram";
String facebookButton = "My Facebook";
String linkedInButton = "My LinkedIn";
String snapchatButton = "My Snapchat";
String tikTokButton = "My TikTok";

String autobiographyTitle = "My Autobiography\n";
String nicknameTitle = "My Nickname\n";
String bestMomentTitle = "My best moment so far in $clubName\n";
String worstMomentTitle = "My worst moment so far in $clubName\n";
String dreamFCTitle = "My Dream Football Club\n";
String positionPlayingTitle = "My Play Position\n";
String dobTitle = "My Birthday\n";
// String prefectPositionTitle = "Position held as a Prefect\n";
String regionOfOriginTitle = "My Region of Origin\n";
String countryTitle = "My Nationality\n";
String otherPositionsOfPlayTitle = "Other Positions I Can Play\n";
String favFootballLegendTitle = "My All Time Favourite Football Legend\n";
String yearOfInceptionTitle = "Inception with $clubName\n";
String leftOrRightFootedTitle = "Left or Right Footed\n";
String adidasOrNikeTitle = "Adidas or Nike\n";
String ronaldoOrMessiTitle = "Ronaldo or Messi\n";
String hobbiesTitle = "My Hobbies\n";
String philosophyTitle = "My Philosophy about Life\n";
String droplineTitle = "My Dropline to my fellow $clubName footballers\n";

String facebookProfileSharedPreferencesTitle = "Manual Website Search";
String facebookProfileSharedPreferencesContentOne = "Apparently, you'd need to search manually for ";
String facebookProfileSharedPreferencesContentTwo = ", on Facebook.com";
String facebookProfileSharedPreferencesButton = "Go to Facebook";
String facebookProfileSharedPreferencesButtonTwo = "Lol, No";

String linkedInProfileSharedPreferencesTitle = "Manual Website Search";
String linkedInProfileSharedPreferencesContentOne = "Apparently, you'd need to search manually for ";
String linkedInProfileSharedPreferencesContentTwo = ", on LinkedIn.com";
String linkedInProfileSharedPreferencesButton = "Go to LinkedIn";
String linkedInProfileSharedPreferencesButtonTwo = "Lol, No";

Color backgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color appBarTextColor = Colors.white;
Color appBarBackgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color appBarIconColor = Colors.white;
Color materialBackgroundColor = Colors.transparent;
Color shapeDecorationColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color shapeDecorationColorTwo = Colors.white;
Color shapeDecorationColorThree = const Color.fromRGBO(33, 37, 41, 1.0);
Color shapeDecorationTextColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color shapeDecorationIconColor = const Color.fromRGBO(255, 107, 53, 1.0);
Color cardBackgroundColor = Colors.white;
Color splashColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color splashColorTwo = Colors.white;
Color splashColorThree = const Color.fromRGBO(33, 37, 41, 1.0);
Color iconTextColor = Colors.white;
Color iconTextColorTwo = const Color.fromRGBO(33, 37, 41, 1.0);
Color buttonColor = const Color.fromRGBO(33, 37, 41, 1.0);
Color textColor = const Color.fromRGBO(33, 37, 41, 1.0);

Color confettiColorOne = Colors.green;
Color confettiColorTwo = Colors.blue;
Color confettiColorThree = Colors.pink;
Color confettiColorFour = Colors.orange;
Color confettiColorFive = Colors.purple;
Color confettiColorSix = Colors.brown;
Color confettiColorSeven = Colors.white;
Color confettiColorEight = Colors.blueGrey;
Color confettiColorNine = Colors.redAccent;
Color confettiColorTen = Colors.teal;
Color confettiColorEleven = Colors.indigoAccent;
Color confettiColorTwelve = Colors.cyan;

late FirstTeamClassNotifier firstTeamClassNotifier;

Map<int, Widget>? userBIO;

var crossFadeView = CrossFadeState.showFirst;

dynamic _autoBio;
dynamic _bestMoment;
dynamic _dob;
dynamic _dreamFC;
dynamic _positionPlaying;
dynamic _email;
dynamic _facebook;
dynamic _linkedIn;
dynamic _hobbies;
dynamic _instagram;
dynamic _name;
dynamic _nickname;
dynamic _philosophy;
dynamic _phone;
dynamic _captain;
dynamic _myDropline;
dynamic _prefectPosition;
dynamic _country;
dynamic _regionFrom;
dynamic _snapchat;
dynamic _tikTok;
dynamic _otherPositionsOfPlay;
dynamic _favFootballLegend;
dynamic _yearOfInception;
dynamic _leftOrRightFooted;
dynamic _adidasOrNike;
dynamic _ronaldoOrMessi;
dynamic _twitter;
dynamic _worstMoment;

class SubPage extends StatefulWidget {
  const SubPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  // final _formKey = GlobalKey<FormState>();
  String otpCode = "";
  bool isLoaded = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String _receivedId = ""; // Add this line
  bool isOTPComplete = false;
  bool isOtpVerified = false; // Add this variable
  // Declare a boolean variable to track OTP generation
  bool isOtpGenerated = false;

  bool isModifyingAutobiography = true; // Assuming modifying autobiography by default

  ConfettiController? _confettiController;

  bool _isVisible = true;

  void showToast() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  // Firebase Firestore instance
  final firestore = FirebaseFirestore.instance;

  // Implement a function to handle form submission

  @override
  Widget build(BuildContext context) {
    firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: true);

    return ConfettiWidget(
      confettiController: _confettiController!,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: [
        confettiColorOne,
        confettiColorTwo,
        confettiColorThree,
        confettiColorFour,
        confettiColorFive,
        confettiColorSix,
        confettiColorSeven,
        confettiColorEight,
        confettiColorNine,
        confettiColorTen,
        confettiColorEleven,
        confettiColorTwelve,
      ],
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            firstTeamClassNotifier.currentFirstTeamClass.nickname!,
            style: GoogleFonts.sanchez(color: appBarTextColor, fontSize: 25, fontWeight: FontWeight.w400),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          elevation: 10,
          backgroundColor: appBarBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: appBarIconColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (firstTeamClassNotifier.currentFirstTeamClass.imageTwo.toString().isEmpty) ...[
                Tooltip(
                    message: firstTeamClassNotifier.currentFirstTeamClass.name,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        crossFadeView = crossFadeView == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
                      }),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .64,
                        child: Card(
                          color: Colors.transparent,
                          elevation: 5,
                          margin: const EdgeInsets.all(10),
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: AnimatedCrossFade(
                            crossFadeState: crossFadeView == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 1000),
                            firstChild: CachedNetworkImage(
                              imageUrl: firstTeamClassNotifier.currentFirstTeamClass.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(MdiIcons.alertRhombus),
                            ),
                            secondChild: CachedNetworkImage(
                              imageUrl: firstTeamClassNotifier.currentFirstTeamClass.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(MdiIcons.alertRhombus),
                            ),
                          ),
                        ),
                      ),
                    )),
              ] else ...[
                Tooltip(
                    message: firstTeamClassNotifier.currentFirstTeamClass.name,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        crossFadeView = crossFadeView == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst;
                      }),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          elevation: 5,
                          margin: const EdgeInsets.all(10),
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: AnimatedCrossFade(
                            crossFadeState: crossFadeView == CrossFadeState.showFirst ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 1000),
                            firstChild: CachedNetworkImage(
                              imageUrl: firstTeamClassNotifier.currentFirstTeamClass.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(MdiIcons.alertRhombus),
                            ),
                            secondChild: CachedNetworkImage(
                              imageUrl: firstTeamClassNotifier.currentFirstTeamClass.imageTwo!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(MdiIcons.alertRhombus),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
              Material(
                color: materialBackgroundColor,
                child: InkWell(
                  splashColor: splashColor.withOpacity(0.20),
                  onTap: () {},
                  child: Card(
                    elevation: 4,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(color: shapeDecorationColor.withOpacity(0.20), width: 4.0, style: BorderStyle.solid),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              firstTeamClassNotifier.currentFirstTeamClass.name!.toUpperCase(),
                              style: GoogleFonts.blinker(color: shapeDecorationTextColor, fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                            (() {
                              if (firstTeamClassNotifier.currentFirstTeamClass.captain == "Yes") {
                                return Row(
                                  children: <Widget>[
                                    const SizedBox(width: 10),
                                    Icon(
                                      MdiIcons.shieldCheck,
                                      color: shapeDecorationIconColor,
                                    ),
                                  ],
                                );
                              } else {
                                return Visibility(
                                  visible: !_isVisible,
                                  child: Icon(
                                    MdiIcons.shieldCheck,
                                    color: shapeDecorationIconColor,
                                  ),
                                );
                              }
                            }()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 5,
                color: cardBackgroundColor,
                margin: const EdgeInsets.all(10),
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                            child: Container(
                              decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50)),
                              // borderRadius: BorderRadius.circular(10)),
                              child: Material(
                                color: materialBackgroundColor.withAlpha(110),
                                child: InkWell(
                                  splashColor: shapeDecorationColorThree.withOpacity(0.1),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 8, left: 14, right: 14),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      child: Text(
                                        // _name.replaceAll(" ", "'s'") + autoBioDetails,
                                        _name.substring(0, _name.indexOf(' ')) + "'s" + autoBioDetails,
                                        style: GoogleFonts.sacramento(
                                          color: textColor,
                                          fontSize: 25,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          (() {
                            if (_autoBio.toString().isNotEmpty ||
                                _bestMoment.toString().isNotEmpty ||
                                _dob.toString().isNotEmpty ||
                                _dreamFC.toString().isNotEmpty ||
                                _positionPlaying.toString().isNotEmpty ||
                                _hobbies.toString().isNotEmpty ||
                                _nickname.toString().isNotEmpty ||
                                _philosophy.toString().isNotEmpty ||
                                _myDropline.toString().isNotEmpty ||
                                _country.toString().isNotEmpty ||
                                _regionFrom.toString().isNotEmpty ||
                                _otherPositionsOfPlay.toString().isNotEmpty ||
                                _favFootballLegend.toString().isNotEmpty ||
                                _yearOfInception.toString().isNotEmpty ||
                                _leftOrRightFooted.toString().isNotEmpty ||
                                _adidasOrNike.toString().isNotEmpty ||
                                _ronaldoOrMessi.toString().isNotEmpty ||
                                _worstMoment.toString().isNotEmpty ||
                                _captain.toString().isNotEmpty ||
                                _prefectPosition.toString().isNotEmpty) {
                              return Visibility(
                                visible: !_isVisible,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                    child: Material(
                                      color: materialBackgroundColor,
                                      child: InkWell(
                                        splashColor: splashColorThree,
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                          child: Text.rich(
                                            TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: autobiographyTitle,
                                                    style: GoogleFonts.aBeeZee(
                                                      color: textColor,
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                TextSpan(
                                                    text: _autoBio,
                                                    style: GoogleFonts.trykker(
                                                      color: textColor,
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w300,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: _isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: 'No Information\n',
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: " ${_name.substring(0, _name.indexOf(' '))} hasn't filled his data",
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_positionPlaying.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: positionPlayingTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_positionPlaying',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: dreamUniversityCourseTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _dreamUniversityCourse,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_otherPositionsOfPlay.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: otherPositionsOfPlayTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_otherPositionsOfPlay',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: favWatchedMovieTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _favWatchedMovie,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_leftOrRightFooted.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: leftOrRightFootedTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_leftOrRightFooted',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: favPlaceInCampusTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _favPlaceInCampus,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_yearOfInception.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: yearOfInceptionTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_yearOfInception',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: chosenSubjectsTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _chosenSubjects,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_dreamFC.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: dreamFCTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_dreamFC',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: dreamUniversityTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _dreamUniversity,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_favFootballLegend.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: favFootballLegendTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_favFootballLegend',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: favSportInCampusTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _favSportInCampus,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_adidasOrNike.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: adidasOrNikeTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_adidasOrNike',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: favClubActivityTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _favClubActivity,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_ronaldoOrMessi.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: ronaldoOrMessiTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_ronaldoOrMessi',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        // child: InkWell(
                                        //   splashColor: splashColorThree,
                                        //   onTap: () {},
                                        //   child: Padding(
                                        //     padding:
                                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        //     child: Text.rich(
                                        //       TextSpan(
                                        //         children: <TextSpan>[
                                        //           TextSpan(
                                        //               text: favClassmateTitle,
                                        //               style: GoogleFonts.aBeeZee(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.bold,
                                        //               )),
                                        //           TextSpan(
                                        //               text: ' ' + _favClassmate,
                                        //               style: GoogleFonts.trykker(
                                        //                 color: textColor,
                                        //                 fontSize: 19,
                                        //                 fontWeight: FontWeight.w300,
                                        //               )),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_bestMoment.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: bestMomentTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_bestMoment',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: bestMomentTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_bestMoment',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_worstMoment.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: worstMomentTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_worstMoment',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: worstMomentTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_worstMoment',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_nickname.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: nicknameTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_nickname',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: nicknameTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_nickname',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_hobbies.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: hobbiesTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_hobbies',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: hobbiesTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_hobbies',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_dob.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: dobTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_dob',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: dobTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_dob',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_country.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: countryTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_country',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: countryTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_country',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_regionFrom.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: regionOfOriginTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_regionFrom',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: regionOfOriginTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_regionFrom',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_autoBio.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: autobiographyTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: _autoBio,
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: autobiographyTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: _autoBio,
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_philosophy.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: philosophyTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_philosophy',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: philosophyTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_philosophy',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                          (() {
                            if (_myDropline.toString().isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                  child: Material(
                                    color: materialBackgroundColor,
                                    child: InkWell(
                                      splashColor: splashColorThree,
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                        child: Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: droplineTitle,
                                                  style: GoogleFonts.aBeeZee(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              TextSpan(
                                                  text: ' $_myDropline',
                                                  style: GoogleFonts.trykker(
                                                    color: textColor,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Visibility(
                                  visible: !_isVisible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                      child: Material(
                                        color: materialBackgroundColor,
                                        child: InkWell(
                                          splashColor: splashColorThree,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: droplineTitle,
                                                      style: GoogleFonts.aBeeZee(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                      text: ' $_myDropline',
                                                      style: GoogleFonts.trykker(
                                                        color: textColor,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w300,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }
                          }()),
                        ],
                      ),
                      // userBIO![sharedValue]!,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40)
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100), barrierColor: backgroundColor);

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _confettiController = ConfettiController(duration: const Duration(seconds: 7));
    _confettiController!.play();

    FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);

    _autoBio = firstTeamClassNotifier.currentFirstTeamClass.autoBio;
    _bestMoment = firstTeamClassNotifier.currentFirstTeamClass.bestMoment;
    _dob = firstTeamClassNotifier.currentFirstTeamClass.dob;
    _dreamFC = firstTeamClassNotifier.currentFirstTeamClass.dreamFC;
    _positionPlaying = firstTeamClassNotifier.currentFirstTeamClass.positionPlaying;
    _email = firstTeamClassNotifier.currentFirstTeamClass.email;
    _facebook = firstTeamClassNotifier.currentFirstTeamClass.facebook;
    _linkedIn = firstTeamClassNotifier.currentFirstTeamClass.linkedIn;
    _hobbies = firstTeamClassNotifier.currentFirstTeamClass.hobbies;
    _instagram = firstTeamClassNotifier.currentFirstTeamClass.instagram;
    _myDropline = firstTeamClassNotifier.currentFirstTeamClass.myDropline;
    _name = firstTeamClassNotifier.currentFirstTeamClass.name;
    _nickname = firstTeamClassNotifier.currentFirstTeamClass.nickname;
    _philosophy = firstTeamClassNotifier.currentFirstTeamClass.philosophy;
    _phone = firstTeamClassNotifier.currentFirstTeamClass.phone;
    _captain = firstTeamClassNotifier.currentFirstTeamClass.captain;
    _prefectPosition = firstTeamClassNotifier.currentFirstTeamClass.teamCaptaining;
    _country = firstTeamClassNotifier.currentFirstTeamClass.constituentCountry;
    _regionFrom = firstTeamClassNotifier.currentFirstTeamClass.regionFrom;
    _twitter = firstTeamClassNotifier.currentFirstTeamClass.twitter;
    _snapchat = firstTeamClassNotifier.currentFirstTeamClass.snapchat;
    _tikTok = firstTeamClassNotifier.currentFirstTeamClass.tikTok;
    _otherPositionsOfPlay = firstTeamClassNotifier.currentFirstTeamClass.otherPositionsOfPlay;
    _favFootballLegend = firstTeamClassNotifier.currentFirstTeamClass.favFootballLegend;
    _yearOfInception = firstTeamClassNotifier.currentFirstTeamClass.yearOfInception;
    _leftOrRightFooted = firstTeamClassNotifier.currentFirstTeamClass.leftOrRightFooted;
    _adidasOrNike = firstTeamClassNotifier.currentFirstTeamClass.adidasOrNike;
    _ronaldoOrMessi = firstTeamClassNotifier.currentFirstTeamClass.ronaldoOrMessi;
    _worstMoment = firstTeamClassNotifier.currentFirstTeamClass.worstMoment;

    // resetVerificationTime();

    userBIO = <int, Widget>{
      /** 0: Useful for CPFC 1st Version and other FC Apps, DND */
      0: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[],
      ),
      1: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          (() {
            if (_positionPlaying.toString().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: materialBackgroundColor,
                    child: InkWell(
                      splashColor: splashColorThree,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: positionPlayingTitle,
                                  style: GoogleFonts.aBeeZee(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text: ' $_positionPlaying',
                                  style: GoogleFonts.trykker(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Visibility(
                  visible: !_isVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                      child: Material(
                        color: materialBackgroundColor,
                        // child: InkWell(
                        //   splashColor: splashColorThree,
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        //     child: Text.rich(
                        //       TextSpan(
                        //         children: <TextSpan>[
                        //           TextSpan(
                        //               text: dreamUniversityCourseTitle,
                        //               style: GoogleFonts.aBeeZee(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.bold,
                        //               )),
                        //           TextSpan(
                        //               text: ' ' + _dreamUniversityCourse,
                        //               style: GoogleFonts.trykker(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.w300,
                        //               )),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ));
            }
          }()),
          (() {
            if (_otherPositionsOfPlay.toString().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: materialBackgroundColor,
                    child: InkWell(
                      splashColor: splashColorThree,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: otherPositionsOfPlayTitle,
                                  style: GoogleFonts.aBeeZee(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text: ' $_otherPositionsOfPlay',
                                  style: GoogleFonts.trykker(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Visibility(
                  visible: !_isVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                      child: Material(
                        color: materialBackgroundColor,
                        // child: InkWell(
                        //   splashColor: splashColorThree,
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        //     child: Text.rich(
                        //       TextSpan(
                        //         children: <TextSpan>[
                        //           TextSpan(
                        //               text: favWatchedMovieTitle,
                        //               style: GoogleFonts.aBeeZee(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.bold,
                        //               )),
                        //           TextSpan(
                        //               text: ' ' + _favWatchedMovie,
                        //               style: GoogleFonts.trykker(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.w300,
                        //               )),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ));
            }
          }()),
          (() {
            if (_leftOrRightFooted.toString().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: materialBackgroundColor,
                    child: InkWell(
                      splashColor: splashColorThree,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: leftOrRightFootedTitle,
                                  style: GoogleFonts.aBeeZee(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text: ' $_leftOrRightFooted',
                                  style: GoogleFonts.trykker(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Visibility(
                  visible: !_isVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                      child: Material(
                        color: materialBackgroundColor,
                        // child: InkWell(
                        //   splashColor: splashColorThree,
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        //     child: Text.rich(
                        //       TextSpan(
                        //         children: <TextSpan>[
                        //           TextSpan(
                        //               text: favPlaceInCampusTitle,
                        //               style: GoogleFonts.aBeeZee(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.bold,
                        //               )),
                        //           TextSpan(
                        //               text: ' ' + _favPlaceInCampus,
                        //               style: GoogleFonts.trykker(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.w300,
                        //               )),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ));
            }
          }()),
          (() {
            if (_yearOfInception.toString().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: materialBackgroundColor,
                    child: InkWell(
                      splashColor: splashColorThree,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: yearOfInceptionTitle,
                                  style: GoogleFonts.aBeeZee(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text: ' $_yearOfInception',
                                  style: GoogleFonts.trykker(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Visibility(
                  visible: !_isVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                      child: Material(
                        color: materialBackgroundColor,
                        // child: InkWell(
                        //   splashColor: splashColorThree,
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        //     child: Text.rich(
                        //       TextSpan(
                        //         children: <TextSpan>[
                        //           TextSpan(
                        //               text: chosenSubjectsTitle,
                        //               style: GoogleFonts.aBeeZee(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.bold,
                        //               )),
                        //           TextSpan(
                        //               text: ' ' + _chosenSubjects,
                        //               style: GoogleFonts.trykker(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.w300,
                        //               )),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ));
            }
          }()),
          (() {
            if (_dreamFC.toString().isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: materialBackgroundColor,
                    child: InkWell(
                      splashColor: splashColorThree,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: dreamFCTitle,
                                  style: GoogleFonts.aBeeZee(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text: ' $_dreamFC',
                                  style: GoogleFonts.trykker(
                                    color: textColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Visibility(
                  visible: !_isVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(color: shapeDecorationColorThree.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                      child: Material(
                        color: materialBackgroundColor,
                        // child: InkWell(
                        //   splashColor: splashColorThree,
                        //   onTap: () {},
                        //   child: Padding(
                        //     padding:
                        //     const EdgeInsets.only(bottom: 15, top: 15, left: 25),
                        //     child: Text.rich(
                        //       TextSpan(
                        //         children: <TextSpan>[
                        //           TextSpan(
                        //               text: dreamUniversityTitle,
                        //               style: GoogleFonts.aBeeZee(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.bold,
                        //               )),
                        //           TextSpan(
                        //               text: ' ' + _dreamUniversity,
                        //               style: GoogleFonts.trykker(
                        //                 color: textColor,
                        //                 fontSize: 19,
                        //                 fontWeight: FontWeight.w300,
                        //               )),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ));
            }
          }()),
        ],
      ),
    };
    super.initState();
  }
}
