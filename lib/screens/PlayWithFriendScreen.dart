import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/firebaseGamePoolProvider.dart';
import 'package:sudokumingle/utils/globalMethodUtil.dart';
import 'package:sudokumingle/widgets/dualPlayerSudokuGridWidget.dart';
import 'package:sudokumingle/widgets/gameSearchWidget.dart';
import 'package:sudokumingle/widgets/sudokuGridWidget.dart';
import 'package:sudokumingle/widgets/winnerAnnouncement.dart';
import 'package:uuid/uuid.dart';

import '../providers/firebaseRoomManagementProvider.dart';
import '../providers/firebaseUserDataProvider.dart';
import '../providers/firebaseUserDataProvider.dart';
import '../utils/SudokuBoardEnums.dart';
import '../utils/adMobUtility.dart';
import '../utils/constants.dart';
import '../utils/sudokuGeneratorNewAlgorithm.dart';
import '../widgets/liveUserWidget.dart';
import '../widgets/userSearchingWidget.dart';

class PlayWithFriendScreen extends StatefulWidget {
  Difficulty difficultyLevel;
  String roomId;

  PlayWithFriendScreen({required this.difficultyLevel, required this.roomId});

  @override
  State<PlayWithFriendScreen> createState() => _PlayWithFriendScreenState();
}

class _PlayWithFriendScreenState extends State<PlayWithFriendScreen> with WidgetsBindingObserver{

  StreamController<int> _counterController = StreamController<int>();
  int _counter = 3;

  // bool hideBackButton = false;
  String difficulty = "";
  // bool _isLoading = true;
  // bool _isInActiveUserTable = true;
  // bool _isSeaching = true;
  // bool _isGameStarted = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Timer? searchTimer;
  // List<List<int>>? correctSudokuToPass;
  // List<List<int?>>? toBeSolvedSudokuToPass;
  // String _counter = '3';
  // bool? _isFirst = true;
  // Timestamp screenCreatedAt = Timestamp.now();

  // Map<String, int> globalVarliveUsersCountByDifficulty = {
  //   'Easy': 0,
  //   'Medium': 0,
  //   'Hard': 0,
  //   'Master': 0,
  //   'Grandmaster': 0,
  //   'Do Not Try': 0,
  // };

  // String? gameId;
  // String? puzzleId;
  // bool _isGameOver = false;
  // bool _isGameInit = true;
  // bool _isDataFetched = false;


