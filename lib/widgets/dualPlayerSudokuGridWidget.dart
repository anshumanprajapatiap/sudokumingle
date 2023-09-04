import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/utils/constants.dart';
import '../providers/darkThemeProvider.dart';
import '../providers/firebaseRoomManagementProvider.dart';
import '../utils/globalMethodUtil.dart';

class DualPlayerSudokuGridWidget extends StatefulWidget {
  final Map<String, dynamic> generatedSudoku;
  final bool isMultiplayer;
  final String activeGameId;
  final bool isPlayer1;
  final String playerId1;
  final String playerId2;

  DualPlayerSudokuGridWidget({
    required this.generatedSudoku,
    required this.isMultiplayer,
    required this.activeGameId,
    required this.isPlayer1,
    required this.playerId1,
    required this.playerId2
  });

  @override
  _DualPlayerSudokuGridWidgetState createState() => _DualPlayerSudokuGridWidgetState();
}

class _DualPlayerSudokuGridWidgetState extends State<DualPlayerSudokuGridWidget>
    with WidgetsBindingObserver {
  FirebaseGlobalMethodActiveGamePoolUtil firebaseGlobalMethodActiveGamePoolUtil = FirebaseGlobalMethodActiveGamePoolUtil();
  User? currentUser = FirebaseAuth.instance.currentUser;
  Timer? searchTimer;
  // bool _isLoading = true;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache? audioCache;
  bool isGameEnded = false;
  void initAudioCache() async {
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    await audioCache?.load('audio/alert_sound.mp3');
  }

  List<List<Color>> sudokuGridColors = List.generate(9, (_) => List.filled(9, Colors.transparent));
  List<List<int?>> sudokuGrid = List.generate(9, (_) => List.filled(9, null));
  List<List<int>> sudokuGridCorrect = List.generate(9, (_) => List.filled(9, 0));
  int? activeCellRow;
  int? activeCellCol;
  bool isPaused = false;
  Stopwatch stopwatch = Stopwatch();
  bool isCellTapped = false;
  bool isNonActiveIsActive= false;

  Difficulty? difficultyLevel;
  int numberOfMistakes = 0;
  int scoreTillNow = 0;

  late Timer timer;
  Duration elapsedTime = Duration.zero;
  String winnerId = '';
  int numberOfEmptyCell = 81;

  bool isCounter = true;
  String counter = "3";


  void playAlertSound() {
    audioCache?.play('audio/alert_sound.mp3');
  }

  int countEmptyCells() {
    int emptyCellCount = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (sudokuGrid[row][col] == null) {
          emptyCellCount++;
        }
      }
    }
    return emptyCellCount;
  }

  void setActiveCell(int row, int col) {
    resetNonActiveCell();
    setState(() {
      activeCellRow = row;
      activeCellCol = col;
      isCellTapped = true;
    });
  }

  void setNonActiveCell(int row, int col, int val, bool isDarkMode) {
    setState(() {
      isNonActiveIsActive = true;
      final tappedColor = isDarkMode ? Colors.blueGrey : Colors.blueGrey.shade100;// Change to the desired shade of grey

      for (int i = 0; i < 9; i++) {
        sudokuGridColors[row][i] = tappedColor;
        sudokuGridColors[i][col] = tappedColor;
      }

      final startRow = (row ~/ 3) * 3;
      final startCol = (col ~/ 3) * 3;
      for (int i = startRow; i < startRow + 3; i++) {
        for (int j = startCol; j < startCol + 3; j++) {
          sudokuGridColors[i][j] = tappedColor;
        }
      }
      for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
          if(val == sudokuGrid[i][j]) sudokuGridColors[i][j] = tappedColor;
        }
      }
      sudokuGridColors[row][col] = isDarkMode ? Colors.black12 : Colors.white;
    });
  }

  void resetActiveCell() {
    setState(() {
      activeCellRow = null;
      activeCellCol = null;
      isCellTapped = false;
      if(isNonActiveIsActive){
        sudokuGridColors = List.generate(9, (_) => List.filled(9, Colors.transparent));
      }

    });
  }

  void resetNonActiveCell() {
    setState(() {
      isNonActiveIsActive= false;
      sudokuGridColors = List.generate(9, (_) => List.filled(9, Colors.transparent));
    });
  }

  bool isEditableCell(int row, int col) {
    return sudokuGrid[row][col] == null;
  }

  void initializeSudoku() {
    sudokuGridCorrect = widget.generatedSudoku['correctSudoku'];
    sudokuGrid = widget.generatedSudoku['toBeSolvedSudoku'];
    difficultyLevel = widget.generatedSudoku['difficulty'];
    int emptyCellCount = countEmptyCells();
    numberOfEmptyCell = emptyCellCount;
  }

  void fillCell(int row, int col, int number) {
    if (isEditableCell(row, col)) {
      setState(() {
        sudokuGrid[row][col] = number;
      });
    }
  }

  String _formatElapsedTime(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    stopwatch.start();
  }

  void fillCellWithNumber(int number) {
    if (isCellTapped && activeCellRow != null && activeCellCol != null) {

      if (sudokuGridCorrect[activeCellRow!][activeCellCol!] != number) {
        playAlertSound();
        // print('alert_sound');
        setState(() {
          numberOfMistakes++;
        });
        firebaseGlobalMethodActiveGamePoolUtil.updateMistake(widget.isPlayer1, numberOfMistakes, widget.activeGameId);
        if (numberOfMistakes >= 3) {
          firebaseGlobalMethodActiveGamePoolUtil.thisPlayerLoseTheGame(widget.playerId1, widget.playerId2, widget.isPlayer1, scoreTillNow, numberOfMistakes, widget.activeGameId);
        }
        return;
      }

      scoreTillNow = scoreTillNow + number;
      numberOfEmptyCell = numberOfEmptyCell - 1;
      fillCell(activeCellRow!, activeCellCol!, number);
      if(numberOfEmptyCell==0){
        // print('gameOver');
        firebaseGlobalMethodActiveGamePoolUtil.thisPlayerWonTheGame(widget.playerId1, widget.playerId2, widget.isPlayer1, scoreTillNow, numberOfMistakes, widget.activeGameId);
      }
      else{
        firebaseGlobalMethodActiveGamePoolUtil.updateScore(widget.isPlayer1, scoreTillNow, widget.activeGameId);
      }
    }
  }

  void counterStartStop() async{

    await Future.delayed(Duration(seconds: 1), () {
      // print('deplayed for 3');
    });
    setState(() {
      counter = "2";
    });
    await Future.delayed(Duration(seconds: 1), () {
      // print('deplayed for 2');
    });
    setState(() {
      counter = "1";
    });
    await Future.delayed(Duration(seconds: 1), () {
      // print('deplayed for 1');
    });
    setState(() {
      counter = "GO!";
    });
    await Future.delayed(Duration(seconds: 1), () {
      // print('deplayed for GO');
    });
    setState(() {
      isCounter = false;
    });

    startTimer();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        elapsedTime = stopwatch.elapsed;
      });
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(!widget.isMultiplayer){
      if (state == AppLifecycleState.paused) {
        //pauseTimer();
        if (numberOfMistakes >= 3) {
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => buildMaxMistakesDialog(),
          // ).then((value) {
          //   if(widget.isMultiplayer){
          //     Navigator.of(context).pop();
          //   }
          // });
        } else if (isPaused) {
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => showPauseDialog(context),
          // );
          //showPauseDialog(context);
        }
      }
      // else if (state == AppLifecycleState.resumed) {
      //   resumeTimer();
      // }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    stopwatch.stop();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DualPlayerSudokuGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isPaused) {
      //pauseTimer();
      if (numberOfMistakes >= 3) {
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) => buildMaxMistakesDialog(),
        // );
      } else {
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) => showPauseDialog(context),
        // );
        //showPauseDialog(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initAudioCache();
    initializeSudoku();
    counterStartStop();
    // startTimer();
    // timer = Timer.periodic(Duration(seconds: 1), (_) {
    //   setState(() {
    //     elapsedTime = stopwatch.elapsed;
    //   });
    // });
    // final firebaseRoomManagementProvider = Provider.of<FirebaseRoomManagementProvider>(context, listen: false);
    // firebaseRoomManagementProvider.setBackButtonTrue();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSwitchProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if(widget.isMultiplayer && isGameEnded == false){
          firebaseGlobalMethodActiveGamePoolUtil.thisPlayerLoseTheGame(widget.playerId1, widget.playerId2, widget.isPlayer1, scoreTillNow, numberOfMistakes, widget.activeGameId);
        }
        return false;
      },

      child: Scaffold(
        body: isCounter
            ? Center(
                child: Text(
                  counter,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize:  30
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(difficultyLevel!.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                      Text('Score: $scoreTillNow',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                      Text('Mistakes: $numberOfMistakes/3',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                      TextButton.icon(
                        onPressed: (){},
                        label: Text(
                          _formatElapsedTime(elapsedTime),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor
                          ),
                        ),
                        icon: Icon(Icons.timer, weight: 700,
                            color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width*0.98,
                    padding: const EdgeInsets.all(10.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 81,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final cellValue = sudokuGrid[row][col];
                        final editableCell = isEditableCell(row, col);
                        final isActiveCell = activeCellRow == row && activeCellCol == col;


                        final isBoldCellColumn = col==0 || col == 3 || col == 6 ;
                        final isBoldCellRow = row == 0  || row == 3 || row == 6;
                        final rowNumberEight = row == 8;
                        final columnNumberEight = col == 8;
                        final borderColor = isBoldCellColumn || isBoldCellRow || rowNumberEight || columnNumberEight
                            ? themeProvider.isDarkMode ? Colors.white : Colors.black
                            : themeProvider.isDarkMode ? Colors.blueGrey.shade400 : Colors.blueGrey;

                        final tappedColor = themeProvider.isDarkMode ? Colors.blueGrey.shade400 : Colors.blueGrey.shade100;  // Change this to the desired color

                        Color cellColor = isActiveCell ? Colors.blueGrey : Colors.grey.withOpacity(0.1);
                        cellColor = isNonActiveIsActive ? sudokuGridColors[row][col]: cellColor;
                        if (!editableCell && isActiveCell) {
                          cellColor = tappedColor;
                        } else if (!editableCell) {
                          cellColor = cellColor; // Change this to the desired background color
                        }



                        return GestureDetector(
                          onTap: () {
                            if (editableCell) {
                              if (isActiveCell) {
                                resetActiveCell();
                              } else {
                                setState(() {
                                  setActiveCell(row, col);
                                });
                              }
                            }
                            else {
                              resetActiveCell();
                              resetNonActiveCell();
                              setNonActiveCell(row, col, cellValue!, themeProvider.isDarkMode);
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: columnNumberEight ? borderColor: Colors.grey.withOpacity(0.2),
                                        width: 2
                                    ),
                                    left: BorderSide(
                                        color: isBoldCellColumn ? borderColor : Colors.grey.withOpacity(0.0),
                                        width: 2
                                    ),
                                    bottom: BorderSide(
                                        color: rowNumberEight ? borderColor : Colors.grey.withOpacity(0.2),
                                        width: 2
                                    ),
                                    top: BorderSide(
                                        color: isBoldCellRow ? borderColor : Colors.grey.withOpacity(0.0),
                                        width: 2
                                    ),

                                  ),
                                  color: cellColor,
                                  //fontWeight: isBoldCell ? FontWeight.bold : FontWeight.normal,
                                ),
                                child: Center(
                                  child: Text(
                                    cellValue != null ? cellValue.toString() : '',
                                    style: TextStyle(
                                      fontSize: 23,
                                      color: themeProvider.isDarkMode ? Colors.white : Colors.blueGrey ,),
                                  ),
                                ),
                              ),
                              isActiveCell && editableCell
                                  ? Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Handle cell interaction
                                    },
                                  ),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  const SizedBox(height: 30),

                  Container(
                    width: MediaQuery.of(context).size.width*.98,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(9, (index) {
                        int number = index + 1;
                        return GestureDetector(
                          onTap: () {
                            fillCellWithNumber(number);
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width/11,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Text(
                                number.toString(),
                                style: const TextStyle(
                                  // color: Theme.of(context).secondaryHeaderColor,
                                    color: Colors.white,
                                    fontSize: 23, fontWeight:
                                FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                ],
              ),
      ),
    );
  }

}
