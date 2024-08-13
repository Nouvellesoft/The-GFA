import 'package:flutter/material.dart';

class ClubGlobalProvider extends ChangeNotifier {
  String _clubName = '';

  String get clubName => _clubName;

  void setClubName(String name) {
    _clubName = name;
    notifyListeners();
  }
}
