import 'package:flutter/material.dart';

class ClubGlobalProvider extends ChangeNotifier {
  String _clubName = '';
  String _clubLogo = '';
  String _clubIcon = '';

  String get clubName => _clubName;
  String get clubLogo => _clubLogo;
  String get clubIcon => _clubIcon;

  void setClubName(String name) {
    _clubName = name;
    notifyListeners();
  }

  void setClubLogo(String logo) {
    _clubLogo = logo;
    notifyListeners();
  }

  void setClubIcon(String icon) {
    _clubIcon = icon;
    notifyListeners();
  }

}
