import 'package:flutter/material.dart';

class FTClassOkayDialogButtonPressedNotifier extends ChangeNotifier {
  bool _isOkayDialogButtonPressed = false;

  bool get isOkayDialogButtonPressed => _isOkayDialogButtonPressed;

  void setOkayPressed(bool value) {
    _isOkayDialogButtonPressed = value;
    notifyListeners(); // Notify listeners when the value changes
  }
}
