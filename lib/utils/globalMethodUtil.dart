
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';

import '../providers/firebaseUserDataProvider.dart';
import 'constants.dart';

class GlobalMethodUtil{

  static Future<void> warningDialog({
    required String title,
    required String subtitle,
    required Function fct,
    required BuildContext context,
  }) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [
              // Image.asset(
              //   'assets/images/warning-sign.png',
              //   height: 20,
              //   width: 20,
              //   fit: BoxFit.fill,
              // ),
              const SizedBox(
                width: 8,
              ),
              Text(title),
            ]),
            content: Text(subtitle),
            actions: [
              // TextButton(
              //   onPressed: () {
              //     if (Navigator.canPop(context)) {
              //       Navigator.pop(context);
              //     }
              //   },
              //   child: TextWidget(
              //     color: Colors.cyan,
              //     text: 'Cancel',
              //     textSize: 18,
              //   ),
              // ),
              TextButton(
                onPressed: () {
                  fct();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'OK',
                ),
              ),
            ],
          );
        });
  }


  static int getCoinValue(String difficultyLevel, String currentUserId, String winnerId, {required bool isMultiplayer}){
    int coinAdded = 0;
    if(difficultyLevel == 'Easy'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 200:-200;
      }
      else{
        coinAdded = currentUserId==winnerId ? 100:-100;
      }
    }
    else if(difficultyLevel == 'Medium'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 400:-400;
      }
      else{
        coinAdded = currentUserId==winnerId ? 200:-200;
      }
    }
    else if(difficultyLevel == 'Hard'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 600:-600;
      }
      else{
        coinAdded = currentUserId==winnerId ? 300:-300;
      }
    }
    else if(difficultyLevel == 'Master'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 800:-800;
      }
      else{
        coinAdded = currentUserId==winnerId ? 400:-400;
      }
    }
    else if(difficultyLevel == 'Grandmaster'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 1000:-1000;
      }
      else{
        coinAdded = currentUserId==winnerId ? 500:-500;
      }
    }
    else if(difficultyLevel == 'Do Not Try'){
      if(isMultiplayer){
        coinAdded = currentUserId==winnerId ? 1200:-1200;
      }
      else{
        coinAdded = currentUserId==winnerId ? 600:-600;
      }
    }
    return coinAdded;
  }

}

class FirebaseGlobalMethodUtil{

  static void initUserData(BuildContext context) async {
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await userDataProvider.fetchCustomUserProfileData();
      await userDataProvider.fetchUserGameHistory();
    }
  }

  static void deleteDocument(String collectionName, String documentId) {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .delete()
        .then((_) {
      print("Document deleted successfully!");
    }).catchError((error) {
      print("Error deleting document: $error");
    });
  }

  // void deleteActiveGamePool(String gameId) async{
  //
  //   try{
  //     await FirebaseFirestore.instance
  //         .collection(Constants.ACTIVE_GAME_POOL)
  //         .doc(gameId)
  //         .delete();
  //   }
  //   catch(e){
  //     print('Error deleting document with roomId ${gameId} : $e');
  //   }
  //
  // }
  // void deleteFromActiveGamePool(Difficulty difficultyLevel, String roomId, String gameId) async{
  //
  //   //get Game ID and delete that First
  //   final roomData = FirebaseFirestore.instance
  //       .collection(Constants.ACTIVE_USER_POOL)
  //       .doc(DifficultyEnumToString(difficultyLevel).name)
  //       .collection(Constants.ACTIVE_ROOM)
  //       .doc(widget.roomId).get();
  //
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection(Constants.ACTIVE_USER_POOL)
  //         .doc(DifficultyEnumToString(widget.difficultyLevel).name)
  //         .collection(Constants.ACTIVE_ROOM)
  //         .doc(widget.roomId)
  //         .delete().then((_) {
  //       print('Document with roomId ${widget.roomId} deleted successfully.');
  //     }).catchError((error) {
  //       print('Error deleting document with roomId ${widget.roomId} : $error');
  //     });
  //   }catch(e){
  //     print('Error deleting document with roomId ${widget.roomId} : $e');
  //   }
  //
  //
  // }

}


class FirebaseGlobalMethodActiveGamePoolUtil{

  void thisPlayerWonTheGame(String playerId1, String playerId2, bool isPlayer1, int scoreToUpdate, int mistakesToUpdate, String gameId) async {

    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId);

    activeGameDocRef.get().then((documentSnapshot) async{
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if (data['isGameEnded']) {
          // Game is ended, handle accordingly
          // For example, show a message or perform an action
          return;
        }
      }
    }).catchError((error) {
      // Handle the error if there's an issue with fetching the document
      print("Error fetching document: $error");
    });

    if(isPlayer1){
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer1': true,
        'player1Points': scoreToUpdate,
        'player1Mistake': mistakesToUpdate,
        'winnerId': playerId1,
        'endedAt': Timestamp.now()
      });
    }
    else{
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer2': true,
        'player2Points': scoreToUpdate,
        'player2Mistake': mistakesToUpdate,
        'winnerId': playerId2,
        'endedAt': Timestamp.now()
      });

    }

    // await Future.delayed(Duration(seconds: 3), () {print('deplayed1');});
    // fetchUserFromActiveGamePoolContinuously(widget.activeGameId, ctx);
  }

  void thisPlayerLoseTheGame(String playerId1, String playerId2, bool isPlayer1, int scoreToUpdate, int mistakesToUpdate, String gameId) async{
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId);
    if(isPlayer1){
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer1': true,
        'player1Points': scoreToUpdate,
        'player1Mistake': mistakesToUpdate,
        'winnerId': playerId2,
        'endedAt': Timestamp.now()
      });
    }
    else{
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer2': true,
        'player2Points': scoreToUpdate,
        'player2Mistake': mistakesToUpdate,
        'winnerId': playerId1,
        'endedAt': Timestamp.now()
      });

    }
  }

  void updateScore(bool isPlayer1, int scoreToUpdate, String gameId) async {
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId);
    if(isPlayer1){
      await activeGameDocRef.update({
        'player1Points': scoreToUpdate,
      });
    }
    else{
      await activeGameDocRef.update({
        'player2Points': scoreToUpdate,
      });

    }
  }

  void updateMistake(bool isPlayer1, int mistakesToUpdate, String gameId) async {
    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId);
    if(isPlayer1){
      await activeGameDocRef.update({
        'player1Mistake': mistakesToUpdate,
      });
    }
    else{
      await activeGameDocRef.update({
        'player2Mistake': mistakesToUpdate,
      });

    }
  }

}