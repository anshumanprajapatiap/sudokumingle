
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/utils/constants.dart';
import 'package:uuid/uuid.dart';

import '../utils/sudokuGeneratorNewAlgorithm.dart';

List<int> flattenArray(List<List<int?>> nestedArray) {
  List<int> flattenedArray = [];
  for (int i = 0; i < nestedArray.length; i++) {
    for (int j = 0; j < nestedArray[i].length; j++) {
      int value = nestedArray[i][j] ?? 0;
      flattenedArray.add(value);
    }
  }
  return flattenedArray;
}

List<List<int>> convertToNestedArray(List<dynamic> flattenedArray) {
  List<List<int>> nestedArray = [];

  for (int i = 0; i < 9; i++) {
    List<int> row = [];
    for (int j = 0; j < 9; j++) {
      row.add(flattenedArray[i * 9 + j]);
    }
    nestedArray.add(row);
  }
  return nestedArray;
}

List<List<int?>> convertToNestedArrayNull(List<dynamic> flattenedArray) {
  List<List<int?>> nestedArray = [];

  for (int i = 0; i < 9; i++) {
    List<int?> row = [];
    for (int j = 0; j < 9; j++) {
      if(flattenedArray[i * 9 + j]==0){
        row.add(null);
      }else{
        row.add(flattenedArray[i * 9 + j]);
      }

    }
    nestedArray.add(row);
  }
  return nestedArray;
}

class FirebaseGamePoolProvider with ChangeNotifier {

  Map<String, dynamic> _gameData = {
    'gameId': '',
    'playerId1': '',
    'playerId2': '',
    'winnerId': '',
    'createdAt': '',
    'endedAt': '',
    'createdBy': '',
    'player1Points': 0,
    'player2Points': 0,
    'player1Mistake': 0,
    'player2Mistake': 0,
    'isScoreUpdate1': false,
    'isScoreUpdate2': false,
    'isGameEnded': false,
    'isSkippedPlayer1': false,
    'isSkippedPlayer2': false,
    'correctSudoku': [],
    'toBeSolvedSudoku': [],
    'difficulty': []
  };

  List<List<int>> correctSudokuToPass = [];
  List<List<int?>> toBeSolvedSudokuToPass = [];
  bool _isGameStarted = false;
  bool _isCounterStarted = false;

  List<List<int>> get getCorrectSudoku => correctSudokuToPass;
  List<List<int?>> get getToBeSolvedSudoku => toBeSolvedSudokuToPass;
  bool get getGameStarted => _isGameStarted;
  bool get getIsCounterStarted => _isCounterStarted;


  gameStarted(){
    _isGameStarted = true;
    _isCounterStarted = true;
    notifyListeners();
  }

  void updateCounterStatus(){
      _isCounterStarted = false;
      notifyListeners();
  }


  void generatePuzzleForGame(Difficulty difficulty, String gId,
      String playerId1, String playerId2, Timestamp createdAt,
      String createdBy) {
    print('generating puzzle');
    final sudokuPuzzler = SudokuGeneratorAgorithmV2();
    Map<String, dynamic> puzzleData = sudokuPuzzler.generatePuzzle(difficulty);
    print('puzzleon which puzzle is created Id ${gId}');
    createActivePuzzleOnActiveGamePool(
        gId, playerId1, playerId2, createdAt, createdBy, puzzleData);
  }

  createActivePuzzleOnActiveGamePool(String gameId, String playerId1,
      String playerId2, Timestamp createdAt,
      String createdBy, Map<String, dynamic> puzzleData) async {
    correctSudokuToPass = [];
    toBeSolvedSudokuToPass = [];
    try {
      CollectionReference activePuzzleGameCollection = FirebaseFirestore
          .instance.collection(Constants.ACTIVE_GAME_POOL);
      DocumentReference gameDocument = activePuzzleGameCollection.doc(gameId);

      correctSudokuToPass = puzzleData['correctSudoku'];
      toBeSolvedSudokuToPass = puzzleData['toBeSolvedSudoku'];
      notifyListeners();

      // Set the data for the user document
      List<int> correctSudoku = flattenArray(puzzleData['correctSudoku']);
      List<int> toBeSolvedSudoku = flattenArray(puzzleData['toBeSolvedSudoku']);

      Map<String, dynamic> gameData = {
        'gameId': gameId,
        'playerId1': playerId1,
        'playerId2': playerId2,
        'winnerId': '',
        'createdAt': createdAt,
        'endedAt': '',
        'createdBy': createdBy,
        'player1Points': 0,
        'player2Points': 0,
        'player1Mistake': 0,
        'player2Mistake': 0,
        'isScoreUpdate1': false,
        'isScoreUpdate2': false,
        'isGameEnded': false,
        'isSkippedPlayer1': false,
        'isSkippedPlayer2': false,
        'correctSudoku': correctSudoku,
        'toBeSolvedSudoku': toBeSolvedSudoku,
        'difficulty': DifficultyEnumToString(puzzleData['difficulty']).name
      };

      await gameDocument.set(gameData);

      print('ActivePuzzlePool Created!');
    } catch (error) {
      print('Error ActivePuzzlePool: $error');
    }
  }


  fetchPuzzleForGame(String gameId) async {
    correctSudokuToPass = [];
    toBeSolvedSudokuToPass = [];
    print('fetingpuzzleDataForGameFucntion ${gameId}');
    CollectionReference activePuzzlePoolCollection = FirebaseFirestore.instance
        .collection(Constants.ACTIVE_GAME_POOL);
    DocumentSnapshot snapshot = await activePuzzlePoolCollection.doc(gameId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> documentData = snapshot.data() as Map<String, dynamic>;
      //print(documentData);
      List<dynamic> c = documentData!['correctSudoku'];
      List<dynamic> p = documentData!['toBeSolvedSudoku'];
      print('c $c');
      print('p $p');

      List<List<int>> correctSudoku = convertToNestedArray(c);
      List<List<int?>> toBeSolvedSudoku = convertToNestedArrayNull(p);
      print('correctSudoku $correctSudoku');
      print('toBeSolvedSudoku $toBeSolvedSudoku');
      //List<List<int?>> toBeSolvedSudoku = convertToNestedArray(documentData!['toBeSolvedSudoku']);
      print('converting puzzleData');
      // setState(() {
      //   correctSudokuToPass = correctSudoku;
      //   toBeSolvedSudokuToPass = toBeSolvedSudoku;
      // });

      correctSudokuToPass = correctSudoku;
      toBeSolvedSudokuToPass = toBeSolvedSudoku;
      notifyListeners();
    }
  }

}