import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

String reachDetails = "Contacts";
String autoBioDetails = "AutoBiography";

Map<int, Widget>? userBIO;

Color backgroundColor = const Color.fromRGBO(180, 43, 81, 1);
Color appBarTextColor = Colors.white;
Color appBarBackgroundColor = const Color.fromRGBO(180, 43, 81, 1);
Color appBarIconColor = Colors.white;
Color materialBackgroundColor = Colors.transparent;
Color shapeDecorationColor = const Color.fromRGBO(180, 43, 81, 1);
Color shapeDecorationTextColor = const Color.fromRGBO(180, 43, 81, 1);
Color cardBackgroundColor = Colors.white;
Color cardThumbColor = Colors.white;
Color cardThumbBackgroundColor = const Color.fromRGBO(180, 43, 81, 1);
Color splashColor = const Color.fromRGBO(180, 43, 81, 1);
Color splashColorTwo = Colors.white;
Color iconTextColor = const Color.fromRGBO(180, 43, 81, 1);
Color iconTextColorTwo = Colors.white;
Color buttonColor = const Color.fromRGBO(180, 43, 81, 1);
Color textColor = const Color.fromRGBO(180, 43, 81, 1);

class MyChatGFAPage extends StatefulWidget {
  final String clubId;
  const MyChatGFAPage({super.key, required this.clubId});

  @override
  MyChatGFAPageState createState() => MyChatGFAPageState();
}

class MyChatGFAPageState extends State<MyChatGFAPage> {
  List<Map<String, String>> messages = [];
  TextEditingController messageController = TextEditingController();
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Club ID: ${widget.clubId}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: CupertinoSlidingSegmentedControl<int>(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      thumbColor: cardThumbColor,
                      backgroundColor: cardThumbBackgroundColor.withAlpha(50),
                      children: {
                        0: Text(
                          reachDetails,
                          style: GoogleFonts.sacramento(color: shapeDecorationTextColor, fontSize: 25, fontWeight: FontWeight.w400),
                        ),
                        1: Text(
                          autoBioDetails,
                          style: GoogleFonts.sacramento(color: shapeDecorationTextColor, fontSize: 25, fontWeight: FontWeight.w400),
                        ),
                      },
                      onValueChanged: (int? value) {
                        setState(() {
                          sharedValue = value!;
                        });
                      },
                      groupValue: sharedValue,
                    ),
                  ),

                  userBIO![sharedValue]!, // Use safe access with null check
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int sharedValue = 0;

  initState() {
    userBIO = <int, Widget>{
      0: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: messages[index]['type'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: messages[index]['type'] == 'user' ? Colors.green : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        messages[index]['text']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      1: Container(),
    };

    super.initState();
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    final userMessage = messageController.text;
    setState(() {
      messages.add({'text': userMessage, 'type': 'user'});
      messages.add({'text': 'Processing...', 'type': 'system'});
    });

    try {
      var url = Uri.parse('http://127.0.0.1:5000/parse');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': userMessage, 'club_id': widget.clubId}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var message = data['message'];

        setState(() {
          messages.removeLast(); // Remove 'Processing...' message
          messages.add({'text': message, 'type': 'system'});
        });

        if (message.contains("Multiple players found") || message.contains("Who scored the goal?")) {
          // Don't update Firestore, wait for user clarification
        } else {
          // Backend Flask handles Firestore update, no need to update in Flutter
        }
      } else {
        setState(() {
          messages.removeLast(); // Remove 'Processing...' message
          messages.add({'text': 'Failed to parse message. Status code: ${response.statusCode}', 'type': 'system'});
        });
        if (kDebugMode) {
          print('Failed to parse message. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      setState(() {
        messages.removeLast(); // Remove 'Processing...' message
        messages.add({'text': 'Error: $e', 'type': 'system'});
      });
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }

    messageController.clear();
  }
}
