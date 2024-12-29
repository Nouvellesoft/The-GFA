import 'package:flutter/material.dart';

class MyAppColors {
  static final darkBlue = Color(0xFF1E1E2C);
  static final lightBlue = Color(0xFF2D2D44);
}

class MyAppThemes {
  static final lightTheme = ThemeData(
      useMaterial3: true,
      primaryColor: MyAppColors.lightBlue,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: MyAppColors.lightBlue,
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      canvasColor: Colors.green,
      fontFamily: 'Roboto',
      cardColor: Colors.grey[250],
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.deepPurple,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey[900],
        textStyle: TextStyle(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
          primary: Colors.grey[400]!,
          // onPrimary: Colors.white,
          // onPrimaryFixedVariant: Colors.black,
          secondary: Colors.grey[300]!,
          // onSecondary: Colors.white,
          // onSecondaryFixedVariant: Colors.white,
          surface: Colors.white,
          // onSurface: Colors.black,
          // background: Colors.white,
          // onBackground: Colors.black,
          error: Colors.red,
          onError: Colors.white));

  static final darkTheme = ThemeData(
      useMaterial3: true,
      primaryColor: MyAppColors.darkBlue,
      brightness: Brightness.dark,
      canvasColor: Colors.green,
      fontFamily: 'Roboto',
      cardColor: Colors.grey[850],
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.deepPurple,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey[900],
        textStyle: TextStyle(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
          primary: Colors.grey[900]!,
          // onPrimary: Colors.white,
          // onPrimaryFixedVariant: Colors.black,
          secondary: Colors.grey[800]!,
          // onSecondary: Colors.white,
          // onSecondaryFixedVariant: Colors.white,
          surface: Colors.black,
          // onSurface: Colors.black,
          // background: Colors.white,
          // onBackground: Colors.black,
          error: Colors.red,
          onError: Colors.white));
}
