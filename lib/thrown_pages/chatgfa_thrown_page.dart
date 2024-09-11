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
  List<Map<String, String>> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club ID: ${widget.clubId}'),
      ),
      body: Column(
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
    );
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
        var goalScorer = data['goal_scorer'];
        var assistProvider = data['assist_provider'];
        var message = data['message'];

        setState(() {
          messages.removeLast(); // Remove 'Processing...' message
          messages.add({'text': message, 'type': 'system'});
        });

        if (message.contains("Multiple players found") || message.contains("Who scored the goal?")) {
          // Don't update Firestore, wait for user clarification
        } else {
          await updateFirestore(goalScorer, assistProvider);
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

  Future<void> updateFirestore(String? goalScorer, String? assistProvider) async {
    if (goalScorer == null && assistProvider == null) return;

    try {
      final clubsRef = FirebaseFirestore.instance.collection('clubs');
      final clubDoc = clubsRef.doc(widget.clubId);
      final playersRef = clubDoc.collection('PllayersTable');

      Future<List<QueryDocumentSnapshot>> findPlayers(String name) async {
        var nameParts = name.toLowerCase().split(' ');
        var querySnapshot = await playersRef.get();
        return querySnapshot.docs.where((doc) {
          var playerName = doc['player_name'].toString().toLowerCase();
          return nameParts.every((part) => playerName.contains(part));
        }).toList();
      }

      if (goalScorer != null) {
        var goalDocs = await findPlayers(goalScorer);
        if (goalDocs.isEmpty) {
          setState(() {
            messages.add({'text': 'No player found matching "$goalScorer"', 'type': 'system'});
          });
        } else if (goalDocs.length > 1) {
          setState(() {
            messages.add({'text': 'Multiple players found matching "$goalScorer". Please specify.', 'type': 'system'});
          });
        } else {
          await playersRef.doc(goalDocs[0].id).update({'goals_scored': FieldValue.increment(1)});
        }
      }

      if (assistProvider != null) {
        var assistDocs = await findPlayers(assistProvider);
        if (assistDocs.isEmpty) {
          setState(() {
            messages.add({'text': 'No player found matching "$assistProvider"', 'type': 'system'});
          });
        } else if (assistDocs.length > 1) {
          setState(() {
            messages.add({'text': 'Multiple players found matching "$assistProvider". Please specify.', 'type': 'system'});
          });
        } else {
          await playersRef.doc(assistDocs[0].id).update({'assists': FieldValue.increment(1)});
        }
      }

      if (kDebugMode) {
        print('Firestore updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Firestore: $e');
      }
      setState(() {
        messages.add({'text': 'Error updating player statistics: $e', 'type': 'system'});
      });
    }
  }
}
