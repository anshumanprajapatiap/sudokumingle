import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/screens/bottomNavigationBar.dart';
import 'package:sudokumingle/screens/homeScreen.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/utils/constants.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../providers/darkThemeProvider.dart';
import '../utils/globalMethodUtil.dart';

class DualPlayerSudokuGridWidget extends StatefulWidget {
  final Map<String, dynamic> generatedSudoku;
  final bool isMultiplayer;
  final String activeGameId;

  final bool isPlayer1;

  DualPlayerSudokuGridWidget({
    required this.generatedSudoku,
    required this.isMultiplayer,
    required this.activeGameId,
    required this.isPlayer1
  });

  @override
  _DualPlayerSudokuGridWidgetState createState() => _DualPlayerSudokuGridWidgetState();
}

class _DualPlayerSudokuGridWidgetState extends State<DualPlayerSudokuGridWidget>
    with WidgetsBindingObserver {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Timer? searchTimer;
  bool _isLoading = true;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache? audioCache;
  bool isGameEnded = false;
  // void initAudioCache() async {
  //   audioCache = AudioCache(fixedPlayer: audioPlayer);
  //   await audioCache?.load('assets/audio/alert_sound.mp3');
  // }

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


  void playAlertSound() {
    audioCache?.play('assets/audio/alert_sound.mp3');
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
    // initAudioCache();
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
    if(!widget.isMultiplayer){
      if (state == AppLifecycleState.paused) {
        //pauseTimer();
        if (numberOfMistakes >= 3) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => buildMaxMistakesDialog(),
          ).then((value) {
            if(widget.isMultiplayer){
              Navigator.of(context).pop();
            }
          });
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

  // void pauseTimer() {
  //   //Navigator.pop(context);
  //   setState(() {
  //     isPaused = true;
  //     stopwatch.stop();
  //   });
  //   showPauseDialog(context);
  //
  // }

  // void resumeTimer() {
  //   setState(() {
  //     isPaused = false;
  //     stopwatch.start();
  //   });
  // }

  void fillCellWithNumber(int number) {
    if (isCellTapped && activeCellRow != null && activeCellCol != null) {
      if (sudokuGridCorrect[activeCellRow!][activeCellCol!] != number) {
        playAlertSound();
        print('alert_sound');
        setState(() {
          numberOfMistakes++;
        });
        if (numberOfMistakes >= 3) {
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => buildMaxMistakesDialog(),
          // );
          thisPlayerLoseTheGame(currentUser!.uid, context);
        }
        return;
      }
      scoreTillNow = scoreTillNow + number;
      numberOfEmptyCell = numberOfEmptyCell - 1;
      fillCell(activeCellRow!, activeCellCol!, number);
      if(numberOfEmptyCell==0){
        print('gameOver');
        thisPlayerWonTheGame(currentUser!.uid, context);
      }
    }
  }

  AlertDialog buildMaxMistakesDialog() {
    if(widget.isMultiplayer){

    }
    return AlertDialog(
      title: Text('Maximum Mistakes Reached'),
      content: Text('You have made 3 mistakes. Do you want to restart the game or go back?'),
      actions: [
        Center(
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  // Go back
                  //deleteFromActiveGamePool();
                  thisPlayerLoseTheGame(currentUser!.uid, context);
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        )
      ],
    );
  }


  void showGameOverDialog(BuildContext context, bool error) {
    final double dialogHeight = MediaQuery.of(context).size.height * 0.8;
    Widget winnerShow = const Text('Click Exit to Show Results');


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // Prevent dialog from closing on back press
                return false;
              },
              child: AlertDialog(
                title: const Text('Game Ended!!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                content: Container(
                  height: dialogHeight * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      winnerShow,
                      // Image of 150x150
                      const SizedBox(height: 20,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: dialogHeight* 0.5,
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
                          // Exit
                          Navigator.pop(context);
                        },
                        child: Text('Exit'),
                      )

                    ],
                  ),
                ],
              ),
            );
          },
    );
  }

  fetchUserFromActiveGamePoolContinuously(String gameId, BuildContext ctx) async{
    // print('fetching Game is Active $gameId for puzzle ${widget.activePuzzleId}');
    CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection('ActiveGamePool');
    if(isGameEnded) {
      //winnerCalculator(ctx, false, currentUser!.uid);
      showGameOverDialog(ctx, false);
      print('gameisoverfrominnerwidget');

    }else{
      DocumentSnapshot snapshot = await activeUserPoolCollection.doc(gameId).get();
      if(snapshot.exists){
        Map<String, dynamic>? documentData = snapshot.data() as Map<String, dynamic>?;
        if(documentData!['isGameEnded']){
          winnerCalculator(ctx, false, currentUser!.uid);
          setState(() {
            isGameEnded = true;
          });
          showGameOverDialog(ctx, false);
        }
      }
      else{
        showGameOverDialog(ctx, true);
      }
    }
  }

  // void deleteFromActiveGamePool() async{
  //   try{
  //     FirebaseGlobalMethodUtil.deleteDocument(Constants.ACTIVE_GAME_POOL, widget.activeGameId);
  //   }catch(e){
  //     print('All ready deleted from ACTIVE_GAME_POOL');
  //   }
  //   try{
  //     FirebaseGlobalMethodUtil.deleteDocument(Constants.ACTIVE_PUZZLE_POOL, widget.activePuzzleId);
  //   }catch(e){
  //     print('All ready deleted from ACTIVE_PUZZLE_POOL');
  //   }
  //   try{
  //     FirebaseGlobalMethodUtil.deleteDocument(Constants.ACTIVE_USER_POOL, currentUser!.uid);
  //   }catch(e){
  //     print('All ready deleted from ACTIVE_USER_POOL');
  //   }
  //
  // }

  void writeOnCustomUserProfile(String player1UserId, String player2UserId,
      Timestamp screenCreatedAt, Timestamp endedAt,
      int player1Points, int player2Points, int player1Mistake, int player2Mistake) async {
    try {
      // Reference to the ActiveUserPool collection
      String gId = Uuid().v4();
      CollectionReference passiveUserGamePoolCollection = FirebaseFirestore.instance
          .collection(Constants.CUSTOM_USER_PROFILE)
          .doc(currentUser!.uid)
          .collection(Constants.USER_GAME_HISTORY);
      // Create a document with the current user ID as the document ID
      DocumentReference userGameDocument = passiveUserGamePoolCollection.doc(gId);

      // Set the data for the user document
      await userGameDocument.set({
        'gameId': widget.activeGameId,
        'playerId1': player1UserId,
        'playerId2': player2UserId,
        'puzzleId': difficultyLevel!.name,
        'winnerId': winnerId,
        'createdAt': screenCreatedAt,
        'endedAt': endedAt,
        'player1Points': player1Points,
        'player2Points': player2Points,
        'player1Mistake': player1Mistake,
        'player2Mistake': player2Mistake,
      });

      print('Game History Saved!');

    } catch (error) {
    print('Game History : $error');
    }

  }

  void calculateWinnerMethod(
      int player1Points, int player2Points,
      int player1Mistake, int player2Mistake,
      String player1UserId, String player2UserId,
      {required bool isSkippedByPlayer1, required bool isSkippedByPlayer2}) {

    if(isSkippedByPlayer1 || isSkippedByPlayer2){
      print('isSkippedByPlayer1 $isSkippedByPlayer1');
      print('isSkippedByPlayer2 $isSkippedByPlayer2');

      if(isSkippedByPlayer1 && currentUser!.uid==player1UserId){
        setState(() {
          winnerId = player2UserId;
        });
      }
      else if(isSkippedByPlayer2 && currentUser!.uid==player2UserId){
        setState(() {
          winnerId = player1UserId;
        });
      }
      else if(isSkippedByPlayer1 && currentUser!.uid==player2UserId){
        setState(() {
          winnerId = player2UserId;
        });
      }
      else if(isSkippedByPlayer2 && currentUser!.uid==player1UserId){
        setState(() {
          winnerId = player1UserId;
        });
      }
      else{
        setState(() {
          winnerId = 'MATCH_DRAW';
        });
      }

      return;
    }


    if(player1Points>player2Points){
      setState(() {
        winnerId = player1UserId;
      });
    }
    else if(player2Points>player1Points){
      setState(() {
        winnerId = player2UserId;
      });
    }
    else{
      if(player1Mistake<player2Mistake){
        setState(() {
          winnerId = player1UserId;
        });
      }
      else if(player1Mistake>player2Mistake){
        setState(() {
          winnerId = player2UserId;
        });
      }
      else{
        setState(() {
          winnerId = 'MATCH_DRAW';
        });
      }
    }
  }

  void winnerCalculator(BuildContext ctx, bool isSkippedByThisUser, String currentUserId) async{
    setState(() {
      _isLoading = true;
    });
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId);

    bool min5Passed = true;
    Timer(Duration(seconds: 5), () {
      min5Passed = false;
    });

    if(widget.isPlayer1){
      await activeGameDocRef.update({
        'player1Points': scoreTillNow,
        'player1Mistake': numberOfMistakes,
        'isScoreUpdate1': true,
        'isSkippedPlayer1': isSkippedByThisUser,
        'endedAt':Timestamp.now()
      });
      while(min5Passed){
        DocumentSnapshot activeGameDocSnapshot = await FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId).get();
        if(activeGameDocSnapshot.exists){
          Map<String, dynamic>? documentData = activeGameDocSnapshot.data() as Map<String, dynamic>?;
          if(documentData!['isScoreUpdate2']){
            calculateWinnerMethod(
                documentData['player1Points'],
                documentData['player2Points'],
                documentData['player1Mistake'],
                documentData['player2Mistake'],
                documentData['playerId1'],
                documentData['playerId2'],
                isSkippedByPlayer1: documentData['isSkippedPlayer1'],
                isSkippedByPlayer2: documentData['isSkippedPlayer2']
            );
            break;
          }
        }
      }


    }
    else{
      await activeGameDocRef.update({
        'player2Points': scoreTillNow,
        'player2Mistakes': numberOfMistakes,
        'isScoreUpdate2': true,
        'isSkippedPlayer2': isSkippedByThisUser,
        'endedAt':Timestamp.now()
      });
      while(min5Passed){
        DocumentSnapshot activeGameDocSnapshot = await FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId).get();
        if(activeGameDocSnapshot.exists){
          Map<String, dynamic>? documentData = activeGameDocSnapshot.data() as Map<String, dynamic>?;
          if(documentData!['isScoreUpdate2']){
            calculateWinnerMethod(
                documentData['player1Points'],
                documentData['player2Points'],
                documentData['player1Mistake'],
                documentData['player2Mistake'],
                documentData['playerId1'],
                documentData['playerId2'],
                isSkippedByPlayer1: documentData['isSkippedPlayer1'],
                isSkippedByPlayer2: documentData['isSkippedPlayer2']
            );
            break;
          }
        }
      }
    }
    // await Future.delayed(Duration(seconds: 5), () {print('deplayed3');});
    // if(min5Passed == false){
    //
    //   setState(() {
    //     winnerId = currentUserId;
    //   });
    // }
    print('thiswinner id $winnerId');
    await activeGameDocRef.update({
      'winnerId': winnerId,
    });
    print('winner Calculated');
    setState(() {
      _isLoading = false;
    });

    DocumentSnapshot activeGameDocSnapshot = await FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId).get();
    if(activeGameDocSnapshot.exists){
      Map<String, dynamic>? documentData = activeGameDocSnapshot.data() as Map<String, dynamic>?;
      print('winneris- ${documentData!['winnerId']}');

      //save active gamePool to History for user;
      writeOnCustomUserProfile(
        documentData['playerId1'],
        documentData['playerId2'],
        documentData['createdAt'],
        documentData['endedAt'],
        documentData['player1Points'],
        documentData['player2Points'],
        documentData['player1Mistake'],
        documentData['player2Mistake']
      );

    }

    // deleteFromActiveGamePool();

  }

  void thisPlayerWonTheGame(String currentUserId, BuildContext ctx) async {

    //update isGameEnded to true;
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId);
    //winnerCalcuator(isSkippedByThisUser:true)
    winnerCalculator(ctx, false, currentUserId);
    setState(() {
      isGameEnded = true;
    });
    await activeGameDocRef.update({
      'isGameEnded': true,
    });
    // await Future.delayed(Duration(seconds: 3), () {print('deplayed1');});
    fetchUserFromActiveGamePoolContinuously(widget.activeGameId, ctx);
  }

  void thisPlayerLoseTheGame(String currentUserId, BuildContext ctx) async{

    //update isGameEnded to true;
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(widget.activeGameId);
    //winnerCalcuator(isSkippedByThisUser:true)
    winnerCalculator(ctx, true,currentUserId);
    setState(() {
      isGameEnded = true;
    });
    await activeGameDocRef.update({
      'isGameEnded': true,
    });
    // await Future.delayed(Duration(seconds: 3), () {print('deplayed1');});
    fetchUserFromActiveGamePoolContinuously(widget.activeGameId, ctx);
  }

  Widget winnerAnnouncement(String winnerId, String currentUserId){
    String variableString =
      winnerId == currentUserId
          ? 'Congrats  you Won!, Play Again'
          : 'Opps you Lose!, Try Again';

    Widget whoIsWinner = Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
              'Game Ended!',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor
              ),
          ),
          SizedBox(height: 5,),
          Text(
            variableString,
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor
            ),
          )
        ],
      ),
    );
    return whoIsWinner;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSwitchProvider>(context);
    if(widget.isMultiplayer && isGameEnded == false){
      fetchUserFromActiveGamePoolContinuously(widget.activeGameId, context);
      //return const Placeholder();
    }

    return WillPopScope(
      onWillPop: () async {
        if(widget.isMultiplayer && isGameEnded == false){
          thisPlayerLoseTheGame(currentUser!.uid, context);
          //deleteFromActiveGamePool(context);
          //fetchUserFromActiveGamePoolContinuously(widget.activeGameId, context);
        }
        return false;
      },
      child: _isLoading
          ? Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor
                  ),),
                  SizedBox(height: 30,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text('Go Back'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                      fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),
                    ),
                  )
                ],
              ),
            )
          : isGameEnded
            ? Scaffold(
                body:
                  Center(
                    child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          winnerAnnouncement(winnerId, currentUser!.uid),
                          ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: Text('Go Back'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                              fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),
                            ),
                          )
                        ],
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
              //SizedBox(height: 8),

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
                              //fontWeight: isBoldCell ? FontWeight.bold : FontWeight.normal,
                            ),
                            child: Center(
                              child: Text(
                                cellValue != null ? cellValue.toString() : '',
                                style: TextStyle(
                                  fontSize: 20,
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
                                fontSize: 20, fontWeight:
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
