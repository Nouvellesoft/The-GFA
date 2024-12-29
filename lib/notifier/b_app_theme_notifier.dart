import 'package:flutter/material.dart';

import '../app_colors_and_themes/colors_themes_colors.dart';

class AppThemeProvider extends ChangeNotifier {
  ThemeData _themeDataStyle = MyAppThemes.lightTheme;

  ThemeData get themeDataStyle => _themeDataStyle;

  set themeDataStyle(ThemeData themeData) {
    _themeDataStyle = themeData;
    notifyListeners();
  }

  void changeTheme() {
    if (_themeDataStyle == MyAppThemes.lightTheme) {
      themeDataStyle = MyAppThemes.darkTheme;
    } else {
      themeDataStyle = MyAppThemes.lightTheme;
    }
  }
}
