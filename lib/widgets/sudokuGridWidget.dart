import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/model/gameHistoryModel.dart';
import 'package:sudokumingle/providers/darkThemeProvider.dart';
import 'package:sudokumingle/screens/homeScreen.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/utils/constants.dart';

import '../main.dart';
import '../providers/firebaseUserDataProvider.dart';
import '../utils/globalMethodUtil.dart';

class SudokuGridWidget extends StatefulWidget {
  final Map<String, dynamic> generatedSudoku;

  SudokuGridWidget({
    required this.generatedSudoku,
  });

  @override
  _SudokuGridWidgetState createState() => _SudokuGridWidgetState();
}

class _SudokuGridWidgetState extends State<SudokuGridWidget>
    with WidgetsBindingObserver {
  Timestamp createdAt = Timestamp.now();
  Timer? searchTimer;
  bool _isLoading = true;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache? audioCache;
  void initAudioCache() async {
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    await audioCache?.load('audio/alert_sound.mp3');
  }

  void playAlertSound() {
    audioCache?.play('audio/alert_sound.mp3');
  }
  // void playAlertSound(){
  //   final player=AudioCache();
  //   player.play('audio/alert_sound.mp3');
  // }

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
  int numberOfEmptyCell = 81;

  late Timer timer;
  Duration elapsedTime = Duration.zero;

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
      final tappedColor = isDarkMode ? Colors.blueGrey : Colors.blueGrey.shade100; // Change to the desired shade of grey

      // Update colors of the row and column
      for (int i = 0; i < 9; i++) {
        sudokuGridColors[row][i] = tappedColor;
        sudokuGridColors[i][col] = tappedColor;
      }

      // Update colors of the 3x3 grid
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

  @override
  void initState() {
    super.initState();
    initAudioCache();
    startTimer();
    initializeSudoku();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        elapsedTime = stopwatch.elapsed;
      });
    });
    WidgetsBinding.instance?.addObserver(this);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.paused) {
        pauseTimer();
        if (numberOfMistakes >= 3) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => buildMaxMistakesDialog(),
          ).then((value) {
            Navigator.of(context).pop();
          });
        } else if (isPaused) {
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => showPauseDialog(context),
          // );
          showPauseDialog(context);
        }
      }
      // else if (state == AppLifecycleState.resumed) {
      //   resumeTimer();
      // }
  }

  @override
  void dispose() {
    timer.cancel();
    stopwatch.stop();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(SudokuGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isPaused) {
      pauseTimer();
      if (numberOfMistakes >= 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => buildMaxMistakesDialog(),
        );
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

  void initializeSudoku() {
    sudokuGridCorrect = widget.generatedSudoku['correctSudoku'];
    sudokuGrid = widget.generatedSudoku['toBeSolvedSudoku'];
    difficultyLevel = widget.generatedSudoku['difficulty'];
    int emptyCellCount = countEmptyCells();
    print('Number of empty cells: $emptyCellCount');
    numberOfEmptyCell = emptyCellCount;
    print('Number of empty after initializeSudoku: $numberOfEmptyCell');
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

  void pauseTimer() {
    //Navigator.pop(context);
    setState(() {
      isPaused = true;
      stopwatch.stop();
    });
    showPauseDialog(context);

  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
      stopwatch.start();
    });
  }

  void fillCellWithNumber(int number) {
    if (isCellTapped && activeCellRow != null && activeCellCol != null) {
      if (sudokuGridCorrect[activeCellRow!][activeCellCol!] != number) {
        playAlertSound();
        print('alert_sound');
        setState(() {
          numberOfMistakes++;
        });
        if (numberOfMistakes >= 3) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => buildMaxMistakesDialog(),
          );
        }
        return;
      }
      scoreTillNow = scoreTillNow + number;
      numberOfEmptyCell = numberOfEmptyCell - 1;
      fillCell(activeCellRow!, activeCellCol!, number);
      if(numberOfEmptyCell==0){
        print('gameOver');
        showGameOverDialog(context);
      }
    }
  }


  AlertDialog buildMaxMistakesDialog() {
    return AlertDialog(
      title: Text('Maximum Mistakes Reached'),
      content: Text('You have made 3 mistakes. Do you want to restart the game or go back?'),
      actions: [
        Center(
          child: Row(
            children: [
                    TextButton(
                      onPressed: () {
                        // Restart game
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PraticeOfflineSudokuScreen(difficultyLevel: difficultyLevel as Difficulty,))
                        );
                      },
                      child: Text('Restart'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Go back
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Go Back'),
                    ),
                  ],
          ),
        )
      ],
    );
  }

  void showGameOverDialog(BuildContext context) {
    final double dialogHeight = MediaQuery.of(context).size.height * 0.8;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                // Prevent dialog from closing on back press
                return false;
              },
              child: AlertDialog(
                title: Text('Game Over',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                content: Container(
                  height: dialogHeight * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text('Mistakes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('$numberOfMistakes/3',

                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              Text('Time',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('${_formatElapsedTime(elapsedTime)}',

                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              Text('Difficulty',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('${difficultyLevel?.name}',

                              ),
                            ],
                          ),
                        ],
                      ),
                      // Image of 150x150
                      SizedBox(height: 20,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.7,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Resume game
                          saveGameToUserHistory();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Exit'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                        ),
                        onPressed: () {
                          // Resume game
                          saveGameToUserHistory();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => PraticeOfflineSudokuScreen(difficultyLevel: difficultyLevel as Difficulty,))
                          );
                        },
                        child: Text('Play Again'),
                      ),

                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showPauseDialog(BuildContext context) {
    final double dialogHeight = MediaQuery.of(context).size.height * 0.8;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                // Prevent dialog from closing on back press
                return false;
              },
              child: AlertDialog(
                title: Text('Paused',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                content: Container(
                  height: dialogHeight * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text('Mistakes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('$numberOfMistakes/3',

                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              Text('Time',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('${_formatElapsedTime(elapsedTime)}',

                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              Text('Difficulty',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('${difficultyLevel?.name}',

                              ),
                            ],
                          ),
                        ],
                      ),
                      // Image of 150x150
                      SizedBox(height: 20,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.7,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Resume game
                          saveGameToUserHistory();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Exit'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                        ),
                        onPressed: () {
                          // Resume game
                          Navigator.pop(context);
                          resumeTimer();
                        },
                        child: Text('Resume'),
                      ),

                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void saveGameToUserHistory(){
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    DateTime createdAtDateTime = createdAt.toDate();
    // Duration duration;
    // DateTime endedDateTime = createdAtDateTime.add(timer);
    // Timestamp endedAt = Timestamp.fromDate(endedDateTime);

    GameHistoryModel gameData = GameHistoryModel(
        gameId: createdAt.toString(),
        playerId1: '',
        playerId2: '',
        difficultyLevel: difficultyLevel!.name,
        winnerId: '',
        createdAt: createdAt,
        endedAt: Timestamp.now(),
        player1Points: scoreTillNow,
        player2Points: 0,
        player1Mistake: numberOfMistakes,
        player2Mistake: 0,
        createdBy: ''
    );

    userDataProvider.addUserGameHistory(gameData, isMultiplayer: false);


  }



  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeSwitchProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        pauseTimer();
        return true;
      },
      child: _isLoading
          ? const Scaffold(
            body:  Center(child: CircularProgressIndicator(),),
          )
          : Scaffold(
            body: Column(
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
                      onPressed: isPaused ? resumeTimer : pauseTimer,
                      label: Text(
                        _formatElapsedTime(elapsedTime),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                      icon: Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          weight: 700,
                          color: Theme.of(context).primaryColor
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 81,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

                      final tappedColor = themeProvider.isDarkMode ? Colors.blueGrey.shade400 : Colors.blueGrey.shade100; // Change this to the desired color

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
                                  right: BorderSide(color: columnNumberEight ? borderColor: Colors.grey.withOpacity(0.2)),
                                  left: BorderSide(color: isBoldCellColumn ? borderColor : Colors.grey.withOpacity(0.0)),
                                  bottom: BorderSide(color: rowNumberEight ? borderColor : Colors.grey.withOpacity(0.2)),
                                  top: BorderSide(color: isBoldCellRow ? borderColor : Colors.grey.withOpacity(0.0)),

                                ),
                                color: cellColor,
                                // fontWeight: true ? FontWeight.bold : FontWeight.normal,
                              ),
                              child: Center(
                                child: Text(
                                  cellValue != null ? cellValue.toString() : '',
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode ? Colors.white : Colors.blueGrey ,
                                      fontSize: 20
                                  ),
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

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(9, (index) {
                      int number = index + 1;
                      return GestureDetector(
                        onTap: () {
                          fillCellWithNumber(number);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              number.toString(),
                              style: TextStyle(
                                  // color: Theme.of(context).secondaryHeaderColor,
                                  color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

              ],
            ),
            bottomNavigationBar: SizedBox(
              height: MediaQuery.of(context).size.height*0.1,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Center(
                    child: Text('')
                ),
              ),
            ),
          ),
    );
  }
}
