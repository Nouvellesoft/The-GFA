import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
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
  TextEditingController generalChatMessageController = TextEditingController(); // For General Chat

  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> adminMatchDayChatMessages = [];
  List<Map<String, dynamic>> generalChatMessages = [];

  DateTime? adminMatchDayChatLastMessageDate;
  DateTime? generalChatLastMessageDate;

  int sharedValue = 0;
  bool isRecording = true;
  double appBarElevation = 0.0;

  @override
  void initState() {
    super.initState();

    // Scroll controller listener to adjust AppBar elevation
    _scrollController.addListener(() {
      final scrollOffset = _scrollController.offset;
      setState(() {
        appBarElevation = scrollOffset > 0 ? 4.0 : 0.0; // Change elevation based on scroll
      });
    });

    // Scroll to the bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    adminMatchDayChatMessageController.addListener(_handleAdminChatTextChange);
    generalChatMessageController.addListener(_handleGeneralChatTextChange);
  }

  @override
  void dispose() {
    adminMatchDayChatMessageController.dispose();
    generalChatMessageController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: appBarElevation,
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
              color: const Color.fromRGBO(255, 255, 255, 1.0),
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                thumbColor: Colors.white,
                backgroundColor: Colors.transparent,
                children: {
                  0: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                    ), // Adjust this to control inner spacing
                    child: Text(
                      adminMatchDayChat,
                      style: GoogleFonts.agbalumo(
                        color: const Color.fromRGBO(38, 34, 35, 1.0),
                        fontSize: MediaQuery.of(context).size.width * 0.055,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                    ), // Adjust this to control inner spacing
                    child: Text(
                      generalChat,
                      style: GoogleFonts.andadaPro(
                        color: const Color.fromRGBO(38, 34, 35, 1.0),
                        fontSize: MediaQuery.of(context).size.width * 0.055,
                        fontWeight: FontWeight.w600,
                      ),
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
      body: sharedValue == 0 ? _buildAdminMatchDayChatView() : _buildGeneralChatView(),
    );
  }

  Widget _buildAdminMatchDayChatView() {
    return Stack(
      children: <Widget>[
        if (adminMatchDayChatMessages.isEmpty)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Lottie.asset('assets/json/chat_gfa_admin_before_chat.json'), // Show when page is empty
                ),
                const SizedBox(height: 20), // Add some space between the Lottie and the text
                Align(
                  alignment: Alignment.center,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Goal by Dexter, Adebayo gave the assist', // Your animated text here
                        textStyle: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Change this based on your theme
                        ),
                        speed: const Duration(milliseconds: 100), // Set the speed for each character
                      ),
                    ],
                    isRepeatingAnimation: true,
                  ),
                ),
              ],
            ),
          ),
        if (adminMatchDayChatMessages.isNotEmpty)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Top Lottie Animation
                Align(
                  alignment: Alignment.topCenter,
                  child: Lottie.asset(
                    'assets/json/cc.json', // Top Lottie animation file
                    height: MediaQuery.of(context).size.width * 0.5, // Adjust the height as needed
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),

                const SizedBox(height: 50), // Space between top and center Lottie

                // Center Lottie Animation
                Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/json/chat_gfa_admin_during_chat.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ],
            ),
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
      ],
    );
  }

  Widget _buildGeneralChatView() {
    return Stack(
      children: <Widget>[
        if (generalChatMessages.isEmpty)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Lottie.asset('assets/json/chat_gfa_admin_before_chat.json'), // Animation for General Chat
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'When did Blake Kasser join this football club', // Intro text for general chat
                        textStyle: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: true,
                  ),
                ),
              ],
            ),
          ),
        if (generalChatMessages.isNotEmpty)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Lottie.asset(
                    'assets/json/cc.json',
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/json/chat_gfa_admin_during_chat.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ],
            ),
          ),
        Positioned.fill(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: generalChatMessages.length,
                  itemBuilder: (context, index) {
                    final message = generalChatMessages[generalChatMessages.length - 1 - index];
                    final messageDate = DateTime(
                      message['time'].year,
                      message['time'].month,
                      message['time'].day,
                    );

                    final showDateSeparator = index == generalChatMessages.length - 1 ||
                        messageDate !=
                            DateTime(
                              generalChatMessages[generalChatMessages.length - 2 - index]['time'].year,
                              generalChatMessages[generalChatMessages.length - 2 - index]['time'].month,
                              generalChatMessages[generalChatMessages.length - 2 - index]['time'].day,
                            );

                    return Column(
                      children: [
                        if (showDateSeparator) _buildGeneralChatDateSeparator(messageDate),
                        _buildGeneralChatMessageItem(context, message),
                      ],
                    );
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
              _buildGeneralChatMessageInput(),
            ],
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

  Widget _buildGeneralChatMessageItem(BuildContext context, Map<String, dynamic> message) {
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
                  ? _buildGeneralChatLoadingIndicator()
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: adminMatchDayChatMessageController,
                decoration: InputDecoration(
                  hintText: "Enter your message or tap the mic...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none, // No border
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    setState(() {
                      isRecording = false; // Switch to send button when typing
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // FloatingActionButton.extended with rectangular shape
            isRecording
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.grey[600],
                    onPressed: startAdminChatVoiceInput,
                    label: const Text(
                      "Voice",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : FloatingActionButton.extended(
                    backgroundColor: Colors.blue[800],
                    onPressed: sendAdminMatchDayItemMessage,
                    label: const Text(
                      "Send",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralChatMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: generalChatMessageController,
                decoration: InputDecoration(
                  hintText: "Enter your message or tap the mic...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none, // No border
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    setState(() {
                      isRecording = false; // Switch to send button when typing
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // FloatingActionButton.extended with rectangular shape
            isRecording
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.grey[600],
                    onPressed: startGeneralChatVoiceInput,
                    label: const Text(
                      "Voice",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : FloatingActionButton.extended(
                    backgroundColor: Colors.blue[800],
                    onPressed: sendGeneralChatMessage,
                    label: const Text(
                      "Send",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
          ],
        ),
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
    setState(() {
      isRecording = true; // Switch back to the mic button
    });
  }

  Future<void> sendGeneralChatMessage() async {
    if (generalChatMessageController.text.isEmpty) return;

    final userMessage = generalChatMessageController.text;
    final currentTime = DateTime.now(); // Capture the current time

    setState(() {
      generalChatMessages.add({'text': userMessage, 'type': 'user', 'time': currentTime});
      generalChatMessages.add({'text': 'Processing...', 'type': 'system', 'time': currentTime});
      generalChatLastMessageDate = currentTime;
    });

    try {
      var url = Uri.parse('http://127.0.0.1:5000/general_chat');
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
          generalChatMessages.removeLast(); // Remove 'Processing...' message
          generalChatMessages.add({'text': message, 'type': 'system', 'time': systemTime});
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
          generalChatMessages.removeLast(); // Remove 'Processing...' message
          generalChatMessages.add({'text': 'Failed to parse message. Status code: ${response.statusCode}', 'type': 'system', 'time': currentTime});
        });
      }
    } catch (e) {
      setState(() {
        generalChatMessages.removeLast(); // Remove 'Processing...' message
        generalChatMessages.add({'text': 'Error: $e', 'type': 'system', 'time': currentTime});
      });
    }

    generalChatMessageController.clear();
    setState(() {
      isRecording = true; // Switch back to the mic button
    });
  }

  Widget _buildAdminMatchDayLoadingIndicator() {
    return Center(child: Lottie.asset('assets/json/chat_gfa_admin_ai_texting_chat.json', width: 250, height: 250, fit: BoxFit.cover));
  }

  Widget _buildGeneralChatLoadingIndicator() {
    return Center(child: Lottie.asset('assets/json/chat_gfa_admin_ai_texting_chat.json', width: 250, height: 250, fit: BoxFit.cover));
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

  Widget _buildGeneralChatDateSeparator(DateTime date) {
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

  void _handleAdminChatTextChange() {
    setState(() {
      isRecording = adminMatchDayChatMessageController.text.isEmpty;
    });
  }

  void _handleGeneralChatTextChange() {
    setState(() {
      isRecording = generalChatMessageController.text.isEmpty;
    });
  }

  void _updateWithAdminChatVoiceInput(String voiceText) {
    setState(() {
      adminMatchDayChatMessageController.text = voiceText;
      isRecording = false; // Switch to the send button
    });
  }

  void _updateWithGeneralChatVoiceInput(String voiceText) {
    setState(() {
      generalChatMessageController.text = voiceText;
      isRecording = false; // Switch to the send button
    });
  }

  void startAdminChatVoiceInput() async {
    // Here you will call a voice recognition package
    // For demo purposes, we're simulating voice input
    Future.delayed(const Duration(seconds: 3), () {
      _updateWithAdminChatVoiceInput("David scored, assist by Daniel");
    });
  }

  void startGeneralChatVoiceInput() async {
    // Here you will call a voice recognition package
    // For demo purposes, we're simulating voice input
    Future.delayed(const Duration(seconds: 3), () {
      _updateWithGeneralChatVoiceInput("When did Coach Edwin this club");
    });
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
