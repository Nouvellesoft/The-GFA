import 'package:flutter/material.dart';

import '../../bloc_navigation_bloc/navigation_bloc.dart';

class CreateAnnouncementSMPost extends StatefulWidget implements NavigationStates {
  final String clubId;
  const CreateAnnouncementSMPost({super.key, required this.clubId});

  @override
  State<CreateAnnouncementSMPost> createState() => _CreateAnnouncementSMPostState();
}

class _CreateAnnouncementSMPostState extends State<CreateAnnouncementSMPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
