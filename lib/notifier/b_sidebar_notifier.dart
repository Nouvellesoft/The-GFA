import 'package:flutter/material.dart';

class SideBarNotifier with ChangeNotifier {
  bool isOpened = false;

  setIsOpened(bool value) {
    isOpened = value;
    notifyListeners();
  }
}
