import 'package:flutter/material.dart';

class ClubGlobalProvider extends ChangeNotifier {
  String _clubName = '';
  String _clubLogo = '';
  String _clubIcon = '';
  String _clubYID = '';

  String get clubName => _clubName;
  String get clubLogo => _clubLogo;
  String get clubIcon => _clubIcon;
  String get clubYID => _clubYID;

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

void setClubYID(String yid) {
    _clubYID = yid;
    notifyListeners();
  }

}
