import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistoryModel{
  final String gameId;
  final String playerId1;
  final String playerId2;
  final String difficultyLevel;
  final String winnerId;
  final Timestamp createdAt;
  final Timestamp endedAt;
  final int player1Points;
  final int player2Points;
  final int player1Mistake;
  final int player2Mistake;
  final String createdBy;

  GameHistoryModel({
    required this.gameId,
    required this.playerId1,
    required this.playerId2,
    required this.difficultyLevel,
    required this.winnerId,
    required this.createdAt,
    required this.endedAt,
    required this.player1Points,
    required this.player2Points,
    required this.player1Mistake,
    required this.player2Mistake,
    required this.createdBy
  });
}