import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:toast/toast.dart';

import '/details_pages/second_team_details_page.dart';
import '/notifier/second_team_class_notifier.dart';
import '../api/get_club_aspect_visibility_api.dart';
import '../api/players_table_api.dart';
import '../club_admin/others/view_club_population_page.dart';
import '../details_pages/fifth_team_details_page.dart';
import '../details_pages/first_team_details_page.dart';
import '../details_pages/fourth_team_details_page.dart';
import '../details_pages/sixth_team_details_page.dart';
import '../details_pages/third_team_details_page.dart';
import '../model/players_table_model.dart';
import '../notifier/fifth_team_class_notifier.dart';
import '../notifier/first_team_class_notifier.dart';
import '../notifier/fourth_team_class_notifier.dart';
import '../notifier/players_table_notifier.dart';
import '../notifier/sixth_team_class_notifier.dart';
import '../notifier/third_team_class_notifier.dart';

Color conColor = const Color.fromRGBO(34, 40, 49, 1);
Color? backgroundColor = const Color.fromRGBO(34, 40, 49, 1);
Color? cardBackgroundColorTwo = const Color.fromRGBO(34, 40, 49, 0.6);
Color? cardBackgroundColor = const Color.fromRGBO(57, 62, 70, 1);
Color? goalsScoredTextColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarIconColor = const Color.fromRGBO(255, 141, 41, 1);
Color? appBarBackgroundColor = const Color.fromRGBO(34, 40, 49, 1);

String lottieTrainingSoccerTitle = "assets/json/training_soccer.json";
String lottieTrialSoccerTitle = "assets/json/trial_soccer.json";

FirstTeamClassNotifier? firstTeamClassNotifier;
SecondTeamClassNotifier? secondTeamClassNotifier;
ThirdTeamClassNotifier? thirdTeamClassNotifier;
FourthTeamClassNotifier? fourthTeamClassNotifier;
FifthTeamClassNotifier? fifthTeamClassNotifier;
SixthTeamClassNotifier? sixthTeamClassNotifier;

class PlayersTablePage extends StatefulWidget {
  final String clubId;

  const PlayersTablePage({super.key, required this.clubId});

  @override
  State<PlayersTablePage> createState() => PlayersTablePageState();
}

class PlayersTablePageState extends State<PlayersTablePage> {
  List<PlayersTable> playersTableList = [];
  late PlayersTableDataSource playersTableDataSource;
  Map<String, Map<String, dynamic>> aspectVisibilitySettings = {};

  // Stream<QuerySnapshot> getDataFromFirestore(String clubId) {
  //   return FirebaseFirestore.instance
  //       .collection('clubs')
  //       .doc(clubId)
  //       .collection('PllayersTable')
  //       .orderBy('goals_scored', descending: true)
  //       .snapshots();
  // }

