import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc_navigation_bloc/navigation_bloc.dart';
import '../dummy_pages/dummy_sidebar.dart';
import '../notifier/sidebar_notifier.dart';

class SideBarLayout extends StatelessWidget {
  final String clubId; // Add this line

  // const SideBarLayout({super.key});
  const SideBarLayout({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) {
    SideBarNotifier sideBarNotifier = Provider.of<SideBarNotifier>(context);
    return Scaffold(
      body: BlocProvider<NavigationBloc>(
        create: (context) => NavigationBloc(clubId: clubId),
        child: Stack(
          children: <Widget>[
            IgnorePointer(
              ignoring: !sideBarNotifier.isOpened,
              child: BlocBuilder<NavigationBloc, NavigationStates>(
                builder: (context, navigationState) {
                  return navigationState as Widget;
                },
              ),
            ),
            // const SideBar(
            //   clubId: '',
            // ), // Pass clubId here
            SideBar(clubId: clubId), // Pass clubId here
          ],
        ),
      ),
    );
  }
}
