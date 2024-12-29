import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gfa/api/second_team_class_api.dart';
import 'package:the_gfa/details_pages/first_team_details_page.dart';

import '../details_pages/second_team_details_page.dart';
import '../notifier/first_team_class_notifier.dart';
import '../notifier/second_team_class_notifier.dart';
import 'first_team_class_api.dart';

// Worked but not excellent
class BirthdayNotificationService {
  static void handleBirthdayNotification(BuildContext context, RemoteMessage message) {
    print('Handling notification: ${message.data}');

    if (message.data['type'] == 'BIRTHDAY_NOTIFICATION') {
      String clubId = message.data['clubId'];
      String playerName = message.data['playerName'];
      String subcollection = message.data['subcollection']?.toLowerCase();

      print('Notification details - ClubId: $clubId, PlayerName: $playerName, Subcollection: $subcollection');

      // Navigate based on normalized subcollection
      switch (subcollection) {
        case 'firstteamclassplayers': // Ensure lowercase match
          print('Navigating to FirstTeamClassPlayer details...');
          // _handleFirstTeamClassNotification(context, clubId, playerName);
          break;

        case 'secondteamclassplayers': // Ensure lowercase match
          print('Navigating to SecondTeamClassPlayer details...');
          // _handleSecondTeamClassNotification(context, clubId, playerName);
          break;

        default:
          print('Unhandled subcollection: $subcollection');
        // _showUnhandledNotificationDialog(context);
      }
    }
  }

  static void _handleFirstTeamClassNotification(BuildContext context, String clubId, String playerName) async {
    try {
      print('Fetching FirstTeamClassPlayers for ClubId: $clubId...');
      final firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);

      // Ensure the list is loaded before searching
      if (firstTeamClassNotifier.firstTeamClassList.isEmpty) {
        print('FirstTeamClass list is empty. Fetching from API...');
        await getFirstTeamClass(firstTeamClassNotifier, clubId);
      } else {
        print('FirstTeamClass list already loaded.');
      }

      // Find the player
      print('Searching for player: $playerName...');
      final player = firstTeamClassNotifier.firstTeamClassList.firstWhere(
        (p) => p.name?.toLowerCase() == playerName.toLowerCase(),
        orElse: () => throw Exception('Player not found'),
      );

      print('Player found: ${player.name}');
      firstTeamClassNotifier.currentFirstTeamClass = player;

      // Navigate to details page
      print('Navigating to details page for player: ${player.name}');
      Navigator.push(context, MaterialPageRoute(builder: (context) => SubPage(clubId: clubId)));
    } catch (e) {
      print('Error: ${e.toString()}');
      _showPlayerNotFoundDialog(context, playerName);
    }
  }

  static void _handleSecondTeamClassNotification(BuildContext context, String clubId, String playerName) async {
    try {
      print('Fetching SecondTeamClassPlayers for ClubId: $clubId...');
      final secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);

      // Ensure the list is loaded before searching
      if (secondTeamClassNotifier.secondTeamClassList.isEmpty) {
        print('SecondTeamClass list is empty. Fetching from API...');
        await getSecondTeamClass(secondTeamClassNotifier, clubId);
      } else {
        print('SecondTeamClass list already loaded.');
      }

      // Find the player
      print('Searching for player: $playerName...');
      final player = secondTeamClassNotifier.secondTeamClassList.firstWhere(
        (p) => p.name?.toLowerCase() == playerName.toLowerCase(),
        orElse: () => throw Exception('Player not found'),
      );

      print('Player found: ${player.name}');
      secondTeamClassNotifier.currentSecondTeamClass = player;

      // Navigate to details page
      print('Navigating to details page for player: ${player.name}');
      Navigator.push(context, MaterialPageRoute(builder: (context) => SecondTeamClassDetailsPage(clubId: clubId)));
    } catch (e) {
      print('Error: ${e.toString()}');
      _showPlayerNotFoundDialog(context, playerName);
    }
  }

  // Added error dialog for better user experience
  static void _showPlayerNotFoundDialog(BuildContext context, String playerName) {
    print('Showing "Player Not Found" dialog for player: $playerName');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Player Not Found'),
        content: Text('Could not find player: $playerName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
