
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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


  static bool canPop(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    return navigator != null && navigator.canPop();
  }

}

class FirebaseGlobalMethodUtil{

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

}


class FirebaseGlobalMethodActiveGamePoolUtil{

  void thisPlayerWonTheGame(String playerId1, String playerId2, bool isPlayer1, int scoreToUpdate, int mistakesToUpdate, String gameId) async {

    DocumentReference activeGameDocRef = FirebaseFirestore.instance.collection(Constants.ACTIVE_GAME_POOL).doc(gameId);

    if(isPlayer1){
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer1': true,
        'player1Points': scoreToUpdate,
        'player1Mistake': mistakesToUpdate,
        'winnerId': playerId1
      });
    }
    else{
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer2': true,
        'player2Points': scoreToUpdate,
        'player2Mistake': mistakesToUpdate,
        'winnerId': playerId2
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
        'winnerId': playerId2
      });
    }
    else{
      await activeGameDocRef.update({
        'isGameEnded': true,
        'isSkippedPlayer2': true,
        'player2Points': scoreToUpdate,
        'player2Mistake': mistakesToUpdate,
        'winnerId': playerId1
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