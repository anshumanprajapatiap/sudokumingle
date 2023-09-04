
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/gameHistoryModel.dart';
import '../utils/constants.dart';
import '../utils/globalMethodUtil.dart';

// Map<String, dynamic> gameDataMultiplayerConstantDataLocal = {
//   'Easy': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Hard': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Medium': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Master': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Grandmaster': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Do Not Try': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
// };
// Map<String, dynamic> gameDataSinglePlayerConstantDataLocal = {
//   'Easy': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Hard': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Medium': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Master': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Grandmaster': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
//   'Do Not Try': {
//     'won': 0,
//     'bestTime': '',
//     'worstTime': '',
//     'totalGames': 0,
//     'winningPercentage': 0.0,
//     'bestScore': 0,
//     'avgScore': 0,
//     'wonWithoutMistake': 0
//   },
// };


class FirebaseUserDataProvider with ChangeNotifier {
  bool _isGameHistoryDataFetched = false;
  final _currentAuthUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _practiceGameHistory = {};
  Map<String, dynamic> _onlineGameHistory = {};
  Map<String, dynamic> get getUserData => _userData;
  Map<String, dynamic> get getPracticeGameHistory => _practiceGameHistory;
  Map<String, dynamic> get getOnlineGameHistory => _onlineGameHistory;
  bool get getGameHistoryDataFetched => _isGameHistoryDataFetched;

  setGameHistoryDataFetched(){
    _isGameHistoryDataFetched = true;
    notifyListeners();
  }

  fetchCustomUserProfileData() async {

    DocumentSnapshot userSnapshotDoc = await FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid).get();

