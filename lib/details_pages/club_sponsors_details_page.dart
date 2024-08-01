import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/notifier/a_upcoming_matches_notifier.dart';
import '/notifier/club_sponsors_notifier.dart';
import '../model/club_sponsors.dart';

Color conColor = const Color.fromRGBO(194, 194, 220, 1.0);
Color conColorTwo = const Color.fromRGBO(151, 147, 151, 1.0);
Color textColor = const Color.fromRGBO(222, 214, 214, 1.0);
Color whiteColor = const Color.fromRGBO(255, 253, 253, 1.0);
Color twitterColor = const Color.fromRGBO(36, 81, 149, 1.0);
Color instagramColor = const Color.fromRGBO(255, 255, 255, 1.0);
Color facebookColor = const Color.fromRGBO(43, 103, 195, 1.0);
Color snapchatColor = const Color.fromRGBO(222, 163, 36, 1.0);
Color youtubeColor = const Color.fromRGBO(220, 45, 45, 1.0);
Color websiteColor = const Color.fromRGBO(104, 79, 178, 1.0);
Color emailColor = const Color.fromRGBO(230, 45, 45, 1.0);
Color phoneColor = const Color.fromRGBO(20, 134, 46, 1.0);
Color backgroundColor = const Color.fromRGBO(20, 36, 62, 1.0);

String callFIRST = "tel:+44";
String smsFIRST = "sms:+44";
String whatsAppFIRST = "https://api.whatsapp.com/send?phone=+44";
String whatsAppSECOND = "&text=Hello%20";
String whatsAppTHIRD = ",%20How%20are%20you%20doing%20today?";
String mailFIRST = "mailto:";
String mailSECOND = "?subject=Hello ";
String urlTwitter = "https://twitter.com/";
String urlFacebook = "https://facebook.com/";
String urlYoutube = "https://youtube.com/watch?v=";
String urlInstagram = "https://www.instagram.com/";
String urlSnapchat = "https://www.snapchat.com/add/";

String callButton = "Call Us";
String whatsAppButton = "WhatsApp Us";
String emailButton = "Email Us";
String twitterButton = "Our Twitter";
String instagramButton = "Our Instagram";
String facebookButton = "Our Facebook";
String youtubeButton = "Our Youtube";
String websiteButton = "Our Website";
String snapchatButton = "Our Snapchat";

String reachUsTitle = "Reach Us";
String ourServicesTitle = "Our Services";
String addressTitle = "Our Location:";
String categoryTitle = "Category:";

String facebookProfileSharedPreferencesTitle = "Manual Website Search";
String facebookProfileSharedPreferencesContentOne = "Apparently, you'd need to search manually for ";
String facebookProfileSharedPreferencesContentTwo = ", on Facebook.com";
String facebookProfileSharedPreferencesButton = "Go to Facebook";
String facebookProfileSharedPreferencesButtonTwo = "Lol, No";

dynamic _name;
dynamic _phone;
dynamic _email;
dynamic _twitter;
dynamic _instagram;
dynamic _facebook;
dynamic _youtube;
dynamic _website;
dynamic _snapchat;
dynamic _aboutUs;
dynamic _ourServices;

late ClubSponsorsNotifier clubSponsorsNotifier;
late UpcomingMatchesNotifier upcomingMatchesNotifier;

class ClubSponsorsDetailsPage extends StatefulWidget {
  const ClubSponsorsDetailsPage({super.key});

  @override
  State<ClubSponsorsDetailsPage> createState() => _ClubSponsorsDetailsPageState();
}

