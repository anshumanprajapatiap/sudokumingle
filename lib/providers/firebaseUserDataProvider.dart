
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/gameHistoryModel.dart';
import '../utils/constants.dart';




class FirebaseUserDataProvider with ChangeNotifier {
  Map<String, dynamic> gameDataMultiplayerConstantData = {
    'Easy': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Hard': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Medium': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Master': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Grandmaster': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Do Not Try': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
  };
  Map<String, dynamic> gameDataSingleplayerConstantData = {
    'Easy': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Hard': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Medium': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Master': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Grandmaster': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
    'Do Not Try': {
      'won': 0,
      'bestTime': '',
      'worstTime': '',
      'totalGames': 0,
      'winningPercentage': 0.0,
    },
  };

  final _currentAuthUser = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _practiceGameHistory = {};
  Map<String, dynamic> _onlineGameHistory = {};

  Map<String, dynamic> get getUserData {
    return _userData;
  }
  Map<String, dynamic> get getPracticeGameHistory{
    return _practiceGameHistory;
  }
  Map<String, dynamic> get getOnlineGameHistory{
    return _onlineGameHistory;
  }

  fetchCustomUserProfileData() async {

    DocumentSnapshot userSnapshotDoc = await FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid).get();

    _userData = {};
    if(userSnapshotDoc.exists){
      Map<String, dynamic> userData = userSnapshotDoc.data() as Map<String, dynamic>;

      _userData = {
        'userFirstName': _currentAuthUser.displayName,
        'coins': userData['mingleCoins'],
        'userRank': userData['rank'],
        'userAvatar': userData['userAvatar']
      };
    }
    setCustomUserProfileDataRank();
    notifyListeners();
    return;
  }

  setCustomUserProfileDataCoin(int coin) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid);

    _userData['coins'] += coin;
    await documentReference.update({
      'mingleCoins': _userData['coins']
    });

    notifyListeners();
  }

  setCustomUserProfileDataRank() async {
    DocumentReference documentReference =  FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid);

    int currentUserRank = 1;
    await FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .get()
        .then((QuerySnapshot allUserData){
      allUserData.docs.forEach((element) {
        if(_currentAuthUser != element.reference.id){
          if(_userData['coins'] < element.get('mingleCoins')){
            currentUserRank++;
          }
        }
      });
    });
    print(currentUserRank);
    _userData['userRank'] = currentUserRank;
    await documentReference.update({
      'rank': currentUserRank
    });
  }

  fetchUserGameHistory() async{

    List<Map<String, dynamic>> onlineGameHistory = [];
    List<Map<String, dynamic>> practiceGameHistory = [];

    await FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid)
        .collection(Constants.USER_GAME_HISTORY)
        .get().then((QuerySnapshot onlineGameData) {

        onlineGameData.docs.forEach((element) {
          Map<String, dynamic> gameData = {
            'difficultyLevel': element.get('difficulty'),
            'createdAt': element.get('createdAt'),
            'endedAt': element.get('endedAt'),
            'isWinner': element.get('winnerId') == _currentAuthUser!.uid ? true : false
          };
          onlineGameHistory.insert(
            0,
            gameData
          );
        });
    });

    print(onlineGameHistory);

    await FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid)
        .collection(Constants.USER_PRACTICE_HISTORY)
        .get().then((QuerySnapshot offlineGameData) {

      offlineGameData.docs.forEach((element) {
        Map<String, dynamic> gameData = {
          'difficultyLevel': element.get('difficulty'),
          'createdAt': element.get('createdAt'),
          'endedAt': element.get('endedAt'),
        };
        print(gameData);
        practiceGameHistory.insert(
          0,
          gameData
        );
      });
    });
    print(onlineGameHistory);

    calculateStatistics(onlineGameHistory, practiceGameHistory);

    notifyListeners();
  }

  calculateStatistics(List<Map<String, dynamic>> onlineGameHistory, List<Map<String, dynamic>> practiceGameHistory){

    for (var game in onlineGameHistory) {
      String difficultyLevel = game['difficultyLevel'];

      if (gameDataMultiplayerConstantData.containsKey(difficultyLevel)) {
        gameDataMultiplayerConstantData[difficultyLevel]['won'] += game['isWinner'] ? 1 : 0;

        // if (gameDataMultiplayer[difficultyLevel]['bestTime'] == '' ||
        //     game['endedAt'] < gameDataMultiplayer[difficultyLevel]['bestTime']) {
        //   gameDataMultiplayer[difficultyLevel]['bestTime'] = game['endedAt'];
        // }
        //
        // if (gameDataMultiplayer[difficultyLevel]['worstTime'] == '' ||
        //     game['endedAt'] > gameDataMultiplayer[difficultyLevel]['worstTime']) {
        //   gameDataMultiplayer[difficultyLevel]['worstTime'] = game['endedAt'];
        // }

        gameDataMultiplayerConstantData[difficultyLevel]['totalGames'] += 1;
      }
    }

    // gameDataMultiplayer.forEach((key, value) {
    //   double winningPercentage = (value['won'] / value['totalGames']) * 100;
    //   gameDataMultiplayer[key]['winningPercentage'] = winningPercentage;
    // });

    _onlineGameHistory =  gameDataMultiplayerConstantData;



    for (var game in practiceGameHistory) {
      String difficultyLevel = game['difficultyLevel'];

      if (gameDataSingleplayerConstantData.containsKey(difficultyLevel)) {
        // gameDataMultiplayer[difficultyLevel]['won'] += game['isWinner'] ? 1 : 0;

        // if (gameDataSingleplayer[difficultyLevel]['bestTime'] == '' ||
        //     game['endedAt'] < gameDataSingleplayer[difficultyLevel]['bestTime']) {
        //   gameDataSingleplayer[difficultyLevel]['bestTime'] = game['endedAt'];
        // }
        //
        // if (gameDataSingleplayer[difficultyLevel]['worstTime'] == '' ||
        //     game['endedAt'] > gameDataSingleplayer[difficultyLevel]['worstTime']) {
        //   gameDataSingleplayer[difficultyLevel]['worstTime'] = game['endedAt'];
        // }

        gameDataSingleplayerConstantData[difficultyLevel]['totalGames'] += 1;
      }
    }

    // gameDataSingleplayer.forEach((key, value) {
    //   double winningPercentage = (value['won'] / value['totalGames']) * 100;
    //   gameDataSingleplayer[key]['winningPercentage'] = winningPercentage;
    // });

    _practiceGameHistory =  gameDataSingleplayerConstantData;

  }

  addUserGameHistory(GameHistoryModel gameData, {required bool isMultiplayer}) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid);
    String gId = Uuid().v4();

    Map<String, dynamic> gameDataToAdd = {
      'gameId': gameData.gameId,
      'playerId1': isMultiplayer ? gameData.playerId1 : _currentAuthUser.uid,
      'playerId2': gameData.playerId2,
      'difficulty': gameData.difficultyLevel,
      'winnerId': gameData.winnerId,
      'createdAt': gameData.createdAt,
      'endedAt': gameData.endedAt,
      'player1Points': gameData.player1Points,
      'player2Points': gameData.player2Points,
      'player1Mistake': gameData.player1Mistake,
      'player2Mistake': gameData.player2Mistake,
      'createdBy': gameData.createdBy
    };

    if(isMultiplayer){
      CollectionReference passiveUserGamePoolCollection = userDocRef.collection(Constants.USER_GAME_HISTORY);
      DocumentReference userGameDocument = passiveUserGamePoolCollection.doc(gId);
      await userGameDocument.set(gameDataToAdd);
      //add to local list as well

    }
    else{
      CollectionReference passiveUserGamePoolCollection = userDocRef.collection(Constants.USER_PRACTICE_HISTORY);
      DocumentReference userGameDocument = passiveUserGamePoolCollection.doc(gId);
      await userGameDocument.set(gameDataToAdd);
      //add to local list as well
    }

    updateGameDataMultiplayer(gameData.difficultyLevel, isMultiplayer, gameDataToAdd);
    setCustomUserProfileDataCoin(100);
    setCustomUserProfileDataRank();
    notifyListeners();
  }

  void updateGameDataMultiplayer(String difficultyLevel, bool isMultiplayer, Map<String, dynamic> singleData) {

    if (!_practiceGameHistory.containsKey(difficultyLevel) || !_onlineGameHistory.containsKey(difficultyLevel)) {
      // If the difficulty level doesn't exist in the map, return.
      return;
    }
    if(isMultiplayer) {
      _onlineGameHistory[difficultyLevel]['won'] += singleData['winnerId'] == _currentAuthUser!.uid ? 1 : 0;
      _onlineGameHistory[difficultyLevel]['totalGames']++;
      // _onlineGameHistory[difficultyLevel]['winningPercentage'] = (_onlineGameHistory[difficultyLevel]['won'] / _onlineGameHistory[difficultyLevel]['totalGames']) * 100;
    }
    else {
      _onlineGameHistory[difficultyLevel]['won'] += singleData['isWinner'] == _currentAuthUser!.uid ? 1 : 0;
      _practiceGameHistory[difficultyLevel]['totalGames']++;
      // _practiceGameHistory[difficultyLevel]['winningPercentage'] = (_practiceGameHistory[difficultyLevel]['won'] / _practiceGameHistory[difficultyLevel]['totalGames']) * 100;

    }
    notifyListeners();

  }

  void addOnlineGameDataToGameHistory(String gameId) async{
     DocumentSnapshot gameDataSnapshot = await FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId).get();

    if(gameDataSnapshot.exists){
      Map<String, dynamic> gameData = gameDataSnapshot.data() as Map<String, dynamic>;

      GameHistoryModel gameDataObj = GameHistoryModel(
          gameId: gameData['gameId'],
          playerId1: gameData['playerId1'],
          playerId2: gameData['playerId2'],
          difficultyLevel: gameData['difficulty'],
          winnerId: gameData['winnerId'],
          createdAt: gameData['createdAt'],
          endedAt: gameData['endedAt'],
          player1Points: gameData['player1Points'],
          player2Points: gameData['player2Points'],
          player1Mistake: gameData['player1Mistake'],
          player2Mistake: gameData['player1Mistake'],
          createdBy: gameData['createdBy']
      );
      print('data to added on OnlineGame History');

      addUserGameHistory(gameDataObj, isMultiplayer: true,);

    }

  }

  void deleteOnlineGameHistoryData(){
    deleteAllDocumentsFromCollection(Constants.USER_GAME_HISTORY);
    _onlineGameHistory = gameDataMultiplayerConstantData;
    notifyListeners();
  }

  void deleteOfflineGameHistoryData(){
    deleteAllDocumentsFromCollection(Constants.USER_PRACTICE_HISTORY);
    _practiceGameHistory = gameDataSingleplayerConstantData;
    notifyListeners();
  }

  Future<void> deleteAllDocumentsFromCollection(String collectionName) async {
    final collectionRef = FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid)
        .collection(collectionName);

    // Fetch the documents from the collection
    final snapshot = await collectionRef.get();

    // Create a batch instance
    final batch = FirebaseFirestore.instance.batch();

    // Add delete operation for each document to the batch
    snapshot.docs.forEach((doc) {
      batch.delete(doc.reference);
    });

    // Commit the batch to delete all documents
    await batch.commit();
  }
}