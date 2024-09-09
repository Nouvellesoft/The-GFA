import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyChatGFAPage extends StatefulWidget {
  final String clubId;
  const MyChatGFAPage({super.key, required this.clubId});

  @override
  MyChatGFAPageState createState() => MyChatGFAPageState();
}

class MyChatGFAPageState extends State<MyChatGFAPage> {
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clubId),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        messages[index],
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
    );
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    setState(() {
      messages.add(messageController.text);
    });

    try {
      var url = Uri.parse('http://127.0.0.1:5000/parse');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': messageController.text}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var goalScorer = data['goal_scorer'];
        var assistProvider = data['assist_provider'];

        if (goalScorer != null && assistProvider != null) {
          // Update Firestore
          await updateFirestore(goalScorer, assistProvider);

          // Display parsed data
          setState(() {
            messages.add('Goal by $goalScorer, assist by $assistProvider');
          });
        } else {
          setState(() {
            messages.add('Failed to parse goal and assist information');
          });
        }
      } else {
        setState(() {
          messages.add('Failed to parse message. Status code: ${response.statusCode}');
        });
        if (kDebugMode) {
          print('Failed to parse message. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      setState(() {
        messages.add('Error: $e');
      });
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }

    messageController.clear();
  }

  Future<void> updateFirestore(String goalScorer, String assistProvider) async {
    try {
      final clubsRef = FirebaseFirestore.instance.collection('clubs');
      final clubDoc = clubsRef.doc(widget.clubId);
      final playersRef = clubDoc.collection('PlayersTable');

      // Update goal scorer
      var goalDoc = await playersRef.where('player_name', isEqualTo: goalScorer).get();
      if (goalDoc.docs.isNotEmpty) {
        await playersRef.doc(goalDoc.docs[0].id).update({'goals_scored': FieldValue.increment(1)});
      }

      // Update assist provider
      var assistDoc = await playersRef.where('player_name', isEqualTo: assistProvider).get();
      if (assistDoc.docs.isNotEmpty) {
        await playersRef.doc(assistDoc.docs[0].id).update({'assists': FieldValue.increment(1)});
      }

      setState(() {
        messages.add('Firestore updated successfully');
      });
    } catch (e) {
      setState(() {
        messages.add('Error updating Firestore: $e');
      });
      if (kDebugMode) {
        print('Error updating Firestore: $e');
      }
    }
  }
}