class _ClubSponsorsDetailsPageState extends State<ClubSponsorsDetailsPage> {
  Future launchURL(String url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("The required app is not installed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    clubSponsorsNotifier = Provider.of<ClubSponsorsNotifier>(context, listen: true);
    upcomingMatchesNotifier = Provider.of<UpcomingMatchesNotifier>(context);

    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          clubSponsorsNotifier.currentClubSponsors.name!,
          style: GoogleFonts.alkatra(color: textColor, fontSize: 25, fontWeight: FontWeight.w400),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 10,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.upload),
        //     onPressed: () {
        //       _showUploadDialog();
        //     },
        //   ),
        // ],
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Container(
                  width: width,
                  // height: height/0.8,
                  decoration: BoxDecoration(color: conColor.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: width / 2.7,
                              height: width / 2.7,
                              decoration: BoxDecoration(
                                color: conColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Container(
                                  width: width / 3,
                                  height: width / 3,
                                  decoration: BoxDecoration(
                                    color: conColorTwo.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(14),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(clubSponsorsNotifier.currentClubSponsors.image!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: width / 2.7,
                              height: width / 2.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    clubSponsorsNotifier.currentClubSponsors.name!,
                                    style: GoogleFonts.aldrich(
                                      color: textColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$addressTitle ${clubSponsorsNotifier.currentClubSponsors.address!}',
                                    style: GoogleFonts.aldrich(
                                      color: textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '$categoryTitle ${clubSponsorsNotifier.currentClubSponsors.category!}',
                                      style: GoogleFonts.aldrich(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: width / 1.22,
                              decoration: BoxDecoration(
                                color: conColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text.rich(
                                      textAlign: TextAlign.justify,
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '$reachUsTitle\n',
                                              style: GoogleFonts.aBeeZee(
                                                color: textColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ],
                                      ),
                                    ),
                                    Wrap(
                                      runAlignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 8,
                                      children: [
                                        Visibility(
                                          visible: _phone.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              if (_phone.toString().startsWith('0')) {
                                                var most = _phone.toString().substring(1);
                                                launchURL(callFIRST + most);
                                              } else {
                                                launchURL(callFIRST + _phone);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: phoneColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.phoneDial,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              callButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _phone.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              if (_phone.toString().startsWith('0')) {
                                                var most = _phone.toString().substring(1);
                                                var firstName = _name.toString().substring(0, _name.toString().indexOf(" "));
                                                launchURL(whatsAppFIRST + most + whatsAppSECOND + firstName + whatsAppTHIRD);
                                                launchURL(whatsAppFIRST + most);
                                              } else {
                                                var firstName = _name.toString().substring(0, _name.toString().indexOf(" "));
                                                launchURL(whatsAppFIRST + _phone + whatsAppSECOND + firstName + whatsAppTHIRD);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: phoneColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.whatsapp,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              whatsAppButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _email.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              launchURL(mailFIRST + _email + mailSECOND + _name);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: emailColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.email,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              emailButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _twitter.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              if (_twitter.toString().startsWith('@')) {
                                                var handle = _twitter.toString().substring(1);
                                                launchURL(urlTwitter + handle);
                                              } else {
                                                launchURL(urlTwitter + _twitter);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: twitterColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.twitter,
                                              size: 17,
                                              color: twitterColor,
                                            ),
                                            label: Text(
                                              twitterButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _instagram.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              if (_instagram.toString().startsWith('@')) {
                                                var handle = _instagram.toString().substring(1);
                                                launchURL(urlInstagram + handle);
                                              } else {
                                                launchURL(urlInstagram + _instagram);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: instagramColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.instagram,
                                              size: 17,
                                              color: instagramColor,
                                            ),
                                            label: Text(
                                              instagramButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _snapchat.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              if (_snapchat.toString().startsWith('@')) {
                                                var handle = _snapchat.toString().substring(1);
                                                launchURL(urlSnapchat + handle);
                                              } else {
                                                launchURL(urlSnapchat + _snapchat);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: snapchatColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.snapchat,
                                              size: 17,
                                              color: snapchatColor,
                                            ),
                                            label: Text(
                                              snapchatButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _website.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              launchURL(_website);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: websiteColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.searchWeb,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              websiteButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _facebook.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              facebookLink();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: facebookColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.facebook,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              facebookButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _youtube.isNotEmpty,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              launchURL(urlYoutube + _youtube);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: youtubeColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 2.0,
                                              ),
                                            ),
                                            icon: Icon(
                                              MdiIcons.youtube,
                                              size: 17,
                                              color: whiteColor,
                                            ),
                                            label: Text(
                                              youtubeButton,
                                              style: GoogleFonts.raleway(
                                                color: textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: width / 1.19,
                              // height: width/1.6,
                              decoration: BoxDecoration(
                                color: conColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text.rich(
                                  textAlign: TextAlign.justify,
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '${clubSponsorsNotifier.currentClubSponsors.name!}\n',
                                          style: GoogleFonts.aBeeZee(
                                            color: textColor,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: '  $_aboutUs\n\n',
                                          style: GoogleFonts.trykker(
                                            color: textColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          )),
                                      TextSpan(
                                          text: '$ourServicesTitle\n',
                                          style: GoogleFonts.aBeeZee(
                                            color: textColor,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      TextSpan(
                                          text: '  $_ourServices',
                                          style: GoogleFonts.trykker(
                                            color: textColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Container(
                              width: width / 1.19,
                              height: width / 1.6,
                              decoration: BoxDecoration(
                                color: conColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Swiper(
                                curve: Curves.bounceIn,
                                autoplay: true,
                                viewportFraction: 0.8,
                                scale: 0.9,
                                itemCount: clubSponsorsNotifier.clubSponsorsList.length,
                                // Total count of images in all documents
                                itemBuilder: (context, index) {
                                  int imageIndex = index % 5;
                                  ClubSponsors sponsor = clubSponsorsNotifier.currentClubSponsors;

                                  String? imageUrl;
                                  switch (imageIndex) {
                                    case 0:
                                      imageUrl = sponsor.image;
                                      break;
                                    case 1:
                                      imageUrl = sponsor.imageTwo;
                                      break;
                                    case 2:
                                      imageUrl = sponsor.imageThree;
                                      break;
                                    case 3:
                                      imageUrl = sponsor.imageFour;
                                      break;
                                    case 4:
                                      imageUrl = sponsor.imageFive;
                                      break;
                                    default:
                                      imageUrl = null;
                                      break;
                                  }

                                  if (imageUrl != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          image: DecorationImage(
                                            alignment: Alignment.topCenter,
                                            image: CachedNetworkImageProvider(imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink(); // Return an empty container if image URL is null
                                  }
                                },
                                layout: SwiperLayout.DEFAULT,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _name = clubSponsorsNotifier.currentClubSponsors.name;
    _phone = clubSponsorsNotifier.currentClubSponsors.phone;
    _email = clubSponsorsNotifier.currentClubSponsors.email;
    _twitter = clubSponsorsNotifier.currentClubSponsors.twitter;
    _instagram = clubSponsorsNotifier.currentClubSponsors.instagram;
    _facebook = clubSponsorsNotifier.currentClubSponsors.facebook;
    _youtube = clubSponsorsNotifier.currentClubSponsors.youtube;
    _website = clubSponsorsNotifier.currentClubSponsors.website;
    _snapchat = clubSponsorsNotifier.currentClubSponsors.snapchat;
    _aboutUs = clubSponsorsNotifier.currentClubSponsors.aboutUs;
    _ourServices = clubSponsorsNotifier.currentClubSponsors.ourServices;

    super.initState();
  }

  void facebookLink() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        backgroundColor: backgroundColor,
        title: Text(
          facebookProfileSharedPreferencesTitle,
          style: TextStyle(color: textColor),
        ),
        content: Text(
          facebookProfileSharedPreferencesContentOne + _facebook + facebookProfileSharedPreferencesContentTwo,
          textAlign: TextAlign.justify,
          style: TextStyle(color: textColor),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              launchURL(urlFacebook);
              Fluttertoast.showToast(
                msg: 'Success! Facebook Page Opening',
                // Show success message (you can replace it with actual banner generation logic)
                gravity: ToastGravity.BOTTOM,
                backgroundColor: backgroundColor,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Text(
              facebookProfileSharedPreferencesButton,
              style: TextStyle(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              facebookProfileSharedPreferencesButtonTwo,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
