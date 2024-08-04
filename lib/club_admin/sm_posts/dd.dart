// import 'dart:async';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:giffy_dialog/giffy_dialog.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:toast/toast.dart';
//
// import '/details_pages/second_team_details_page.dart';
// import '/notifier/second_team_class_notifier.dart';
// import '../../details_pages/first_team_details_page.dart';
// import '../../notifier/first_team_class_notifier.dart';
//
// Color conColor = const Color.fromRGBO(34, 40, 49, 1);
// Color? backgroundColor = const Color.fromRGBO(34, 40, 49, 1);
// Color? cardBackgroundColorTwo = const Color.fromRGBO(34, 40, 49, 0.6);
// Color? cardBackgroundColor = const Color.fromRGBO(57, 62, 70, 1);
// Color? goalsScoredTextColor = const Color.fromRGBO(255, 141, 41, 1);
// Color? appBarIconColor = const Color.fromRGBO(255, 141, 41, 1);
// Color? appBarBackgroundColor = const Color.fromRGBO(34, 40, 49, 1);
//
// String lottieTrainingSoccerTitle = "assets/json/training_soccer.json";
// String lottieTrialSoccerTitle = "assets/json/trial_soccer.json";
//
// // final List<PlayersTable> playersTableList = [];
//
// FirstTeamClassNotifier? firstTeamClassNotifier;
// SecondTeamClassNotifier? secondTeamClassNotifier;
//
// class PlayersTablePage extends StatefulWidget {
//   final String clubId;
//
//   const PlayersTablePage({super.key, required this.clubId});
//
//   @override
//   State<PlayersTablePage> createState() => PlayersTablePageState();
// }
//
// class PlayersTablePageState extends State<PlayersTablePage> {
//   List<PlayersTable> playersTableList = [];
//
//   late PlayersTableDataSource playersTableDataSource;
//
//   Stream<QuerySnapshot> getDataFromFirestore(String clubId) {
//     return FirebaseFirestore.instance
//         .collection('clubs')
//         .doc(clubId)
//         .collection('PllayersTable')
//         .orderBy('goals_scored', descending: true)
//         .snapshots();
//   }
//
//   Widget _buildDataGrid() {
//     firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
//     secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);
//     return StreamBuilder(
//         stream: getDataFromFirestore(widget.clubId),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasData) {
//             if (playersTableList.isNotEmpty && !snapshot.data!.metadata.isFromCache) {
//               realTimeUpdate(var data) {
//                 return DataGridRow(cells: [
//                   DataGridCell<String>(columnName: 'id', value: data.doc['id']),
//                   DataGridCell<String>(columnName: 'image', value: data.doc['image']),
//                   DataGridCell<String>(columnName: 'player_name', value: data.doc['player_name']),
//                   DataGridCell<int>(columnName: 'matches_played', value: data.doc['matches_played']),
//                   DataGridCell<int>(columnName: 'matches_started', value: data.doc['matches_started']),
//                   DataGridCell<int>(columnName: 'matches_benched', value: data.doc['matches_benched']),
//                   DataGridCell<int>(columnName: 'goals_scored', value: data.doc['goals_scored']),
//                   DataGridCell<int>(columnName: 'assists', value: data.doc['assists']),
//                   DataGridCell<int>(columnName: 'yellow_card', value: data.doc['yellow_card']),
//                   DataGridCell<int>(columnName: 'red_card', value: data.doc['red_card']),
//                   DataGridCell<String>(columnName: 'player_position', value: data.doc['player_position']),
//                   DataGridCell<String>(columnName: 'nationality', value: data.doc['nationality']),
//                 ]);
//               }
//
//               for (var data in snapshot.data!.docChanges) {
//                 if (data.type == DocumentChangeType.modified) {
//                   playersTableDataSource.dataGridRows[data.oldIndex] = realTimeUpdate(data);
//                   playersTableDataSource.updateDataGridSource();
//                 } else if (data.type == DocumentChangeType.added) {
//                   playersTableDataSource.dataGridRows.add(realTimeUpdate(data));
//                   playersTableDataSource.updateDataGridSource();
//                 } else if (data.type == DocumentChangeType.removed) {
//                   playersTableDataSource.dataGridRows.removeAt(data.oldIndex);
//                   playersTableDataSource.updateDataGridSource();
//                 }
//               }
//             } else if (playersTableList.isEmpty) {
//               for (var data in snapshot.data!.docs) {
//                 playersTableList.add(PlayersTable(
//                     id: data['id'],
//                     image: data['image'],
//                     playerName: data['player_name'],
//                     matchesPlayed: data['matches_played'],
//                     matchesStarted: data['matches_started'],
//                     matchesBenched: data['matches_benched'],
//                     goalsScored: data['goals_scored'],
//                     assists: data['assists'],
//                     playerPosition: data['player_position'],
//                     yellowCard: data['yellow_card'],
//                     redCard: data['red_card'],
//                     nationality: data['nationality']));
//               }
//               playersTableDataSource = PlayersTableDataSource(playersTableList);
//             }
//
//             return SizedBox(
//               height: 700,
//               child: Material(
//                 color: cardBackgroundColorTwo,
//                 child: SfDataGridTheme(
//                   data: SfDataGridThemeData(
//                       // sortIcon: const Icon(Icons.arrow_circle_up),
//                       sortIconColor: Colors.white,
//                       headerColor: cardBackgroundColorTwo,
//                       gridLineColor: backgroundColor,
//                       gridLineStrokeWidth: 1.0),
//                   child: SfDataGrid(
//                     rowHeight: 50,
//                     source: playersTableDataSource,
//                     onCellTap: (details) {
//                       if (details.column.columnName == 'player_name' && details.rowColumnIndex.rowIndex > 0) {
//                         DataGridRow row = playersTableDataSource.effectiveRows.elementAt(details.rowColumnIndex.rowIndex - 1);
//
//                         String playerName = row.getCells().firstWhere((element) => element.columnName == 'player_name').value.toString();
//
//                         var firstTeamPlayer = firstTeamClassNotifier?.firstTeamClassList.firstWhereOrNull((element) => element.name == playerName);
//
//                         var secondTeamPlayer = secondTeamClassNotifier?.secondTeamClassList.firstWhereOrNull((element) => element.name == playerName);
//
//                         if (firstTeamPlayer != null) {
//                           firstTeamClassNotifier?.currentFirstTeamClass = firstTeamPlayer;
//                           navigateToSubPage(context, widget.clubId);
//
//                           Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                         } else if (secondTeamPlayer != null) {
//                           secondTeamClassNotifier?.currentSecondTeamClass = secondTeamPlayer;
//                           navigateToSecondTeamClassDetailsPage(context, widget.clubId);
//
//                           Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                         } else {
//                           Toast.show("We can't find $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                         }
//                       }
//                     },
//                     frozenColumnsCount: 3,
//                     frozenRowsCount: 0,
//                     allowSorting: true,
//                     allowTriStateSorting: true,
//                     // allowMultiColumnSorting: true,
//                     columnWidthMode: ColumnWidthMode.fill,
//                     tableSummaryRows: [
//                       GridTableSummaryRow(
//                           color: cardBackgroundColorTwo,
//                           showSummaryInRow: true,
//                           title: '{Goals} Goals and {Ass} Assists by {Count} players so far.',
//                           columns: [
//                             const GridSummaryColumn(name: 'Goals', columnName: 'goals_scored', summaryType: GridSummaryType.sum),
//                             const GridSummaryColumn(name: 'Ass', columnName: 'assists', summaryType: GridSummaryType.sum),
//                             const GridSummaryColumn(name: 'Count', columnName: 'id', summaryType: GridSummaryType.count),
//                           ],
//                           position: GridTableSummaryRowPosition.bottom)
//                     ],
//                     columns: getColumns,
//                   ),
//                 ),
//               ),
//             );
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         });
//   }
//
//   @override
//   void initState() {
//     // getDataFromFirestore();
//     // if (playersTableList.isEmpty) {
//     playersTableDataSource = PlayersTableDataSource(playersTableList);
//     playersTableDataSource.sortedColumns.add(const SortColumnDetails(name: 'goals_scored', sortDirection: DataGridSortDirection.descending));
//     // }
//
//     super.initState();
//
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//
//     // final useMaterial3 = Theme.of(context).useMaterial3;
//     // final borderRadius = useMaterial3 ? const BorderRadius.all(Radius.circular(16)) : const BorderRadius.all(Radius.circular(4));
//
//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) async {
//         if (!didPop) {
//           // return false;
//           Navigator.of(context).pop();
//         }
//         await _onWillPop();
//       },
//       canPop: true, // Allow the pop action
//       child: Scaffold(
//         backgroundColor: backgroundColor,
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               color: cardBackgroundColor,
//               child: _buildDataGrid()),
//         ),
//       ),
//     );
//   }
//
//   Future navigateMyApp(context) async {
//     Navigator.of(context).pop(false);
//   }
//
//   Future<bool> _onWillPop() {
//     Navigator.of(context).pop(false);
//     return Future.value(true);
//   }
// }
//
// class PlayersTableDataSource extends DataGridSource {
//   PlayersTableDataSource(this.playersTableList) {
//     sort();
//     _buildDataRow();
//   }
//
//   List<PlayersTable> playersTableList = [];
//
//   List<DataGridRow> dataGridRows = <DataGridRow>[];
//
//   @override
//   List<DataGridRow> get rows => dataGridRows.isEmpty ? [] : dataGridRows;
//
//   /// Creates the playersTable data source class with required page..
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     final clubId = widget.clubId; // Store clubId in a local variable
//
//     return DataGridRowAdapter(
//         color: cardBackgroundColor,
//         cells: row.getCells().map<Widget>((e) {
//           TextStyle getTextStyle() {
//             if (e.columnName == 'goals_scored') {
//               return TextStyle(color: goalsScoredTextColor, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
//             }
//             if (e.columnName == 'player_name') {
//               return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.normal);
//             } else if (e.columnName == 'nationality') {
//               return const TextStyle(color: Colors.white, fontStyle: FontStyle.italic);
//             } else {
//               return const TextStyle(color: Colors.white);
//             }
//           }
//
//           return e.columnName == 'image'
//               ? Builder(builder: (context) {
//                   FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context);
//                   SecondTeamClassNotifier secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context);
//                   return GestureDetector(
//                     onTap: () {
//                       /// DG to PP
//                       String playerName = row.getCells().firstWhere((element) => element.columnName == 'player_name').value.toString();
//
//                       var firstTeamPlayer = firstTeamClassNotifier.firstTeamClassList.firstWhereOrNull((element) => element.name == playerName);
//
//                       var secondTeamPlayer = secondTeamClassNotifier.secondTeamClassList.firstWhereOrNull((element) => element.name == playerName);
//
//                       if (firstTeamPlayer != null) {
//                         firstTeamClassNotifier.currentFirstTeamClass = firstTeamPlayer;
//                         navigateToSubPage(context, clubId); // Use local variable
//
//                         Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                       } else if (secondTeamPlayer != null) {
//                         secondTeamClassNotifier.currentSecondTeamClass = secondTeamPlayer;
//                         navigateToSecondTeamClassDetailsPage(context, clubId); // Use local variable
//
//                         Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                       } else {
//                         Toast.show("We can't find $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
//                       }
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.all(2),
//                       alignment: Alignment.center,
//                       // width: 25,
//                       // height: 25,
//                       decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           shape: BoxShape.circle,
//                           // borderRadius: const BorderRadius.all(Radius.circular(15)),
//                           image: DecorationImage(
//                               alignment: const Alignment(-1, -1.1),
//                               image: CachedNetworkImageProvider(
//                                 e.value,
//                               ),
//                               fit: BoxFit.cover)),
//                     ),
//                   );
//                 })
//               : e.columnName == 'player_name'
//                   ? Container(
//                       alignment: Alignment.centerLeft,
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         e.value.toString(),
//                         style: getTextStyle(),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     )
//                   : Container(
//                       alignment: (e.columnName == 'id') ? Alignment.center : Alignment.centerLeft,
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         e.value.toString(),
//                         style: getTextStyle(),
//                         overflow: TextOverflow.fade,
//                       ),
//                     );
//         }).toList());
//   }
//
//   void updateDataGridSource() {
//     notifyListeners();
//   }
// }
//
// Future navigateToSubPage(context, String clubId) async {
//   Navigator.push(context, MaterialPageRoute(builder: (context) => SubPage(clubId: clubId)));
// }
//
// Future navigateToSecondTeamClassDetailsPage(context, String clubId) async {
//   Navigator.push(context, MaterialPageRoute(builder: (context) => SecondTeamClassDetailsPage(clubId: clubId)));
// }
