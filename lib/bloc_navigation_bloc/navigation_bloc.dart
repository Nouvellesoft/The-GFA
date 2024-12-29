import 'package:flutter_bloc/flutter_bloc.dart';

import '/bottom_nav_stats_pages/social_media/b_youtube_page.dart';
import '../thrown_pages/captains_thrown_page.dart';
import '../thrown_pages/chatgfa/chatgfa_thrown_page.dart';
import '../thrown_pages/club_sponsors/club_sponsors_thrown_page.dart';
import '../thrown_pages/coaches_thrown_page.dart';
import '../thrown_pages/fifth_team_thrown_page.dart';
import '../thrown_pages/first_team_thrown_page.dart';
import '../thrown_pages/fourth_team_thrown_page.dart';
import '../thrown_pages/management_thrown_page.dart';
import '../thrown_pages/second_team_thrown_page.dart';
import '../thrown_pages/sixth_team_thrown_page.dart';
import '../thrown_pages/third_team_thrown_page.dart';

enum NavigationEvents {
  myFirstTeamClassPageClickedEvent,
  mySecondTeamClassPageClickedEvent,
  myThirdTeamClassPageClickedEvent,
  myFourthTeamClassPageClickedEvent,
  myFifthTeamClassPageClickedEvent,
  mySixthTeamClassPageClickedEvent,
  myCoachesPageClickedEvent,
  myManagementBodyPageClickedEvent,
  myCaptainsPageClickedEvent,
  myChatGFAPageClickedEvent,
  myClubSponsorsPageClickedEvent,
  myYouTubePageClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  final String clubId;

  NavigationBloc({required this.clubId}) : super(MyFirstTeamClassPage(clubId: clubId));

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.myFirstTeamClassPageClickedEvent:
        yield MyFirstTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.mySecondTeamClassPageClickedEvent:
        yield MySecondTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.myThirdTeamClassPageClickedEvent:
        yield MyThirdTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.myFourthTeamClassPageClickedEvent:
        yield MyFourthTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.myFifthTeamClassPageClickedEvent:
        yield MyFifthTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.mySixthTeamClassPageClickedEvent:
        yield MySixthTeamClassPage(clubId: clubId);
        break;
      case NavigationEvents.myCoachesPageClickedEvent:
        yield MyCoachesPage(clubId: clubId);
        break;
      case NavigationEvents.myManagementBodyPageClickedEvent:
        yield MyManagementBodyPage(clubId: clubId);
        break;
      case NavigationEvents.myCaptainsPageClickedEvent:
        yield MyCaptainsPage(clubId: clubId);
        break;
      case NavigationEvents.myChatGFAPageClickedEvent:
        yield MyChatGFAPage(clubId: clubId);
        break;
      case NavigationEvents.myClubSponsorsPageClickedEvent:
        yield MyClubSponsorsPage(fromPage1: false, clubId: clubId);
        break;
      case NavigationEvents.myYouTubePageClickedEvent:
        yield MyYouTubePage(clubId: clubId);
        break;
    }
  }
}
