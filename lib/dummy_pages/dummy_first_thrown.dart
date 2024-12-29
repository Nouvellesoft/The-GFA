// import 'package:flutter/material.dart';
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({required Key key, required this.title}) : super(key: key);
//   final String title;
//
//   @override
//   MyHomePageState createState() => MyHomePageState();
// }
//
// class MyHomePageState extends State<MyHomePage> {
//   ThemeMode _themeMode = ThemeMode.system;
//
//   void _toggleTheme(ThemeMode themeMode) {
//     setState(() {
//       _themeMode = themeMode;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: <Widget>[
//           Switch(
//             value: isDarkMode,
//             onChanged: (isOn) {
//               isOn ? _toggleTheme(ThemeMode.dark) : _toggleTheme(ThemeMode.light);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
