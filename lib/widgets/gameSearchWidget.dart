import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/widgets/userSearchingWidget.dart';

import '../providers/firebaseUserDataProvider.dart';

class GameSearchWidget extends StatelessWidget {
  final Difficulty difficultyLevel;
  const GameSearchWidget({super.key, required this.difficultyLevel});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Selected difficulty Level ${DifficultyEnumToString(difficultyLevel).name}',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        const SizedBox(height: 20,),
        UserSearchingWidget(milliSecondsDelayTime: 100, searching: true, userAvatarIndex: userDataProvider.getUserData['userAvatar'] ?? 0,),
        const SizedBox(height: 20,),
        Text(
          'Searching Player',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16
          ),
        ),
      ],
    );
  }
}