  Widget _buildDataGrid() {
    firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context, listen: false);
    secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context, listen: false);
    thirdTeamClassNotifier = Provider.of<ThirdTeamClassNotifier>(context, listen: false);
    fourthTeamClassNotifier = Provider.of<FourthTeamClassNotifier>(context, listen: false);
    fifthTeamClassNotifier = Provider.of<FifthTeamClassNotifier>(context, listen: false);
    sixthTeamClassNotifier = Provider.of<SixthTeamClassNotifier>(context, listen: false);

    return FutureBuilder<List<PlayersTable>>(
      future: fetchPlayersTable(),
      builder: (BuildContext context, AsyncSnapshot<List<PlayersTable>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          playersTableList = snapshot.data!;
          playersTableDataSource = PlayersTableDataSource(playersTableList, widget.clubId, aspectVisibilitySettings);

          return SizedBox(
            height: 700,
            child: Material(
              color: cardBackgroundColorTwo,
              child: SfDataGridTheme(
                data: SfDataGridThemeData(
                    sortIconColor: Colors.white, headerColor: cardBackgroundColorTwo, gridLineColor: backgroundColor, gridLineStrokeWidth: 1.0),
                child: SfDataGrid(
                  rowHeight: 50,
                  source: playersTableDataSource,
                  onCellTap: (details) {
                    if (details.column.columnName == 'player_name' && details.rowColumnIndex.rowIndex > 0) {
                      DataGridRow row = playersTableDataSource.effectiveRows.elementAt(details.rowColumnIndex.rowIndex - 1);

                      String playerName = row.getCells().firstWhere((element) => element.columnName == 'player_name').value.toString();

                      var firstTeamPlayer = firstTeamClassNotifier?.firstTeamClassList.firstWhereOrNull((element) => element.name == playerName);
                      var secondTeamPlayer = secondTeamClassNotifier?.secondTeamClassList.firstWhereOrNull((element) => element.name == playerName);
                      var thirdTeamPlayer = thirdTeamClassNotifier?.thirdTeamClassList.firstWhereOrNull((element) => element.name == playerName);
                      var fourthTeamPlayer = fourthTeamClassNotifier?.fourthTeamClassList.firstWhereOrNull((element) => element.name == playerName);
                      var fifthTeamPlayer = fifthTeamClassNotifier?.fifthTeamClassList.firstWhereOrNull((element) => element.name == playerName);
                      var sixthTeamPlayer = sixthTeamClassNotifier?.sixthTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      if (firstTeamPlayer != null) {
                        firstTeamClassNotifier?.currentFirstTeamClass = firstTeamPlayer;
                        navigateToSubPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (secondTeamPlayer != null) {
                        secondTeamClassNotifier?.currentSecondTeamClass = secondTeamPlayer;
                        navigateToSecondTeamClassDetailsPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (thirdTeamPlayer != null) {
                        thirdTeamClassNotifier?.currentThirdTeamClass = thirdTeamPlayer;
                        navigateToThirdTeamClassDetailsPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (fourthTeamPlayer != null) {
                        fourthTeamClassNotifier?.currentFourthTeamClass = fourthTeamPlayer;
                        navigateToFourthTeamClassDetailsPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (fifthTeamPlayer != null) {
                        fifthTeamClassNotifier?.currentFifthTeamClass = fifthTeamPlayer;
                        navigateToFifthTeamClassDetailsPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (sixthTeamPlayer != null) {
                        sixthTeamClassNotifier?.currentSixthTeamClass = sixthTeamPlayer;
                        navigateToSixthTeamClassDetailsPage(context, widget.clubId);
                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else {
                        Toast.show("We can't find $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      }
                    }
                  },
                  frozenColumnsCount: 3,
                  frozenRowsCount: 0,
                  allowSorting: true,
                  allowTriStateSorting: true,
                  columnWidthMode: ColumnWidthMode.fill,
                  tableSummaryRows: [
                    GridTableSummaryRow(
                        color: cardBackgroundColorTwo,
                        showSummaryInRow: true,
                        title: _buildSummaryTitle(),
                        columns: [
                          const GridSummaryColumn(name: 'Goals', columnName: 'goals_scored', summaryType: GridSummaryType.sum),
                          const GridSummaryColumn(name: 'Ass', columnName: 'assists', summaryType: GridSummaryType.sum),
                          const GridSummaryColumn(name: 'Count', columnName: 'id', summaryType: GridSummaryType.count),
                        ],
                        position: GridTableSummaryRowPosition.bottom)
                  ],
                  columns: getColumns,
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('No data available'),
          );
        }
      },
    );
  }

  List<GridColumn> get getColumns {
    List<GridColumn> columns = <GridColumn>[
      GridColumn(
          columnName: 'id',
          width: 45,
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              // padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'ID',
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))),
      GridColumn(
          columnName: 'image',
          width: 70,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Image', style: TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis))),
      GridColumn(
          columnName: 'player_name',
          width: 120,
          label: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: const Text(
                'Player Name',
                softWrap: true,
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))),
    ];
    // Conditionally add columns based on visibility
    if (aspectVisibilitySettings['matches_played']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'matches_played',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(' MP', //'Matches Played',
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis))));
    }
    if (aspectVisibilitySettings['goals_scored']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'goals_scored',
          allowSorting: true,
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                ' GS', //'Goals Scored'
                style: TextStyle(color: goalsScoredTextColor, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ))));
    }
    if (aspectVisibilitySettings['assists']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'assists',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                ' A', //'Assists'
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))));
    }
    if (aspectVisibilitySettings['matches_started']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'matches_started',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(' MS', //'Matches Played',
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis))));
    }
    if (aspectVisibilitySettings['matches_benched']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'matches_benched',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(' MB', //'Matches Played',
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis))));
    }
    if (aspectVisibilitySettings['yellow_card']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'yellow_card',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'YC', //'Yellow\nCard'
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))));
    }
    if (aspectVisibilitySettings['red_card']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'red_card',
          width: 50,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'RC', //'Red\nCard'
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))));
    }
    if (aspectVisibilitySettings['player_position']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'player_position',
          width: 60,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                '  PP', //'Player Position'
                style: TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ))));
    }
    if (aspectVisibilitySettings['nationality']?['isVisible'] ?? true) {
      columns.add(GridColumn(
          columnName: 'nationality',
          width: 120,
          label: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Nationality',
                style: TextStyle(
                  color: Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
              ))));
    }
    return columns;
  }

  @override
  void initState() {
    super.initState();
    fetchVisibilitySettings().then((_) {
      fetchPlayersTable().then((_) {
        setState(() {
          playersTableDataSource = PlayersTableDataSource(playersTableList, widget.clubId, aspectVisibilitySettings);
          playersTableDataSource.sortedColumns.add(const SortColumnDetails(name: 'goals_scored', sortDirection: DataGridSortDirection.descending));
        });
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> fetchVisibilitySettings() async {
    aspectVisibilitySettings = await getClubAspectVisibilityAndTitles(widget.clubId);
  }

  Future<List<PlayersTable>> fetchPlayersTable() async {
    // Instantiate the PlayersTableNotifier
    PlayersTableNotifier playersTableNotifier = Provider.of<PlayersTableNotifier>(context, listen: false);

    // Fetch the players table using the provided API
    await getPlayersTable(playersTableNotifier, widget.clubId, orderByGoalsScored: true);

    return playersTableList = playersTableNotifier.playersTableList;
  }

  String _buildSummaryTitle() {
    bool isGoalsVisible = aspectVisibilitySettings['goals_scored']?['isVisible'] ?? false;
    bool isAssistsVisible = aspectVisibilitySettings['assists']?['isVisible'] ?? false;

    // Calculate total goals and assists from the data source
    int totalGoals = playersTableList.fold(0, (total, player) => total + (player.goalsScored ?? 0));
    int totalAssists = playersTableList.fold(0, (total, player) => total + (player.assists ?? 0));

    // Helper function to get singular or plural form
    String pluralize(String word, int count) => count == 1 ? word : '${word}s';

    // Determine title based on visibility and counts
    if (totalGoals == 0 && totalAssists == 0) {
      return '{Count} players in this Football Club';
    } else if (isGoalsVisible && isAssistsVisible) {
      if (totalAssists == 0) {
        return '$totalGoals ${pluralize('Goal', totalGoals)} by {Count} players so far.';
      } else {
        return '$totalGoals ${pluralize('Goal', totalGoals)} and $totalAssists ${pluralize('Assist', totalAssists)} by {Count} players so far.';
      }
    } else if (isGoalsVisible) {
      return '$totalGoals ${pluralize('Goal', totalGoals)} by {Count} players so far.';
    } else if (isAssistsVisible) {
      return '$totalAssists ${pluralize('Assist', totalAssists)} by {Count} players so far.';
    } else {
      return '{Count} players in this Football Club';
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // final useMaterial3 = Theme.of(context).useMaterial3;
    // final borderRadius = useMaterial3 ? const BorderRadius.all(Radius.circular(16)) : const BorderRadius.all(Radius.circular(4));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // return false;
          Navigator.of(context).pop();
        }
        await _onWillPop();
      },
      canPop: true, // Allow the pop action
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('AboutClub').doc('about_club_page').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data?.data()!['club_name'], style: TextStyle(color: appBarIconColor, fontSize: 17));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: appBarIconColor),
            onPressed: () {
              // Navigator.of(context).pop(false);
              navigateMyApp(context);
            },
          ),
          actions: [
            PopupMenuButton(
                color: const Color.fromRGBO(57, 62, 70, 1),
                icon: const Icon(
                  Icons.menu,
                  color: Color.fromRGBO(255, 141, 41, 1),
                ),
                itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text(
                          "View Club Population",
                          style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text(
                          "Legend",
                          style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text(
                          "Training Days",
                          style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 3,
                        child: Text(
                          "Trial Periods",
                          style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                        ),
                      ),
                    ],
                onSelected: (item) {
                  switch (item) {
                    case 0:
                      navigateToViewClubPopulation(context, widget.clubId);
                      break;
                    case 1:
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: const Color.fromRGBO(57, 62, 70, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Acronyms',
                                  style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.70,
                                child: const SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'A.P.T. - All Players Table',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'ID - Identification',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'MP - Matches Played',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'MS - Matches Started',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'MB - Matches Benched',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'GS - Goals Scored',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'A - Assists',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'YC - Yellow Cards',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'RC - Red Cards',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'PP - Players Positions',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'FC - Football Club',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'MOTM - Man Of The Match',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'POTM - Player Of The Match',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'CB - Center Back',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'LB - Left Back',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'RB - Right Back',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'GK - Goal Keeper',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'CM - Central Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'DM - Defensive Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'CDM - Central Defensive Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'LM - Left Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'RM - Right Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'AM - Attacking Midfielder',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'LW - Left Winger',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'RW - Right Winger',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'CF - Center Forward',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Goals Con. - Goals Conceded',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Okay'),
                                child: const Text(
                                  'Okay',
                                  style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      break;
                    case 2:
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: const Color.fromRGBO(57, 62, 70, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Lottie.asset(
                                  lottieTrainingSoccerTitle,
                                  height: 200,
                                  width: 250,
                                ),
                              ),
                              const Text(
                                'Training Days',
                                style: TextStyle(color: Colors.white70, fontSize: 25, fontWeight: FontWeight.w800),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                  width: width / 1.19,
                                  height: width / 1.6,
                                  decoration: BoxDecoration(
                                    color: conColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          TextSpan(
                                            text: 'Thursdays\n',
                                            style: GoogleFonts.aldrich(
                                              color: Colors.white70,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle, // Aligns the icon with the text
                                            child: Icon(Icons.loyalty, color: Colors.blueAccent, size: 14), // Your icon here
                                          ),
                                          TextSpan(
                                            text: ' At The Alan Higgs Centre, Allard Way, Coventry CV3 1HW [8pm - 10pm].',
                                            style: GoogleFonts.aldrich(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Okay'),
                                child: const Text(
                                  'Okay',
                                  style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      break;
                    case 3:
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: const Color.fromRGBO(57, 62, 70, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Lottie.asset(
                                  lottieTrialSoccerTitle,
                                  height: 200,
                                  width: 250,
                                ),
                              ),
                              const Text(
                                'Trial  Periods',
                                style: TextStyle(color: Colors.white70, fontSize: 25, fontWeight: FontWeight.w800),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                  width: width / 1.19,
                                  height: width / 1.6,
                                  decoration: BoxDecoration(
                                    color: conColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text.rich(
                                      textAlign: TextAlign.justify,
                                      TextSpan(
                                        children: <InlineSpan>[
                                          TextSpan(
                                              text: 'Monthly\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              )),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle, // Aligns the icon with the text
                                            child: Icon(MdiIcons.starFourPoints, color: Colors.blueAccent, size: 14), // Your icon here
                                          ),
                                          TextSpan(
                                              text: ' Every month we hold trials on Thursdays between 8pm-10pm.\n\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              )),
                                          TextSpan(
                                              text: 'Location\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              )),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle, // Aligns the icon with the text
                                            child: Icon(MdiIcons.starFourPoints, color: Colors.blueAccent, size: 14), // Your icon here
                                          ),
                                          TextSpan(
                                              text: ' At The Alan Higgs Centre, Allard Way, Coventry CV3 1HW.\n\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              )),
                                          TextSpan(
                                              text: 'Please Note\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              )),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle, // Aligns the icon with the text
                                            child: Icon(MdiIcons.starFourPoints, color: Colors.blueAccent, size: 14), // Your icon here
                                          ),
                                          TextSpan(
                                              text: ' Come on time, prepare to be tested and we wish you good luck.\n\n',
                                              style: GoogleFonts.aldrich(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Okay'),
                                child: const Text(
                                  'Okay',
                                  style: TextStyle(color: Color.fromRGBO(255, 141, 41, 1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      break;
                    default:
                      break;
                  }
                }),
          ],
          elevation: 10,
          backgroundColor: appBarBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 10,
              color: cardBackgroundColor,
              child: _buildDataGrid()),
        ),
      ),
    );
  }

  Future navigateMyApp(context) async {
    Navigator.of(context).pop(false);
  }

  Future<bool> _onWillPop() {
    Navigator.of(context).pop(false);
    return Future.value(true);
  }

  Future navigateToViewClubPopulation(BuildContext context, String clubId) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyViewClubPopulationPage(clubId: clubId)));
  }
}

class PlayersTableDataSource extends DataGridSource {
  final String clubId;
  List<PlayersTable> playersTableList = [];
  List<DataGridRow> dataGridRows = <DataGridRow>[];
  final Map<String, Map<String, dynamic>> aspectVisibilitySettings;

  PlayersTableDataSource(this.playersTableList, this.clubId, this.aspectVisibilitySettings) {
    _buildDataRow();
  }

  @override
  List<DataGridRow> get rows => dataGridRows.isEmpty ? [] : dataGridRows;

  /// Creates the playersTable data source class with required page..

  void _buildDataRow() {
    int itemCount = 1;

    dataGridRows = playersTableList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: itemCount++),
              DataGridCell<String>(columnName: 'image', value: e.image),
              DataGridCell<String>(columnName: 'player_name', value: e.playerName),
              if (aspectVisibilitySettings['matches_played']?['isVisible'] ?? true)
                DataGridCell<int>(columnName: 'matches_played', value: e.matchesPlayed),
              if (aspectVisibilitySettings['goals_scored']?['isVisible'] ?? true) DataGridCell<int>(columnName: 'goals_scored', value: e.goalsScored),
              if (aspectVisibilitySettings['assists']?['isVisible'] ?? true) DataGridCell<int>(columnName: 'assists', value: e.assists),
              if (aspectVisibilitySettings['matches_started']?['isVisible'] ?? true)
                DataGridCell<int>(columnName: 'matches_started', value: e.matchesStarted),
              if (aspectVisibilitySettings['matches_benched']?['isVisible'] ?? true)
                DataGridCell<int>(columnName: 'matches_benched', value: e.matchesBenched),
              if (aspectVisibilitySettings['yellow_card']?['isVisible'] ?? true) DataGridCell<int>(columnName: 'yellow_card', value: e.yellowCard),
              if (aspectVisibilitySettings['red_card']?['isVisible'] ?? true) DataGridCell<int>(columnName: 'red_card', value: e.redCard),
              if (aspectVisibilitySettings['player_position']?['isVisible'] ?? true)
                DataGridCell<String>(columnName: 'player_position', value: e.playerPosition),
              if (aspectVisibilitySettings['nationality']?['isVisible'] ?? true)
                DataGridCell<String>(columnName: 'nationality', value: e.nationality),
            ]))
        .toList();
  }

  @override
  Widget buildTableSummaryCellWidget(
      GridTableSummaryRow? summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex? rowColumnIndex, String? summaryValue) {
    // Define colors
    Color goalsColor = Colors.blue; // Customize as needed
    Color assistsColor = Colors.blue; // Customize as needed
    Color countColor = Colors.orange; // Color for {Count}
    Color numberColor = Colors.blue; // Color for numbers (e.g., 10, 56)
    Color restColor = Colors.white70; // Default color for other text

    if (summaryValue == null) return Container();

    // Create a widget for rich text
    TextSpan span = TextSpan(
      style: const TextStyle(fontWeight: FontWeight.bold),
      children: _buildTextSpans(summaryValue, goalsColor, assistsColor, countColor, numberColor, restColor),
    );

    return Container(
      padding: const EdgeInsets.all(15.0),
      child: RichText(
        text: span,
        textAlign: TextAlign.center, // Center the text inside the container
      ),
    );
  }

// Helper method to build text spans
  List<TextSpan> _buildTextSpans(String text, Color goalsColor, Color assistsColor, Color countColor, Color numberColor, Color restColor) {
    List<TextSpan> spans = [];
    final RegExp goalRegex = RegExp(r'(\d+ \bGoal\b(s)?|Goal(s)?)');
    final RegExp assistRegex = RegExp(r'(\d+ \bAssist\b(s)?|Assist(s)?)');
    final RegExp countRegex = RegExp(r'\{Count\}');
    final RegExp numberRegex = RegExp(r'\d+'); // Regex to match numbers

    int lastMatchEnd = 0;

    // Use a combined regex to find all patterns we want to match
    final RegExp combinedRegex = RegExp(r'(\d+ \bGoal\b(s)?|Goal(s)?|\d+ \bAssist\b(s)?|Assist(s)?|\{Count\}|\d+)');

    for (final match in combinedRegex.allMatches(text)) {
      if (lastMatchEnd < match.start) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: TextStyle(color: restColor)));
      }

      String matchedText = text.substring(match.start, match.end);
      if (goalRegex.hasMatch(matchedText)) {
        spans.add(TextSpan(text: matchedText, style: TextStyle(color: goalsColor, fontWeight: FontWeight.bold)));
      } else if (assistRegex.hasMatch(matchedText)) {
        spans.add(TextSpan(text: matchedText, style: TextStyle(color: assistsColor, fontWeight: FontWeight.bold)));
      } else if (countRegex.hasMatch(matchedText)) {
        spans.add(TextSpan(text: matchedText, style: TextStyle(color: countColor, fontWeight: FontWeight.bold)));
      } else if (numberRegex.hasMatch(matchedText)) {
        spans.add(TextSpan(text: matchedText, style: TextStyle(color: numberColor, fontWeight: FontWeight.bold)));
      } else {
        spans.add(TextSpan(text: matchedText, style: TextStyle(color: restColor)));
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: TextStyle(color: restColor)));
    }

    return spans;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: cardBackgroundColor,
        cells: row.getCells().map<Widget>((e) {
          TextStyle getTextStyle() {
            if (e.columnName == 'goals_scored') {
              return TextStyle(color: goalsScoredTextColor, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
            }
            if (e.columnName == 'player_name') {
              return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontStyle: FontStyle.normal);
            } else if (e.columnName == 'nationality') {
              return const TextStyle(color: Colors.white, fontStyle: FontStyle.italic);
            } else {
              return const TextStyle(color: Colors.white);
            }
          }

          return e.columnName == 'image'
              ? Builder(builder: (context) {
                  FirstTeamClassNotifier firstTeamClassNotifier = Provider.of<FirstTeamClassNotifier>(context);
                  SecondTeamClassNotifier secondTeamClassNotifier = Provider.of<SecondTeamClassNotifier>(context);
                  ThirdTeamClassNotifier thirdTeamClassNotifier = Provider.of<ThirdTeamClassNotifier>(context);
                  FourthTeamClassNotifier fourthTeamClassNotifier = Provider.of<FourthTeamClassNotifier>(context);
                  FifthTeamClassNotifier fifthTeamClassNotifier = Provider.of<FifthTeamClassNotifier>(context);
                  SixthTeamClassNotifier sixthTeamClassNotifier = Provider.of<SixthTeamClassNotifier>(context);
                  return GestureDetector(
                    onTap: () {
                      /// DG to PP
                      String playerName = row.getCells().firstWhere((element) => element.columnName == 'player_name').value.toString();

                      var firstTeamPlayer = firstTeamClassNotifier.firstTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      var secondTeamPlayer = secondTeamClassNotifier.secondTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      var thirdTeamPlayer = thirdTeamClassNotifier.thirdTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      var fourthTeamPlayer = fourthTeamClassNotifier.fourthTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      var fifthTeamPlayer = fifthTeamClassNotifier.fifthTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      var sixthTeamPlayer = sixthTeamClassNotifier.sixthTeamClassList.firstWhereOrNull((element) => element.name == playerName);

                      if (firstTeamPlayer != null) {
                        firstTeamClassNotifier.currentFirstTeamClass = firstTeamPlayer;
                        navigateToSubPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (secondTeamPlayer != null) {
                        secondTeamClassNotifier.currentSecondTeamClass = secondTeamPlayer;
                        navigateToSecondTeamClassDetailsPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (thirdTeamPlayer != null) {
                        thirdTeamClassNotifier.currentThirdTeamClass = thirdTeamPlayer;
                        navigateToThirdTeamClassDetailsPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (fourthTeamPlayer != null) {
                        fourthTeamClassNotifier.currentFourthTeamClass = fourthTeamPlayer;
                        navigateToFourthTeamClassDetailsPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (fifthTeamPlayer != null) {
                        fifthTeamClassNotifier.currentFifthTeamClass = fifthTeamPlayer;
                        navigateToFifthTeamClassDetailsPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else if (sixthTeamPlayer != null) {
                        sixthTeamClassNotifier.currentSixthTeamClass = sixthTeamPlayer;
                        navigateToSixthTeamClassDetailsPage(context, clubId);

                        Toast.show("Loading up $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      } else {
                        Toast.show("We can't find $playerName", duration: Toast.lengthLong, gravity: Toast.bottom, backgroundRadius: 10);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      // width: 25,
                      // height: 25,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          // borderRadius: const BorderRadius.all(Radius.circular(15)),
                          image: DecorationImage(
                              alignment: const Alignment(-1, -1.1),
                              image: CachedNetworkImageProvider(
                                e.value,
                              ),
                              fit: BoxFit.cover)),
                    ),
                  );
                })
              : e.columnName == 'player_name'
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        e.value.toString(),
                        style: getTextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Container(
                      alignment: (e.columnName == 'id') ? Alignment.center : Alignment.centerLeft,
                      // alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        e.value.toString(),
                        style: getTextStyle(),
                        overflow: TextOverflow.fade,
                      ),
                    );
        }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}

Future navigateToSubPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => SubPage(clubId: clubId)));
}

Future navigateToSecondTeamClassDetailsPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => SecondTeamClassDetailsPage(clubId: clubId)));
}

Future navigateToThirdTeamClassDetailsPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdTeamClassDetailsPage(clubId: clubId)));
}

Future navigateToFourthTeamClassDetailsPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => FourthTeamClassDetailsPage(clubId: clubId)));
}

Future navigateToFifthTeamClassDetailsPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => FifthTeamClassDetailsPage(clubId: clubId)));
}

Future navigateToSixthTeamClassDetailsPage(context, String clubId) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => SixthTeamClassDetailsPage(clubId: clubId)));
}
