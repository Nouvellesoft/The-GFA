import 'package:flutter/material.dart';

class ClubDetailPage extends StatelessWidget {
  final String clubId;

  const ClubDetailPage({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details for $clubId')),
      body: Center(
        child: Text('Details for club: $clubId'),
      ),
    );
  }
}
