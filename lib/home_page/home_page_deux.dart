import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../club_admin/club_admin_page.dart';
import '../sidebar/sidebar_layout.dart';

// String clubName = '';

class PandCTransitions extends StatelessWidget {
  final String clubId;

  const PandCTransitions({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) {
    // clubName = Provider.of<ClubGlobalProvider>(context).clubName;

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
          Text(
            "Welcome to\n $clubId App",
            style: const TextStyle(
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
                SlideTransition1(SideBarLayout(
                  clubId: clubId,
                )),
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
          'This is for club coaches and admins',
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
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white70),
              cursorColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.indigoAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String enteredPasscode = passcodeController.text.trim();

                    // Retrieve the stored passcode from Firestore
                    DocumentSnapshot<Map<String, dynamic>> snapshot =
                        await FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('AboutClub').doc('about_club_page').get();

                    String storedPasscode = snapshot.data()!['admin_passcode'] ?? '';

                    // Check if the entered passcode matches the stored passcode
                    if (enteredPasscode == storedPasscode) {
                      if (context.mounted) {
                        Navigator.pop(context);

                        _showAdminWelcomeToast();
                        Navigator.push(context, SlideTransition1(MyClubAdminPage(clubId: clubId)));
                      }
                    } else {
                      // Show a toast for incorrect passcode
                      Fluttertoast.showToast(
                        msg: 'Incorrect passcode',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
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
