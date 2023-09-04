import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/model/gameHistoryModel.dart';
import 'package:sudokumingle/providers/darkThemeProvider.dart';
import 'package:sudokumingle/screens/homeScreen.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/utils/constants.dart';

import '../main.dart';
import '../providers/firebaseUserDataProvider.dart';
import '../utils/adMobUtility.dart';
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
  User? currentUser = FirebaseAuth.instance.currentUser;
  Timestamp createdAt = Timestamp.now();
  Timer? searchTimer;
  // bool _isLoading = true;
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


  AdMobUtility adMobUtility = AdMobUtility();
  late InterstitialAd interstitialAd;
  late BannerAd pauseBox;
  late BannerAd gameOver;
  late BannerAd mistakes;

  initBannerAd(){
    pauseBox = adMobUtility.largeBannerAd();
    pauseBox.load();
    gameOver = adMobUtility.largeBannerAd();
    gameOver.load();
    mistakes = adMobUtility.largeBannerAd();
    mistakes.load();
  }

  void initGameEndAd(){

    InterstitialAd.load(
      adUnitId: adMobUtility.productionCoinWinAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad){
          interstitialAd = ad;
        },
        onAdFailedToLoad: ((error) {
          interstitialAd.dispose();
        }),
      ),
    );
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

  bool isCounter = true;
  String counter = "3";

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
  void initState() {
    super.initState();
    initAudioCache();
    initGameEndAd();
    initBannerAd();
    startTimer();
    initializeSudoku();
    counterStartStop();
    // timer = Timer.periodic(Duration(seconds: 1), (_) {
    //   setState(() {
    //     elapsedTime = stopwatch.elapsed;
    //   });
    // });
    WidgetsBinding.instance?.addObserver(this);
    // setState(() {
    //   _isLoading = false;
    // });

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
    // print('Number of empty cells: $emptyCellCount');
    numberOfEmptyCell = emptyCellCount;
    // print('Number of empty after initializeSudoku: $numberOfEmptyCell');
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
        // print('alert_sound');
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
        // print('gameOver');
        showGameOverDialog(context);
      }
    }
  }

  Dialog buildMaxMistakesDialog() {
    return Dialog(
      insetAnimationCurve: Curves.bounceOut,
      insetAnimationDuration: const Duration(milliseconds: 100),
      backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            Text(
              'Maximum Mistakes Reached',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              'You have made 3 mistakes. Do you want to restart the game or go back?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor
              ),
            ),

            const SizedBox(height: 20,),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: mistakes.size.width.toDouble(),
              child: AdWidget(ad: mistakes),
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  child: Text(''
                      'Restart',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Go back
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor
                    ),),
                ),
              ],
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  void showGameOverDialog(BuildContext context) {
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
              child: Dialog(
                insetAnimationCurve: Curves.bounceOut,
                insetAnimationDuration: const Duration(milliseconds: 100),
                backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20,),
                    Text('Game Over',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 30
                      ),
                    ),
                    numberOfEmptyCell == 0
                        ? Text('You Won',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15
                            ),
                          )
                        :  Text('You Lose',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15
                            ),
                          ),

                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('Mistakes',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),
                            ),
                            Text('$numberOfMistakes/3',
                              style: TextStyle(
                                  color: numberOfMistakes>=1
                                      ? Colors.redAccent
                                      : Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            Text('Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),
                            ),
                            Text('${_formatElapsedTime(elapsedTime)}',
                              style: TextStyle(

                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),

                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            Text('Difficulty',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),
                            ),
                            Text('${difficultyLevel?.name}',
                              style: TextStyle(

                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15
                              ),

                            ),
                          ],
                        ),
                      ],
                    ),
                    // Image of 150x150
                    SizedBox(height: 20,),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: mistakes.size.width.toDouble(),
                      child: AdWidget(ad: mistakes),
                    ),

                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Resume game
                            saveGameToUserHistory();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Exit',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor
                            ),
                          ),
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
                          child: Text('Play Again',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
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
              child: Dialog(
                insetAnimationCurve: Curves.bounceOut,
                insetAnimationDuration: const Duration(milliseconds: 100),
                backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Text('Paused',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 28
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('Mistakes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),
                                ),
                                Text('$numberOfMistakes/3',
                                  style: TextStyle(

                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                 Text('Time',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),
                                ),
                                Text('${_formatElapsedTime(elapsedTime)}',
                                  style: TextStyle(

                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),

                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                 Text('Difficulty',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),
                                ),
                                Text('${difficultyLevel?.name}',
                                  style: TextStyle(

                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15
                                  ),

                                ),
                              ],
                            ),
                          ],
                        ),
                        // Image of 150x150
                        const SizedBox(height: 20,),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: pauseBox.size.width.toDouble(),
                          child: AdWidget(ad: pauseBox),
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.8,
                        //   height: MediaQuery.of(context).size.height * 0.3,
                        //   child: Container(
                        //     color: Theme.of(context).primaryColor,
                        //   ),
                        // )
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Resume game
                            saveGameToUserHistory();
                            Navigator.pop(context);
                            Navigator.pop(context);
                            // Navigator.pop(context);
                            interstitialAd.show();
                          },
                          child: Text('Exit',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor
                              )
                          ),
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
                          child: Text('Resume', style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor
                          ),),
                        ),

                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void saveGameToUserHistory(){
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    // Duration duration;
    // DateTime endedDateTime = createdAtDateTime.add(timer);
    // Timestamp endedAt = Timestamp.fromDate(endedDateTime);
    bool _isGameCompleted = false;
    if(numberOfMistakes != 3 && numberOfEmptyCell==0){
      _isGameCompleted = true;
    }
    GameHistoryModel gameData = GameHistoryModel(
        gameId: createdAt.toString(),
        playerId1: currentUser!.uid,
        playerId2: '',
        difficultyLevel: difficultyLevel!.name,
        winnerId: _isGameCompleted ? currentUser!.uid : '',
        createdAt: createdAt,
        endedAt: Timestamp.now(),
        player1Points: scoreTillNow,
        player2Points: 0,
        player1Mistake: numberOfMistakes,
        player2Mistake: 0,
        createdBy: currentUser!.uid,
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
      child: isCounter
          ? Scaffold(
            body: Center(
              child: Text(
                counter,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize:  30
                ),
              ),
            ),
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
                                // fontWeight: true ? FontWeight.bold : FontWeight.normal,
                              ),
                              child: Center(
                                child: Text(
                                  cellValue != null ? cellValue.toString() : '',
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode ? Colors.white : Colors.blueGrey ,
                                      fontSize: 23
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Reset
                      /*
                      TextButton(
                        onPressed: () {
                          // Handle reset button tap here
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(8), //// Remove default padding
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restore, color: Theme.of(context).primaryColor,),
                            SizedBox(height: 4),
                            Text('Reset', style: TextStyle(color: Theme.of(context).primaryColor, )),
                          ],
                        ),
                      ),
                      */

                      //Erase
                      /*
                      TextButton(
                        onPressed: () {
                          // Handle erase button tap here
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(8), //// Remove default padding
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.backspace, color: Theme.of(context).primaryColor),
                            SizedBox(height: 4),
                            Text('Erase', style: TextStyle(color: Theme.of(context).primaryColor, )),
                          ],
                        ),
                      ),*/

                      //Notes
                      /*
                      TextButton(
                        onPressed: () {
                          // Handle notes button tap here
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(8), //// Remove default padding
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.note, color: Theme.of(context).primaryColor),
                            SizedBox(height: 4),
                            Text('Notes', style: TextStyle(color: Theme.of(context).primaryColor, )),
                          ],
                        ),
                      ),
                      */


                      //Hint
                      /*
                      TextButton(
                        onPressed: () {
                          // Handle hint button tap here
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(8), // Remove default padding
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                            const SizedBox(height: 4),
                            Text('Hint', style: TextStyle(color: Theme.of(context).primaryColor, )),
                          ],
                        ),
                      ),
                      */
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 10),
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
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

              ],
            ),

            // bottomNavigationBar: SizedBox(
            //   height: MediaQuery.of(context).size.height*0.1,
            //   child: Container(
            //     color: Theme.of(context).primaryColor,
            //     child: Center(
            //         child: Text('')
            //     ),
            //   ),
            // ),
          ),
    );
  }
}
