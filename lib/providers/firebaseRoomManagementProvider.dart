import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:uuid/uuid.dart';

import '../utils/constants.dart';
import '../utils/globalMethodUtil.dart';

class FirebaseRoomManagementProvider with ChangeNotifier {
  final _currentAuthUser = FirebaseAuth.instance.currentUser;
  String _winnerId = '';
  bool _backButtonShow = true;

  Map<String, dynamic> _roomDetailsOnActivePool = {
    'roomId': '',
    'playerId1': '',
    'playerId2': '',
    'username1': '',
    'username2': '',
    'difficultyLevel': '',
    'createdBy': '',
    'playerSize': '',
    'createdAt': '',
    'joinedAt': '',
    'GameId': ''
  };

  Map<String, dynamic> get getRoomDetails{
    return _roomDetailsOnActivePool;
  }

  bool get getBackButtonActive => _backButtonShow;
  String get getWinnerId => _winnerId;

  void setBackButtonTrue(){
    _backButtonShow = true;
    notifyListeners();
  }

  void setBackButtonFalse(){
    _backButtonShow = false;
    notifyListeners();
  }

  Future<void> joinOrCreateRoomTesting(Difficulty difficulty) async {
    _roomDetailsOnActivePool['roomId']= '';

    CollectionReference activeRoomsCollection = FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(difficulty!.name)
        .collection(Constants.ACTIVE_ROOM);
    // CollectionReference activeRoomsCollection = FirebaseFirestore.instance.collection('ActiveRoom');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot snapshot = await activeRoomsCollection.get();
        List<QueryDocumentSnapshot> rooms = snapshot.docs.toList();

        if(rooms.isEmpty){
          print('No Rooms are at ACTIVE_ROOM Collection');
          await createRoomOnActiveDetailsOnFirebase(difficulty);
          return;
        }

        // Check for an available room
        for (QueryDocumentSnapshot room in rooms) {
          Map<String, dynamic> roomData = room.data() as Map<String, dynamic>;
          int playerSize = roomData['playerSize'];

          if (playerSize == 1 && roomData['isAvailable']) {
            // Mark the room as occupied by Player 2 and update player count
            DocumentReference roomRef = room.reference;

            // Use a transaction to ensure atomic updates
            DocumentSnapshot roomSnapshot = await transaction.get(roomRef);
            Map<String, dynamic> roomSnapshotData = roomSnapshot.data() as Map<String, dynamic>;
            int currentSize = roomSnapshotData['playerSize'];
            bool currentAvailable = roomData['isAvailable'];
            String player1Id = roomData['playerId1'];
            if (currentSize == 1 && currentAvailable && player1Id !=_currentAuthUser!.uid) {
              // Mark the room as occupied by Player 2 and update player count
              transaction.update(roomRef, {
                'playerSize': 2,
                'playerId2': _currentAuthUser!.uid,
                'username2': _currentAuthUser!.displayName,
                'joinedAt': Timestamp.now(),
                'isAvailable': false
              });

              _roomDetailsOnActivePool['roomId'] = roomSnapshotData['roomId'];
              _roomDetailsOnActivePool['createdBy'] = roomSnapshotData['createdBy'];
              return;
            }
          }
        }

        // If no available room was found, create a new room and try joining again
        await createRoomOnActiveDetailsOnFirebase(difficulty);
        return;

        // Retry joining the new room
        // You could implement a recursive call or a separate function to handle this retry logic
      });
    } catch (e) {
      // Handle transaction error and retries
      // await createRoomOnActiveDetailsOnFirebase(difficulty);
    }
  }


  // fetchRoomDetailsOnFirebase(Difficulty difficulty) async{
  //   _roomDetailsOnActivePool['roomId']= '';
  //
  //   CollectionReference activeRoomInPoolCollection = FirebaseFirestore.instance
  //       .collection(Constants.ACTIVE_USER_POOL)
  //       .doc(difficulty!.name)
  //       .collection(Constants.ACTIVE_ROOM);
  //
  //   QuerySnapshot snapshot = await activeRoomInPoolCollection.get();
  //   List<QueryDocumentSnapshot> documents = snapshot.docs.toList();
  //   print(documents);
  //   // await Future.delayed(Duration(seconds: 2), () {print('delayName');});
  //
  //   if(documents.length==0){
  //     print('No Rooms are at ACTIVE_ROOM Collection');
  //     await createRoomOnActiveDetailsOnFirebase(difficulty);
  //     return;
  //   }
  //
  //   for (QueryDocumentSnapshot document in documents) {
  //     Map<String, dynamic>? documentData = document.data() as Map<String, dynamic>?;
  //     if (documentData != null && documentData['playerSize']==1) {
  //       String roomId = documentData['roomId'] as String? ?? '';
  //       String playerId1 = documentData['playerId1'] as String ?? '';
  //       String username1 = documentData['username1'] as String ?? '';
  //       String createdBy = documentData['createdBy'] as String ?? '';
  //       Timestamp createdAt = documentData['createdAt'] ?? '';
  //
  //       Map<String, dynamic> updatePlayer2Data = {
  //         'playerId2': _currentAuthUser!.uid,
  //         'username2':_currentAuthUser!.displayName,
  //         //'playerSize': documentData['playerSize']+1,
  //         'joinedAt': Timestamp.now(),
  //       };
  //       activeRoomInPoolCollection.doc(roomId).update(updatePlayer2Data);
  //
  //       Map<String, dynamic> gameRoomData = {
  //         'roomId': roomId,
  //         'playerId1': playerId1,
  //         'playerId2': _currentAuthUser!.uid,
  //         'username1': username1,
  //         'username2': _currentAuthUser!.displayName,
  //         'difficultyLevel': difficulty!.name,
  //         'createdBy': createdBy,
  //         'playerSize': 2,
  //         'createdAt': createdAt,
  //         'joinedAt': Timestamp.now(),
  //         'gameId': '',
  //       };
  //       _roomDetailsOnActivePool['roomId'] = gameRoomData['roomId'];
  //       _roomDetailsOnActivePool['createdBy'] = gameRoomData['createdBy'];
  //       // _roomDetailsOnActivePool = gameRoomData;
  //       notifyListeners();
  //       print('Room ID is Full Now $roomId');
  //       return;
  //     }
  //   }
  //
  //   await createRoomOnActiveDetailsOnFirebase(difficulty);
  // }

  createRoomOnActiveDetailsOnFirebase(Difficulty difficulty) async {

    CollectionReference activeRoomInPoolCollection = FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(difficulty!.name).collection(Constants.ACTIVE_ROOM);

    String roomId = Uuid().v4();
    print('creating room $roomId');

    DocumentReference userDocument = activeRoomInPoolCollection.doc(roomId);

    // Set the data for the user document
    Map<String, dynamic> gameRoomData = {
      'roomId': roomId,
      'playerId1': _currentAuthUser!.uid,
      'playerId2': '',
      'username1': _currentAuthUser!.displayName,
      'username2':'',
      'difficultyLevel': difficulty!.name,
      'createdBy': _currentAuthUser!.uid,
      'playerSize': 1,
      'createdAt': Timestamp.now(),
      'joinedAt': '',
      'gameId': '',
      'isFirst': true,
      'isAvailable': true,
    };
    await userDocument.set(gameRoomData, SetOptions(merge: true),);

    _roomDetailsOnActivePool['roomId'] = gameRoomData['roomId'];
    _roomDetailsOnActivePool['createdBy'] = gameRoomData['createdBy'];
    // _roomDetailsOnActivePool = gameRoomData;
    notifyListeners();
    return;
  }

  deleteRoomActiveOnFirebase(String roomId, Difficulty difficulty) async{
    try {
      await FirebaseFirestore.instance
          .collection(Constants.ACTIVE_USER_POOL)
          .doc(difficulty!.name)
          .collection(Constants.ACTIVE_ROOM)
          .doc(roomId)
          .delete();

      print('Document with roomId $roomId deleted successfully.');
    } catch (e) {
      print('Error deleting document with roomId $roomId: $e');
    }
    notifyListeners();
  }

  fetchDataByRoomId(String roomId, Difficulty difficulty) async{
    DocumentSnapshot roomIdSnapShot = await FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(difficulty!.name)
        .collection(Constants.ACTIVE_ROOM)
        .doc(roomId).get();
    if(roomIdSnapShot.exists){
      Map<String, dynamic>? documentData = roomIdSnapShot.data() as Map<String, dynamic>?;
      if (documentData != null) {
        _roomDetailsOnActivePool['gameId'] = documentData['gameId'];
        notifyListeners();
      }
    }

  }

  updateDataGameIdByRoomId(String roomId, String gameId, Difficulty difficulty)async {
    await FirebaseFirestore.instance
        .collection(Constants.ACTIVE_USER_POOL)
        .doc(difficulty!.name)
        .collection(Constants.ACTIVE_ROOM)
        .doc(roomId)
        .update({
          'gameId': gameId
        });
    _roomDetailsOnActivePool['gameId'] = gameId;
    notifyListeners();
  }

  setWinnerId(String winnerId){
    _winnerId = winnerId;
    notifyListeners();
  }
}