  // void putUserIntoActiveUser() async{
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if(currentUser==null){
  //     GlobalMethodUtil.warningDialog(
  //         title: 'User Do Not Exit',
  //         subtitle: 'Please login user to Play With Friends',
  //         fct: () {},
  //         context: context
  //     );
  //     return;
  //   }
  //   String _currentUserId = currentUser!.uid;
  //   addToActiveUserPool(_currentUserId, currentUser!.displayName.toString(), difficulty);
  //   return;
  // }
  //
  // void addToActiveUserPool(String userId, String username, String difficultyLevel) async {
  //   try {
  //     // Reference to the ActiveUserPool collection
  //     CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection('ActiveUserPool');
  //
  //     // Create a document with the current user ID as the document ID
  //     DocumentReference userDocument = activeUserPoolCollection.doc(userId);
  //
  //     // Set the data for the user document
  //     await userDocument.set({
  //       'userId': userId,
  //       'username': username,
  //       'difficultyLevel': difficultyLevel,
  //       'createdAt': screenCreatedAt,
  //       'inGame': false
  //     }, SetOptions(merge: true),);
  //
  //     print('User data added to ActiveUserPool successfully!');
  //   } catch (error) {
  //     print('Error adding user data to ActiveUserPool: $error');
  //   }
  // }
  //
  // void removeCurrentUserFromActiveUserPool(){
  //
  //   if (currentUser == null) {
  //     return;
  //   }
  //   String currentUserId = currentUser!.uid;
  //   removeUserFromActiveUserPool(currentUserId);
  //
  // }

  // void removeUserFromActiveUserPool(String userId) async {
  //   FirebaseGlobalMethodUtil.deleteDocument(Constants.ACTIVE_USER_POOL, userId);
  // }

  // void fetchUserFromActivePool() async {
  //   String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //
  //   if (currentUserId == null) {
  //     return;
  //   }
  //
  //   CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection('ActiveUserPool');
  //   try{
  //     QuerySnapshot snapshot = await activeUserPoolCollection.get();
  //     List<QueryDocumentSnapshot> documents = snapshot.docs.where((doc) => doc.id != currentUserId).toList();
  //     for (QueryDocumentSnapshot document in documents) {
  //       Map<String, dynamic>? documentData = document.data() as Map<String, dynamic>?;
  //
  //       if (documentData != null) {
  //         String userId = documentData['userId'] as String? ?? '';
  //         String username = documentData['username'] as String? ?? '';
  //         String difficultyLevel = documentData['difficultyLevel'] as String? ??
  //             '';
  //         if (difficultyLevel == DifficultyEnumToString(widget.difficultyLevel).name) {
  //           // The difficulty level matches, perform your desired action
  //           print('User found in ActiveUserPool: $userId - $username - $difficultyLevel');
  //           //return;
  //         }
  //       }
  //     }
  //     print('data fetched - No User Found');
  //   } catch (error) {
  //     print('Error fetching users from ActiveUserPool: $error');
  //   }
  //
  // }

  // Future<bool> isDocumentExists(String documentId) async {
  //   CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection('ActiveUserPool');
  //
  //   DocumentSnapshot snapshot = await activeUserPoolCollection.doc(documentId).get();
  //   if(snapshot.exists) {
  //     Map<String, dynamic>? documentData = snapshot.data() as Map<
  //         String,
  //         dynamic>?;
  //     if (documentData!['inGame']) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // List<int> flattenArray(List<List<int?>> nestedArray) {
  //   List<int> flattenedArray = [];
  //   for (int i = 0; i < nestedArray.length; i++) {
  //     for (int j = 0; j < nestedArray[i].length; j++) {
  //       int value = nestedArray[i][j] ?? 0;
  //       flattenedArray.add(value);
  //     }
  //   }
  //   return flattenedArray;
  // }

  // List<List<int>> convertToNestedArray(List<dynamic> flattenedArray) {
  //   List<List<int>> nestedArray = [];
  //
  //   for (int i = 0; i < 9; i++) {
  //     List<int> row = [];
  //     for (int j = 0; j < 9; j++) {
  //       row.add(flattenedArray[i * 9 + j]);
  //     }
  //     nestedArray.add(row);
  //   }
  //
  //   setState(() {
  //     // Store the nestedArray in state if needed
  //   });
  //
  //   print(nestedArray);
  //   return nestedArray;
  // }

  // List<List<int?>> convertToNestedArrayNull(List<dynamic> flattenedArray) {
  //   List<List<int?>> nestedArray = [];
  //
  //   for (int i = 0; i < 9; i++) {
  //     List<int?> row = [];
  //     for (int j = 0; j < 9; j++) {
  //       if(flattenedArray[i * 9 + j]==0){
  //         row.add(null);
  //       }else{
  //         row.add(flattenedArray[i * 9 + j]);
  //       }
  //
  //     }
  //     nestedArray.add(row);
  //   }
  //
  //   setState(() {
  //     // Store the nestedArray in state if needed
  //   });
  //
  //   print(nestedArray);
  //   return nestedArray;
  // }

  // String generatePuzzle(){
  //   final sudokuPuzzler = SudokuGeneratorAgorithmV2();
  //   Map<String, dynamic> puzzleData= sudokuPuzzler.generatePuzzle(widget.difficultyLevel);
  //   // puzzleData.addAll({
  //   //   'createdBy': currentUser!.uid,
  //   //   'createdAt':screenCreatedAt
  //   // });
  //   String pId = Uuid().v4();
  //   print('puzzleon which puzzle is created Id ${pId}');
  //   createActivePuzzleOnActivePuzzlePool(pId, puzzleData);
  //   return pId;
  // }

  // createActivePuzzleOnActivePuzzlePool(String puzzleId, Map<String, dynamic> puzzleData) async {
  //   try {
  //     // Reference to the ActiveUserPool collection
  //     CollectionReference activePuzzlePoolCollection = FirebaseFirestore.instance.collection('ActivePuzzlePool');
  //     // Create a document with the current user ID as the document ID
  //     DocumentReference userDocument = activePuzzlePoolCollection.doc(puzzleId);
  //
  //     // Set the data for the user document
  //     List<int> correctSudoku = flattenArray(puzzleData['correctSudoku']);
  //     List<int> toBeSolvedSudoku = flattenArray(puzzleData['toBeSolvedSudoku']);
  //     print(toBeSolvedSudoku);
  //     await userDocument.set({
  //       'puzzleId': puzzleId,
  //       'correctSudoku': correctSudoku,
  //       'toBeSolvedSudoku': toBeSolvedSudoku,
  //       'difficulty': DifficultyEnumToString(puzzleData['difficulty']).name
  //     });
  //
  //     print('ActivePuzzlePool Created!');
  //   } catch (error) {
  //     print('Error ActivePuzzlePool: $error');
  //   }
  // }

  // Future<void> fetchPuzzleForGame(String puzzleId) async {
  //   print('fetingpuzzleDataForGameFucntion ${puzzleId}');
  //   CollectionReference activePuzzlePoolCollection = FirebaseFirestore.instance.collection('ActivePuzzlePool');
  //   DocumentSnapshot snapshot = await activePuzzlePoolCollection.doc(puzzleId).get();
  //
  //   if(snapshot.exists){
  //     Map<String, dynamic> documentData = snapshot.data() as Map<String, dynamic>;
  //     //print(documentData);
  //     List<dynamic> c = documentData!['correctSudoku'];
  //     List<dynamic> p = documentData!['toBeSolvedSudoku'];
  //     print('c $c');
  //     print('p $p');
  //
  //     List<List<int>> correctSudoku= convertToNestedArray(c);
  //     List<List<int?>> toBeSolvedSudoku= convertToNestedArrayNull(p);
  //     print('correctSudoku $correctSudoku');
  //     print('toBeSolvedSudoku $toBeSolvedSudoku');
  //     //List<List<int?>> toBeSolvedSudoku = convertToNestedArray(documentData!['toBeSolvedSudoku']);
  //     print('converting puzzleData');
  //     setState(() {
  //       correctSudokuToPass = correctSudoku;
  //       toBeSolvedSudokuToPass = toBeSolvedSudoku;
  //     });
  //     //await Future.delayed(Duration(seconds: 6), () {print('deplayed2');});
  //   }
  // }

  // void createGameOnActiveGamePool(String gameIdGenerated, String player2UserId) async {
  //   print('GENERATING PUZZLE');
  //   String puzzleIdTemp = generatePuzzle();
  //   print('creating game');
  //   try {
  //     // Reference to the ActiveUserPool collection
  //
  //     CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL);
  //     // Create a document with the current user ID as the document ID
  //     DocumentReference userDocument = activeUserPoolCollection.doc(gameIdGenerated);
  //
  //     // Set the data for the user document
  //     await userDocument.set({
  //       'gameId': gameIdGenerated,
  //       'playerId1': currentUser!.uid,
  //       'playerId2': player2UserId,
  //       'puzzleId': puzzleIdTemp,
  //       'winnerId': '',
  //       'createdAt': screenCreatedAt,
  //       'endedAt': screenCreatedAt,
  //       'createdBy': currentUser!.uid,
  //       'player1Points': 0,
  //       'player2Points': 0,
  //       'player1Mistake': 0,
  //       'player2Mistake': 0,
  //       'isScoreUpdate1': false,
  //       'isScoreUpdate2': false,
  //       'isGameEnded': false,
  //       'isSkippedPlayer1': false,
  //       'isSkippedPlayer2': false,
  //     });
  //
  //     print('ActiveGamePool Created!');
  //     setState(() {
  //       gameId = gameIdGenerated;
  //       puzzleId = puzzleIdTemp;
  //     });
  //     fetchPuzzleForGame(puzzleId!);
  //
  //   } catch (error) {
  //     print('ActiveGamePool: $error');
  //   }
  // }

  // void generateGame(String player2UserId) async {
  //   print('generating game');
  //   CollectionReference activeGamePoolCollection = FirebaseFirestore.instance.collection('ActiveGamePool');
  //   String gameIDByThisUser = currentUser!.uid+'-'+player2UserId;
  //   String gameIDByOtherUser = player2UserId+'-'+currentUser!.uid;
  //
  //   if(_isFirst!){
  //     createGameOnActiveGamePool(gameIDByThisUser, player2UserId);
  //     // DocumentSnapshot docRef = await activeGamePoolCollection.doc(gameIDByThisUser).get();
  //   }
  //   else{
  //     while(true){
  //       print(gameIDByOtherUser);
  //       DocumentSnapshot docRef = await activeGamePoolCollection.doc(gameIDByOtherUser).get();
  //       if(docRef.exists){
  //
  //           Map<String, dynamic>? documentData = docRef.data() as Map<String, dynamic>?;
  //           String puzzleIdTemp = documentData!['puzzleId'] as String? ?? '';
  //           print('puzzleIdTemp $puzzleIdTemp');
  //           setState(() {
  //             gameId = gameIDByOtherUser;
  //             puzzleId = puzzleIdTemp;
  //           });
  //           print('puzzleId $puzzleId');
  //           break;
  //       }
  //     }
  //   }
  //   print('now will fetch puzzle data for $puzzleId');
  //
  //   fetchPuzzleForGame(puzzleId!);
  //
  // }

  // void setCurrentUserFromActiveUserPoolTrue(){
  //   if (currentUser == null) {
  //     return;
  //   }
  //   String currentUserId = currentUser!.uid;
  //   updateInGameStatus(currentUserId);
  // }

  // Future<void> updateInGameStatus(String userId) async {
  //   try {
  //     // Reference to the ActiveUserPool collection
  //     CollectionReference activeUserPoolCollection =
  //     FirebaseFirestore.instance.collection('ActiveUserPool');
  //
  //     // Get the document reference for the user with the given userId
  //     DocumentReference userDocument = activeUserPoolCollection.doc(userId);
  //
  //     // Update the 'inGame' field to true
  //     await userDocument.update({'inGame': true});
  //
  //     print('User inGame status updated successfully!');
  //   } catch (error) {
  //     print('Error updating user inGame status: $error');
  //   }
  // }

  // Future<void> onBoardToGame(String player2UserId) async {
  //   bool isExists = await isDocumentExists(player2UserId);
  //   //bool isExistsCurrent = await isDocumentExists(currentUser!.uid);
  //
  //   await Future.delayed(Duration(seconds: 2), () {print('deplayed1');});
  //
  //   if (isExists) {
  //     print('game will start soon');
  //     setState(() {
  //       _isSeaching = false;
  //     });
  //     print('_isSeaching1 $_isSeaching');
  //     print('_isInActiveUserTable1 $_isInActiveUserTable');
  //     print('_isGameStarted1 $_isGameStarted');
  //     await Future.delayed(Duration(seconds: 2), () {print('deplayed1');});
  //
  //     //removeCurrentUserFromActiveUserPool();
  //     // removeUserFromActiveUserPool(player2UserId);
  //     setCurrentUserFromActiveUserPoolTrue();
  //
  //     setState(() {
  //       _isInActiveUserTable = false;
  //     });
  //     print('_isSeaching2 $_isSeaching');
  //     print('_isInActiveUserTable2 $_isInActiveUserTable');
  //     print('_isGameStarted2 $_isGameStarted');
  //     //await Future.delayed(Duration(seconds: 2), () {print('deplayed2');});
  //
  //     generateGame(player2UserId);
  //     print('game Created with $player2UserId');
  //
  //     setState(() {
  //       _isGameStarted = true;
  //     });
  //     await Future.delayed(Duration(seconds: 1), () {print('deplayed3');});
  //     setState(() {
  //       // _counter = '2';
  //     });
  //     await Future.delayed(Duration(seconds: 1), () {print('deplayed3');});
  //     setState(() {
  //       // _counter = '1';
  //     });
  //     await Future.delayed(Duration(seconds: 1), () {print('deplayed3');});
  //     setState(() {
  //       // _counter = 'GO!';
  //     });
  //     await Future.delayed(Duration(seconds: 1), () {print('deplayed3');});
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     Timer(Duration(seconds: 5), () {
  //       setState(() {
  //         hideBackButton = true;
  //       });
  //     });
  //   } else {
  //     print('Document with ID $player2UserId does not exist');
  //     fetchUserFromActivePoolContinuously();
  //   }
  //
  // }



  // void fetchUserFromActivePoolContinuously() async {
  //   setState(() {
  //     hideBackButton = true;
  //   });
  //   String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //
  //   if (currentUserId == null) {
  //     return;
  //   }
  //
  //   CollectionReference activeUserPoolCollection = FirebaseFirestore.instance.collection('ActiveUserPool');
  //   searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     QuerySnapshot snapshot = await activeUserPoolCollection.get();
  //     List<QueryDocumentSnapshot> documents = snapshot.docs.where((doc) => doc.id != currentUserId).toList();
  //     Map<String, int> localVarliveUsersCountByDifficulty = {
  //       'Easy': 0,
  //       'Medium': 0,
  //       'Hard': 0,
  //       'Master': 0,
  //       'Grandmaster': 0,
  //       'Do Not Try': 0,
  //     };
  //     for (QueryDocumentSnapshot document in documents) {
  //       Map<String, dynamic>? documentData = document.data() as Map<String, dynamic>?;
  //
  //       if (documentData != null) {
  //         String userId = documentData['userId'] as String? ?? '';
  //         String username = documentData['username'] as String? ?? '';
  //         String difficultyLevelOfUser = documentData['difficultyLevel'] as String? ?? '';
  //         Timestamp createdAt = documentData['createdAt'];
  //         bool? isGame = documentData['inGame'];
  //         print('createdAtHere $createdAt');
  //
  //         if(isGame!=null && isGame == false){
  //           localVarliveUsersCountByDifficulty[difficultyLevelOfUser] = 1 + localVarliveUsersCountByDifficulty[difficultyLevelOfUser]!;
  //         }
  //
  //         if (difficultyLevelOfUser == difficulty && isGame!=null && isGame == false) {
  //           // The difficulty level matches, perform your desired action
  //           setState(() {
  //             hideBackButton = false;
  //           });
  //           print('User found in ActiveUserPool: $userId - $username - $difficultyLevelOfUser - $createdAt');
  //           // Stop searching by canceling the timer
  //           searchTimer?.cancel();
  //           int comparisonResult = screenCreatedAt.compareTo(createdAt);
  //           print('comparisonResult $comparisonResult');
  //           if (comparisonResult<=0) {
  //             setState(() {
  //               _isFirst = true;
  //             });
  //           } else {
  //             setState(() {
  //               _isFirst = false;
  //             });
  //           }
  //           onBoardToGame(userId);
  //           break;
  //         }
  //         else{
  //           print('User Not found in ActiveUserPool: $userId - $username - $difficultyLevelOfUser');
  //         }
  //       }
  //     }
  //     setState(() {
  //       globalVarliveUsersCountByDifficulty = localVarliveUsersCountByDifficulty;
  //     });
  //
  //     print('Data fetched - No user found');
  //   });
  //
  // }

  initGameRoom(BuildContext ctx, String rId) async{
    CollectionReference activeRoomInPoolCollection = FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(difficulty).collection(Constants.ACTIVE_ROOM);

    Map<String, dynamic> updatePlayer2Data = {
      'isFirst': false,
    };
    activeRoomInPoolCollection.doc(rId).update(updatePlayer2Data);
    // print('GameStarted Init');
    // setState(() {
    //   _isGameInit = false;
    // });
    final firebaseRoomManagementProvider = Provider.of<FirebaseRoomManagementProvider>(context, listen: false);
    final firebaseGamePoolProvider = Provider.of<FirebaseGamePoolProvider>(context, listen: false);

    DocumentSnapshot roomDataToGameDataDocSnap = await activeRoomInPoolCollection.doc(rId).get();
    Map<String, dynamic> roomDataToGameData = roomDataToGameDataDocSnap.data() as Map<String, dynamic>;


    String createdBy = roomDataToGameData['createdBy'];
    String playerId1 = roomDataToGameData['playerId1'];
    String playerId2 = roomDataToGameData['playerId2'];
    Timestamp createdAt = Timestamp.now();

    if(createdBy == currentUser!.uid){
      String gId = Uuid().v4();
      firebaseGamePoolProvider.generatePuzzleForGame(
          widget.difficultyLevel, gId, playerId1, playerId2,
          createdAt, createdBy);

      firebaseRoomManagementProvider.updateDataGameIdByRoomId(widget.roomId, gId, widget.difficultyLevel);
      firebaseGamePoolProvider.gameStarted();

    }
  }

  fetchSudokuData(BuildContext ctx, String gameId){
    final firebaseGamePoolProvider = Provider.of<FirebaseGamePoolProvider>(context, listen: false);
    // print('fetched by ${currentUser!.displayName}');
    firebaseGamePoolProvider.fetchPuzzleForGame(gameId);
    firebaseGamePoolProvider.gameStarted();

  }

  counterChanging(){
    final firebaseGamePoolProvider = Provider.of<FirebaseGamePoolProvider>(context, listen: false);
    firebaseGamePoolProvider.updateCounterStatus();
  }

  AdMobUtility adMobUtility = AdMobUtility();
  late InterstitialAd interstitialAd;
  late BannerAd bannerAd;
  initBannerAd(){
    bannerAd = adMobUtility.bottomBarAd();
    bannerAd.load();
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

  @override
  void dispose() {
    // searchTimer?.cancel();
    deleteFromActiveGamePool();
    interstitialAd.show();
    WidgetsBinding.instance?.removeObserver(this);
    //super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    difficulty = DifficultyEnumToString(widget.difficultyLevel).name;
    super.initState();
    initBannerAd();
    initGameEndAd();
    WidgetsBinding.instance?.addObserver(this);
  }

  Stream<DocumentSnapshot> getRoomDocumentStream(String roomId) {
    return FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(widget.difficultyLevel!.name)
        .collection(Constants.ACTIVE_ROOM)
        .doc(roomId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getGameDocumentStream(String gameId) {
    return FirebaseFirestore.instance
        .collection(Constants.ACTIVE_GAME_POOL)
        .doc(gameId).snapshots();
  }

  @override
  Widget build(BuildContext context) {

    final firebaseGamePoolProvider = Provider.of<FirebaseGamePoolProvider>(context, listen: false);
    final firebaseUserDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    final firebaseRoomManagementProvider = Provider.of<FirebaseRoomManagementProvider>(context, listen: true);

    return Scaffold(
        appBar: AppBar(
              automaticallyImplyLeading: firebaseRoomManagementProvider.getBackButtonActive, // Hide the back button based on the hideBackButton variable
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('Sudoku Mingle')
            ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: getRoomDocumentStream(widget.roomId),
          builder: (context, snapshot) {

            if (snapshot.hasError) {
              // Handle error
              String wId = firebaseRoomManagementProvider.getWinnerId;
              return WinnerAnnouncement(winnerId: wId, currentUserId: currentUser!.uid);
              // return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while waiting for data
              return CircularProgressIndicator(color: Theme.of(context).primaryColor,);
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              // Data has been received, access it using snapshot.data
              var data = snapshot.data!.data() as Map<String, dynamic>;
              // Update your UI with the new data
              if(data['playerSize']==2) {
                firebaseRoomManagementProvider.setBackButtonFalse();
                if (data['createdBy'] == currentUser!.uid && data['isFirst']) {
                  initGameRoom(context, widget.roomId);
                  return GameSearchWidget(difficultyLevel: widget.difficultyLevel);
                }
                else {
                  if (data['gameId'] == '') {
                    return GameSearchWidget(difficultyLevel: widget.difficultyLevel);
                  }
                  else {
                    if(data['createdBy']!=currentUser!.uid){
                      // print(data['gameId']);
                      fetchSudokuData(context, data['gameId']);
                      // return UserSearchingWidget(milliSecondsDelayTime: 100, searching: true,);
                    }
                    if (firebaseGamePoolProvider.getGameStarted) {

                      return StreamBuilder<DocumentSnapshot>(
                        stream: getGameDocumentStream(data['gameId']),
                        builder: (context, snapshot) {

                          if (snapshot.hasError) {
                            // Handle error
                            // return Text('Error: ${snapshot.error}');
                            String wId = firebaseRoomManagementProvider.getWinnerId;
                            return WinnerAnnouncement(winnerId: wId, currentUserId: currentUser!.uid);
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Show loading indicator while waiting for data
                            return GameSearchWidget(difficultyLevel: widget.difficultyLevel);
                          }

                          if (snapshot.hasData && snapshot.data!.exists) {
                            // Data has been received, access it using snapshot.data
                            var gameData = snapshot.data!.data() as Map<String, dynamic>;
                            if(gameData['isGameEnded']){
                              if(gameData['winnerId']==''){
                                //calculate Winner
                              }
                              if(gameData['winnerId']!=''){
                                firebaseUserDataProvider.addOnlineGameDataToGameHistory(data['gameId']);
                                firebaseRoomManagementProvider.setWinnerId(data['gameId']);
                                return WinnerAnnouncement(winnerId: gameData['winnerId'], currentUserId: currentUser!.uid);
                              }
                              return const Text('Calculating Results');
                            }
                            firebaseRoomManagementProvider.setBackButtonTrue();
                            return DualPlayerSudokuGridWidget(
                              generatedSudoku: {
                                'correctSudoku': firebaseGamePoolProvider.getCorrectSudoku,
                                'toBeSolvedSudoku': firebaseGamePoolProvider.getToBeSolvedSudoku,
                                'difficulty': widget.difficultyLevel
                              },
                              isMultiplayer: true,
                              activeGameId: gameData['gameId'] ?? '',
                              isPlayer1: gameData['playerId1']! == currentUser!.uid,
                              playerId1: gameData['playerId1'],
                              playerId2: gameData['playerId2'],
                            );
                          }
                          else {
                            // Document does not exist
                            String wId = firebaseRoomManagementProvider.getWinnerId;
                            return WinnerAnnouncement(winnerId: wId, currentUserId: currentUser!.uid);
                          }
                        },
                      );
                    }
                    else {
                      return GameSearchWidget(difficultyLevel: widget.difficultyLevel);
                    }
                  }
                }
              }
              return GameSearchWidget(difficultyLevel: widget.difficultyLevel);
            }

            else {
              // Document does not exist
              String wId = firebaseRoomManagementProvider.getWinnerId;
              return WinnerAnnouncement(winnerId: wId, currentUserId: currentUser!.uid);
            }
          },
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );

  }


  void deleteFromActiveGamePool() async{

    //get Game ID and delete that First
    final roomData = FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(DifficultyEnumToString(widget.difficultyLevel).name)
        .collection(Constants.ACTIVE_ROOM)
        .doc(widget.roomId).get();

    try {
      await FirebaseFirestore.instance
          .collection(Constants.ACTIVE_USER_POOL)
          .doc(DifficultyEnumToString(widget.difficultyLevel).name)
          .collection(Constants.ACTIVE_ROOM)
          .doc(widget.roomId)
          .delete().then((_) {
        // print('Document with roomId ${widget.roomId} deleted successfully.');
      }).catchError((error) {
        // print('Error deleting document with roomId ${widget.roomId} : $error');
      });
    }catch(e){
      // print('Error deleting document with roomId ${widget.roomId} : $e');
    }


  }


}