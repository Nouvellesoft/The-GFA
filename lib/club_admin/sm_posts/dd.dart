// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:confetti/confetti.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms_autofill/sms_autofill.dart';
//
// Color backgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
// Color appBarTextColor = Colors.white;
// Color appBarBackgroundColor = const Color.fromRGBO(33, 37, 41, 1.0);
// Color appBarIconColor = Colors.white;
//
// // late FirstTeamClassNotifier firstTeamClassNotifier;
//
// dynamic _phone;
//
// class SubPage extends StatefulWidget {
//   // final String clubId;
//   const SubPage({super.key, this.title});
//
//   final String? title;
//
//   @override
//   State<SubPage> createState() => _SubPageState();
// }
//
// class _SubPageState extends State<SubPage> {
//   // final _formKey = GlobalKey<FormState>();
//   String otpCode = "";
//   bool isLoaded = false;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   String _receivedId = ""; // Add this line
//   bool isOTPComplete = true;
//   bool isOtpVerified = true; // Add this variable
//   // Declare a boolean variable to track OTP generation
//   bool isOtpGenerated = true;
//
//   bool isModifyingAutobiography = true; // Assuming modifying autobiography by default
//
//   ConfettiController? _confettiController;
//
//   bool _isVisible = true;
//
//   // Create a GlobalKey for the form
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   // Firebase Firestore instance
//   final firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     // firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: true);
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         centerTitle: true,
//         // title: Text(
//         //   // firstTeamClassNotifier.currentFirstTeamClass.nickname!,
//         //   style: GoogleFonts.sanchez(color: appBarTextColor, fontSize: 25, fontWeight: FontWeight.w400),
//         // ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30),
//           ),
//         ),
//         elevation: 10,
//         backgroundColor: appBarBackgroundColor,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: appBarIconColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           PopupMenuButton(
//               color: const Color.fromRGBO(255, 255, 255, 1.0),
//               icon: const Icon(
//                 Icons.menu,
//                 color: Color.fromRGBO(255, 255, 255, 1.0),
//               ),
//               itemBuilder: (context) => [
//                     const PopupMenuItem<int>(
//                       value: 0,
//                       child: Text(
//                         "Modify your Autobiography",
//                         style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
//                       ),
//                     ),
//                     const PopupMenuItem<int>(
//                       value: 1,
//                       child: Text(
//                         "Modify your Images",
//                         style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
//                       ),
//                     ),
//                   ],
//               onSelected: (item) async {
//                 setState(() {
//                   // Set the flag based on the selected item
//                   isModifyingAutobiography = item == 0;
//                 });
//                 _showDialogAndVerify();
//
//                 // modifyProfile(); // Use modifyProfile function instead of _showAutobiographyModificationDialog or _showImageModificationDialog
//               })
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _sendOtpToPhoneNumber() async {
//     String phoneNumber = "+447541315929"; // Replace with your hardcoded phone number
//     // String phoneNumber = "+$_phone"; // Replace with your hardcoded phone number
//
//     try {
//       await auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           // Handle auto verification completed (if needed)
//           await auth.signInWithCredential(credential);
//           if (kDebugMode) {
//             print('Logged In Successfully');
//           }
//
//           Fluttertoast.showToast(
//             msg: 'You’re Welcome',
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.deepOrangeAccent,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           // Handle verification failed
//           if (kDebugMode) {
//             print("Verification failed: ${e.message}");
//           }
//
//           Fluttertoast.showToast(
//             msg: 'Hmm. Check your Internet Connection or maybe too many OTP requests',
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.deepOrangeAccent,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//
//           // You might want to handle the error here or throw an exception
//           throw Exception("Error sending OTP: ${e.message}");
//         },
//         codeSent: (String verificationId, int? resendToken) async {
//           // Save the verification ID to use it later
//           _receivedId = verificationId;
//
//           // Display a message to the user to check their messages for the OTP
//           Fluttertoast.showToast(
//             msg: 'Success! OTP sent to your phone number',
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.deepOrangeAccent,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//           // Optionally, you can set a timer to automatically fill the OTP field after some delay
//           // For example, wait for 30 seconds before filling the OTP field
//           await Future.delayed(const Duration(seconds: 5));
//
//           // Once OTP is successfully sent, set isOtpGenerated to true
//           setState(() {
//             isOtpGenerated = true;
//             isOtpVerified = true;
//             isOTPComplete = true;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           // Handle timeout (if needed)
//           if (kDebugMode) {
//             print('TimeOut');
//           }
//         },
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error sending OTP: $e');
//       }
//       Fluttertoast.showToast(
//         msg: 'Error sending OTP. Please try again.',
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       // Handle any other errors that might occur during the verification process
//       throw Exception("Error sending OTP: $e");
//     }
//   }
//
//   Future<void> verifyOTPCode() async {
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: _receivedId,
//       smsCode: otpCode,
//     );
//     try {
//       await auth.signInWithCredential(credential).then((value) async {
//         if (kDebugMode) {
//           print('User verification is Successful');
//         }
//
//         // Save the verification timestamp only if it's not already set
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? userProperties = prefs.getString('verificationUserProperties');
//         String currentProperties = '_name'; // You can adjust this combination based on your requirements
//
//         if (userProperties == null || userProperties != currentProperties) {
//           // Only update the timestamp if the user's properties are not set or have changed
//           prefs.setString('verificationUserProperties', currentProperties);
//           prefs.setInt('verificationTime', DateTime.now().millisecondsSinceEpoch);
//         }
//
//         // // Start the 30-minute timer
//         // isUserVerifiedRecently();
//
//         // Set isOtpVerified to true upon successful OTP verification
//         setState(() {
//           isOtpVerified = true;
//         });
//
//         Fluttertoast.showToast(
//           msg: 'Verified. Thank you.',
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.deepOrangeAccent,
//           textColor: Colors.white,
//         second_team_details_page.dart  fontSize: 16.0,
//         );
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
//
//         // Close the OTP verification dialog upon success
//         // Navigator.pop(context);
//
//         // Check if modifying autobiography or image and show the appropriate dialog
//         // if (isModifyingAutobiography) {
//         //   _showAutobiographyModificationDialog();
//         // } else {
//         //   _showImageModificationDialog();
//         // }
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error verifying OTP: $e');
//       }
//       Fluttertoast.showToast(
//         msg: 'OTP incorrect. Please retype.',
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.deepOrangeAccent,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//
//       // Handle any other errors that might occur during the verification process
//       throw Exception("Error verifying OTP: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     // FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
//     //
//     // _phone = firstTeamClassNotifier.currentFirstTeamClass.phone;
//     super.initState();
//   }
//
//   Future<void> _showDialogAndVerify() async {
//     final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();
//
//     showDialog<String>(
//         // barrierColor: const Color.fromRGBO(66, 67, 69, 1.0),
//         context: context,
//         builder: (BuildContext context) => PopScope(
//               onPopInvokedWithResult: (didPop, result) async {
//                 // Perform your cleanup actions
//                 otpCode = '';
//                 isOTPComplete = false;
//
//                 // Optionally handle the pop result
//                 // You can do additional things based on `didPop` and `result`
//
//                 if (didPop) {
//                   // Allow the pop to proceed
//                   Navigator.of(context).pop();
//                 }
//               },
//               canPop: true, // Allow the pop action
//               child: AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//                 backgroundColor: const Color.fromRGBO(223, 225, 229, 1.0),
//                 title: const Text(
//                   "Please click 'Generate OTP', input your OTP from the sent sms.",
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
//                 ),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () async {
//                       // User needs to send OTP for verification
//                       await _sendOtpToPhoneNumber();
//                       setState(() {
//                         otpCode = '';
//                       });
//                     },
//                     child: const Text('Generate OTP', style: TextStyle(color: Colors.black)),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       await verifyOTPCode();
//                       setState(() {
//                         otpCode = '';
//                         isOTPComplete = false; // Reset after verification
//                       });
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('Verify OTP', style: TextStyle(color: Colors.black)),
//                   ),
//                 ],
//                 content: Padding(
//                   padding: const EdgeInsets.all(6.0),
//                   child: Form(
//                     key: dialogFormKey,
//                     child: PinFieldAutoFill(
//                       autoFocus: true,
//                       currentCode: otpCode,
//                       decoration: BoxLooseDecoration(
//                         gapSpace: 5,
//                         radius: const Radius.circular(8),
//                         strokeColorBuilder: isOtpGenerated
//                             ? const FixedColorBuilder(Color(0xFFE16641))
//                             : const FixedColorBuilder(Colors.grey), // Use grey color if OTP is not generated
//                       ),
//                       codeLength: 6,
//                       onCodeChanged: (code) {
//                         if (kDebugMode) {
//                           print("OnCodeChanged : $code");
//                         }
//                         otpCode = code.toString();
//                         setState(() {
//                           isOTPComplete = otpCode.length == 6;
//                         });
//                       },
//                       onCodeSubmitted: (val) {
//                         if (kDebugMode) {
//                           print("OnCodeSubmitted : $val");
//                         }
//                         setState(() {
//                           otpCode = val;
//                           isOTPComplete = otpCode.length == 6; // Update based on OTP length
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ));
//   }
// }
