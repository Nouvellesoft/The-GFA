import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/coaches.dart';
import '../model/first_team_class.dart';
import '../model/management_body.dart';
import '../model/second_team_class.dart';

class AllClubMembersNotifier with ChangeNotifier {
  List<FirstTeamClass> _firstTeamClassList = [];
  List<SecondTeamClass> _secondTeamClassList = [];
  List<Coaches> _coachesClassList = [];
  List<ManagementBody> _mgmtBodyClassList = [];

  UnmodifiableListView<FirstTeamClass> get firstTeamClassList => UnmodifiableListView(_firstTeamClassList);

  UnmodifiableListView<SecondTeamClass> get secondTeamClassList => UnmodifiableListView(_secondTeamClassList);

  UnmodifiableListView<Coaches> get coachesClassList => UnmodifiableListView(_coachesClassList);

  UnmodifiableListView<ManagementBody> get mgmtBodyClassList => UnmodifiableListView(_mgmtBodyClassList);

  // StreamController and Stream for allClubMembers
  final _allClubMembersController = StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get allClubMembersStream => _allClubMembersController.stream;

  // Method to set data for first team
  void setFirstTeamMembers(List<FirstTeamClass> members) {
    _firstTeamClassList = members;
    _updateAllClubMembers();
  }

  // Method to set data for second team
  void setSecondTeamMembers(List<SecondTeamClass> members) {
    _secondTeamClassList = members;
    _updateAllClubMembers();
  }

  // Method to set data for coaches
  void setCoachesList(List<Coaches> coaches) {
    _coachesClassList = coaches;
    _updateAllClubMembers();
  }

  // Method to set data for management body
  void setMGMTBodyList(List<ManagementBody> mgmtBody) {
    _mgmtBodyClassList = mgmtBody;
    _updateAllClubMembers();
  }

  // Private method to update the allClubMembers stream
  void _updateAllClubMembers() {
    final allClubMembersList = [..._firstTeamClassList, ..._secondTeamClassList, ..._coachesClassList, ..._mgmtBodyClassList];
    _allClubMembersController.add(allClubMembersList);
    notifyListeners(); // Ensure UI updates are triggered
  }

  @override
  void dispose() {
    _allClubMembersController.close();
    super.dispose();
  }

  // Getter for all club members
  List<dynamic> get allClubMembersList => [..._firstTeamClassList, ..._secondTeamClassList, ..._coachesClassList, ..._mgmtBodyClassList];
}