    _userData = {};
    if(userSnapshotDoc.exists){
      Map<String, dynamic> userData = userSnapshotDoc.data() as Map<String, dynamic>;

      _userData = {
        'userFirstName': _currentAuthUser!.displayName ?? '',
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
    setCustomUserProfileDataRank();
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
            'isWinner': element.get('winnerId') == _currentAuthUser!.uid ? true : false,
            'score':  element.get('playerId1') == _currentAuthUser!.uid ? element.get('player1Points') : element.get('player1Points'),
            'mistakes': element.get('playerId1') == _currentAuthUser!.uid ? element.get('player1Mistake') : element.get('player2Mistake')
          };
          onlineGameHistory.insert(
            0,
            gameData
          );
        });
    });
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
          'isWinner': element.get('winnerId')==_currentAuthUser!.uid ? true : false,
          'score': element.get('player1Points'),
          'mistakes': element.get('player1Mistake')
        };
        print(gameData);
        practiceGameHistory.insert(
          0,
          gameData
        );
      });
    });

    print('onlineGameHistory $onlineGameHistory');
    print('practiceGameHistory $practiceGameHistory');
    calculateStatistics(onlineGameHistory, practiceGameHistory);
    setGameHistoryDataFetched();
    notifyListeners();
  }

  calculateStatistics(List<Map<String, dynamic>> onlineGameHistory, List<Map<String, dynamic>> practiceGameHistory){
    Map<String, dynamic> gameDataMultiplayerConstantDataLocal = {
      'Easy': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Hard': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Medium': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Master': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Grandmaster': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Do Not Try': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
    };
    Map<String, dynamic> gameDataSinglePlayerConstantDataLocal = {
      'Easy': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Hard': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Medium': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Master': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Grandmaster': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Do Not Try': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
    };


    for (var game in onlineGameHistory) {
      Timestamp createdAtTimestamp = game['createdAt'];
      Timestamp endedAtTimestamp = game['endedAt'];
      DateTime createdAt = createdAtTimestamp.toDate();
      DateTime endedAt = endedAtTimestamp.toDate();
      Duration timeDifference = endedAt.difference(createdAt);
      String difficultyLevel = game['difficultyLevel'];

      if (gameDataMultiplayerConstantDataLocal.containsKey(difficultyLevel)) {
        gameDataMultiplayerConstantDataLocal[difficultyLevel]['won'] += game['isWinner'] ? 1 : 0;
        gameDataMultiplayerConstantDataLocal[difficultyLevel]['wonWithoutMistake'] += game['isWinner'] ?game['mistakes']==0 ?1 :0 :0;

        if(gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestTime'] == ''){
          gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestTime'] = timeDifference;
        }else{
          if(gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestTime'] > timeDifference){
            gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestTime'] = timeDifference;
          }
        }
        if(gameDataMultiplayerConstantDataLocal[difficultyLevel]['worstTime'] == ''){
          gameDataMultiplayerConstantDataLocal[difficultyLevel]['worstTime'] = timeDifference;
        }else{
          if(gameDataMultiplayerConstantDataLocal[difficultyLevel]['worstTime'] < timeDifference){
            gameDataMultiplayerConstantDataLocal[difficultyLevel]['worstTime'] = timeDifference;
          }
        }

        if(gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestScore'] < game['score']){
          print('${gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestScore']} ->  ${game['score']}');
          gameDataMultiplayerConstantDataLocal[difficultyLevel]['bestScore'] = game['score'];
        }
        gameDataMultiplayerConstantDataLocal[difficultyLevel]['avgScore'] += game['score'];
        gameDataMultiplayerConstantDataLocal[difficultyLevel]['totalGames'] += 1;
      }
    }

    // gameDataMultiplayer.forEach((key, value) {
    //   double winningPercentage = (value['won'] / value['totalGames']) * 100;
    //   gameDataMultiplayer[key]['winningPercentage'] = winningPercentage;
    // });

    _onlineGameHistory =  gameDataMultiplayerConstantDataLocal;



    for (var game in practiceGameHistory) {
      Timestamp createdAtTimestamp = game['createdAt'];
      Timestamp endedAtTimestamp = game['endedAt'];
      DateTime createdAt = createdAtTimestamp.toDate();
      DateTime endedAt = endedAtTimestamp.toDate();
      Duration timeDifference = endedAt.difference(createdAt);

      String difficultyLevel = game['difficultyLevel'];

      if (gameDataSinglePlayerConstantDataLocal.containsKey(difficultyLevel)) {
        gameDataSinglePlayerConstantDataLocal[difficultyLevel]['won'] += game['isWinner'] ? 1 : 0;
        gameDataSinglePlayerConstantDataLocal[difficultyLevel]['wonWithoutMistake'] += game['isWinner'] ?game['mistakes']==0 ?1 :0 :0;

        if(gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestTime'] == ''){
          gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestTime'] = timeDifference;
        }else{
          if(gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestTime'] > timeDifference){
            gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestTime'] = timeDifference;
          }
        }
        if(gameDataSinglePlayerConstantDataLocal[difficultyLevel]['worstTime'] == ''){
          gameDataSinglePlayerConstantDataLocal[difficultyLevel]['worstTime'] = timeDifference;
        }else{
          if(gameDataSinglePlayerConstantDataLocal[difficultyLevel]['worstTime'] < timeDifference){
            gameDataSinglePlayerConstantDataLocal[difficultyLevel]['worstTime'] = timeDifference;
          }
        }

        if(gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestScore'] < game['score']){
          print('${gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestScore']} ->  ${game['score']}');
          gameDataSinglePlayerConstantDataLocal[difficultyLevel]['bestScore'] = game['score'];
        }
        gameDataSinglePlayerConstantDataLocal[difficultyLevel]['avgScore'] += game['score'];
        gameDataSinglePlayerConstantDataLocal[difficultyLevel]['totalGames'] += 1;
      }

    }

    // gameDataSingleplayer.forEach((key, value) {
    //   double winningPercentage = (value['won'] / value['totalGames']) * 100;
    //   gameDataSingleplayer[key]['winningPercentage'] = winningPercentage;
    // });

    _practiceGameHistory =  gameDataSinglePlayerConstantDataLocal;

  }

  addUserGameHistory(GameHistoryModel gameData, {required bool isMultiplayer}) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection(Constants.CUSTOM_USER_PROFILE)
        .doc(_currentAuthUser!.uid);
    String gId = Uuid().v4();

    Map<String, dynamic> gameDataToAdd = {
      'gameId': gameData.gameId,
      'playerId1': isMultiplayer ? gameData.playerId1 : _currentAuthUser!.uid,
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

    updateGameDataOnLocalList(gameData.difficultyLevel, isMultiplayer, gameDataToAdd);
    int coinAdded = GlobalMethodUtil.getCoinValue(gameData.difficultyLevel, _currentAuthUser!.uid, gameData.winnerId, isMultiplayer: isMultiplayer );

    setCustomUserProfileDataCoin(coinAdded);
    setCustomUserProfileDataRank();
    notifyListeners();
  }

  void updateGameDataOnLocalList(String difficultyLevel, bool isMultiplayer, Map<String, dynamic> singleData) {

    if (!_practiceGameHistory.containsKey(difficultyLevel) || !_onlineGameHistory.containsKey(difficultyLevel)) {
      // If the difficulty level doesn't exist in the map, return.
      return;
    }
    Timestamp createdAtTimestamp = singleData['createdAt'];
    Timestamp endedAtTimestamp = singleData['endedAt'];
    DateTime createdAt = createdAtTimestamp.toDate();
    DateTime endedAt = endedAtTimestamp.toDate();
    Duration timeDifference = endedAt.difference(createdAt);

    if(isMultiplayer) {
      int score = singleData['player1Id'] == _currentAuthUser!.uid ? singleData['player1Points'] : singleData['player2Points'] ;
      _onlineGameHistory[difficultyLevel]['won'] += singleData['winnerId'] == _currentAuthUser!.uid ? 1 : 0;
      if(_onlineGameHistory[difficultyLevel]['bestTime'] == ''){
        _onlineGameHistory[difficultyLevel]['bestTime'] = timeDifference;
      }
      else{
        if(_onlineGameHistory[difficultyLevel]['bestTime'] > timeDifference){
          _onlineGameHistory[difficultyLevel]['bestTime'] = timeDifference;
        }
      }
      if(_onlineGameHistory[difficultyLevel]['worstTime'] == ''){
        _onlineGameHistory[difficultyLevel]['worstTime'] = timeDifference;
      }else{
        if(_onlineGameHistory[difficultyLevel]['worstTime'] < timeDifference){
          _onlineGameHistory[difficultyLevel]['worstTime'] = timeDifference;
        }
      }

      if(_onlineGameHistory[difficultyLevel]['bestScore'] < score){
        print('${_onlineGameHistory[difficultyLevel]['bestScore']} ->  $score}');
        _onlineGameHistory[difficultyLevel]['bestScore'] = score;
      }
      _onlineGameHistory[difficultyLevel]['avgScore'] += score;
      _onlineGameHistory[difficultyLevel]['totalGames']++;
      // _onlineGameHistory[difficultyLevel]['winningPercentage'] = (_onlineGameHistory[difficultyLevel]['won'] / _onlineGameHistory[difficultyLevel]['totalGames']) * 100;
    }
    else {
      int score = singleData['player1Points'];
      _practiceGameHistory[difficultyLevel]['won'] += singleData['isWinner'] == _currentAuthUser!.uid ? 1 : 0;
      _practiceGameHistory[difficultyLevel]['wonWithoutMistake'] += singleData['winnerId'] == _currentAuthUser!.uid ? singleData['player1Mistake'] == 0 ? 1 :0 :0;
      if(_practiceGameHistory[difficultyLevel]['bestTime'] == ''){
        _practiceGameHistory[difficultyLevel]['bestTime'] = timeDifference;
      }
      else{
        if(_practiceGameHistory[difficultyLevel]['bestTime'] > timeDifference){
          _practiceGameHistory[difficultyLevel]['bestTime'] = timeDifference;
        }
      }
      if(_practiceGameHistory[difficultyLevel]['worstTime'] == ''){
        _practiceGameHistory[difficultyLevel]['worstTime'] = timeDifference;
      }else{
        if(_practiceGameHistory[difficultyLevel]['worstTime'] < timeDifference){
          _practiceGameHistory[difficultyLevel]['worstTime'] = timeDifference;
        }
      }

      if(_practiceGameHistory[difficultyLevel]['bestScore'] < score){
        _practiceGameHistory[difficultyLevel]['bestScore'] = score;
      }
      _practiceGameHistory[difficultyLevel]['avgScore'] += score;
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
    Map<String, dynamic> gameDataMultiplayerConstantDataLocal = {
      'Easy': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Hard': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Medium': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Master': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Grandmaster': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Do Not Try': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
    };
    deleteAllDocumentsFromCollection(Constants.USER_GAME_HISTORY);
    _onlineGameHistory = gameDataMultiplayerConstantDataLocal;
    notifyListeners();
  }

  void deleteOfflineGameHistoryData(){
    Map<String, dynamic> gameDataSinglePlayerConstantDataLocal = {
      'Easy': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Hard': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Medium': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Master': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Grandmaster': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
      'Do Not Try': {
        'won': 0,
        'bestTime': '',
        'worstTime': '',
        'totalGames': 0,
        'winningPercentage': 0.0,
        'bestScore': 0,
        'avgScore': 0,
        'wonWithoutMistake': 0
      },
    };
    deleteAllDocumentsFromCollection(Constants.USER_PRACTICE_HISTORY);
    _practiceGameHistory = gameDataSinglePlayerConstantDataLocal;
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