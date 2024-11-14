import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:lottie/lottie.dart';

String adminMatchDayChat = "MatchDay";
String generalChat = "General Chat";

class MyChatGFAPage extends StatefulWidget {
  final String clubId;
  const MyChatGFAPage({super.key, required this.clubId});

  @override
  MyChatGFAPageState createState() => MyChatGFAPageState();
}

class MyChatGFAPageState extends State<MyChatGFAPage> {
  TextEditingController adminMatchDayChatMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> adminMatchDayChatMessages = [];
  DateTime? adminMatchDayChatLastMessageDate;
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Club ID: ${widget.clubId}',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
            child: Container(
              width: double.infinity,
              color: const Color.fromRGBO(240, 240, 240, 1.0),
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                thumbColor: Colors.white,
                backgroundColor: Colors.transparent,
                children: {
                  0: Text(
                    adminMatchDayChat,
                    style: GoogleFonts.agbalumo(
                      color: const Color.fromRGBO(38, 34, 35, 1.0),
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  1: Text(
                    generalChat,
                    style: GoogleFonts.andadaPro(
                      color: const Color.fromRGBO(38, 34, 35, 1.0),
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
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
          ),
        ),
      ),
      body: sharedValue == 0 ? _buildAdminMatchDayChatView() : _buildAutobiographyView(),
    );
  }

  Widget _buildAdminMatchDayChatView() {
    return Stack(
      children: <Widget>[
        if (adminMatchDayChatMessages.isEmpty)
          Center(
            child: Lottie.asset('assets/json/chat_gfa_admin_before_chat.json'), // Show when page is empty
          ),
        Positioned.fill(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: adminMatchDayChatMessages.length,
                  itemBuilder: (context, index) {
                    final message = adminMatchDayChatMessages[adminMatchDayChatMessages.length - 1 - index];
                    final messageDate = DateTime(
                      message['time'].year,
                      message['time'].month,
                      message['time'].day,
                    );

                    final showDateSeparator = index == adminMatchDayChatMessages.length - 1 ||
                        messageDate !=
                            DateTime(
                              adminMatchDayChatMessages[adminMatchDayChatMessages.length - 2 - index]['time'].year,
                              adminMatchDayChatMessages[adminMatchDayChatMessages.length - 2 - index]['time'].month,
                              adminMatchDayChatMessages[adminMatchDayChatMessages.length - 2 - index]['time'].day,
                            );

                    return Column(
                      children: [
                        if (showDateSeparator) _buildAdminMatchDayDateSeparator(messageDate),
                        _buildAdminMatchDayMessageItem(context, message),
                      ],
                    );
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
              _buildAdminMatchDayChatMessageInput(),
            ],
          ),
        ),
        if (adminMatchDayChatMessages.isNotEmpty)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Lottie.asset(
                'assets/json/chat_gfa_admin_during_chat.json', // Background animation when chat is going on
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdminMatchDayMessageItem(BuildContext context, Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final isProcessing = message['text'] == 'Processing...';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: isProcessing
                  ? _buildAdminMatchDayLoadingIndicator()
                  : Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.blue[800] : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              DateFormat.jm().format(message['time']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMatchDayChatMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: adminMatchDayChatMessageController,
              decoration: InputDecoration(
                hintText: "Enter your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            backgroundColor: Colors.blue[800],
            onPressed: sendAdminMatchDayItemMessage,
            mini: true,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendAdminMatchDayItemMessage() async {
    if (adminMatchDayChatMessageController.text.isEmpty) return;

    final userMessage = adminMatchDayChatMessageController.text;
    final currentTime = DateTime.now(); // Capture the current time

    setState(() {
      adminMatchDayChatMessages.add({'text': userMessage, 'type': 'user', 'time': currentTime});
      adminMatchDayChatMessages.add({'text': 'Processing...', 'type': 'system', 'time': currentTime});
      adminMatchDayChatLastMessageDate = currentTime;
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
        final systemTime = DateTime.now(); // Timestamp for the system response

        setState(() {
          adminMatchDayChatMessages.removeLast(); // Remove 'Processing...' message
          adminMatchDayChatMessages.add({'text': message, 'type': 'system', 'time': systemTime});
        });

        // Scroll to the bottom after adding new messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });

        if (message.contains("Multiple players found") || message.contains("Who scored the goal?")) {
          // Don't update Firestore, wait for user clarification
        } else {
          // Backend Flask handles Firestore update, no need to update in Flutter
        }
      } else {
        setState(() {
          adminMatchDayChatMessages.removeLast(); // Remove 'Processing...' message
          adminMatchDayChatMessages
              .add({'text': 'Failed to parse message. Status code: ${response.statusCode}', 'type': 'system', 'time': currentTime});
        });
      }
    } catch (e) {
      setState(() {
        adminMatchDayChatMessages.removeLast(); // Remove 'Processing...' message
        adminMatchDayChatMessages.add({'text': 'Error: $e', 'type': 'system', 'time': currentTime});
      });
    }

    adminMatchDayChatMessageController.clear();
  }

  Widget _buildAdminMatchDayLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40, // Larger to accommodate the Lottie animation
          height: 40,
          child: Lottie.asset('assets/json/chat_gfa_admin_ai_texting_chat.json'), // Animation for AI "thinking"
        ),
        const SizedBox(width: 8),
        Text(
          "Thinking...",
          style: TextStyle(
            color: Colors.blue[800],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAutobiographyView() {
    return Container(); // Empty container for now
  }

  @override
  void initState() {
    super.initState();

    // Scroll to the bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Widget _buildAdminMatchDayDateSeparator(DateTime date) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _getDateString(date),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMMM y').format(date);
    }
  }
}
