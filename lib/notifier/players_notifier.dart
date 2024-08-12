import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/fifth_team_class_model.dart';
import '../model/first_team_class_model.dart';
import '../model/fourth_team_class_model.dart';
import '../model/second_team_class_model.dart';
import '../model/sixth_team_class_model.dart';
import '../model/third_team_class_model.dart';

class PlayersNotifier with ChangeNotifier {
  List<FirstTeamClass> _firstTeamClassList = [];
  List<SecondTeamClass> _secondTeamClassList = [];
  List<ThirdTeamClass> _thirdTeamClassList = [];
  List<FourthTeamClass> _fourthTeamClassList = [];
  List<FifthTeamClass> _fifthTeamClassList = [];
  List<SixthTeamClass> _sixthTeamClassList = [];

  UnmodifiableListView<FirstTeamClass> get firstTeamClassList => UnmodifiableListView(_firstTeamClassList);

  UnmodifiableListView<SecondTeamClass> get secondTeamClassList => UnmodifiableListView(_secondTeamClassList);

  UnmodifiableListView<ThirdTeamClass> get thirdTeamClassList => UnmodifiableListView(_thirdTeamClassList);

  UnmodifiableListView<FourthTeamClass> get fourthTeamClassList => UnmodifiableListView(_fourthTeamClassList);

  UnmodifiableListView<FifthTeamClass> get fifthTeamClassList => UnmodifiableListView(_fifthTeamClassList);

  UnmodifiableListView<SixthTeamClass> get sixthTeamClassList => UnmodifiableListView(_sixthTeamClassList);

  // StreamController and Stream for players
  final _playersController = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get playersStream => _playersController.stream;

  // Method to set data for first team players
  void setFirstTeamPlayers(List<FirstTeamClass> players) {
    _firstTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Method to set data for second team players
  void setSecondTeamPlayers(List<SecondTeamClass> players) {
    _secondTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Method to set data for third team players
  void setThirdTeamPlayers(List<ThirdTeamClass> players) {
    _thirdTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Method to set data for fourth team players
  void setFourthTeamPlayers(List<FourthTeamClass> players) {
    _fourthTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Method to set data for fifth team players
  void setFifthTeamPlayers(List<FifthTeamClass> players) {
    _fifthTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Method to set data for sixth team players
  void setSixthTeamPlayers(List<SixthTeamClass> players) {
    _sixthTeamClassList = players;
    notifyListeners();
    _updatePlayers();
  }

  // Add a private method to update the players stream
  void _updatePlayers() {
    final playersList = [
      ..._firstTeamClassList,
      ..._secondTeamClassList,
      ..._thirdTeamClassList,
      ..._fourthTeamClassList,
      ..._fifthTeamClassList,
      ..._sixthTeamClassList
    ];
    _playersController.add(playersList);
  }

  // Getter for all players
  List<dynamic> get playersList => [
        ..._firstTeamClassList,
        ..._secondTeamClassList,
        ..._thirdTeamClassList,
        ..._fourthTeamClassList,
        ..._fifthTeamClassList,
        ..._sixthTeamClassList
      ];
}
