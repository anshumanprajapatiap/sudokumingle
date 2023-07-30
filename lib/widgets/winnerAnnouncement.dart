import 'package:flutter/material.dart';

class WinnerAnnouncement extends StatelessWidget {
  final String winnerId;
  final String currentUserId;
  const WinnerAnnouncement({super.key, required this.winnerId, required this.currentUserId});

  @override
  Widget build(BuildContext context) {

    String variableString =
      winnerId == currentUserId
          ? 'Congrats  you Won!, Play Again'
          : 'Opps you Lose!, Try Again';


    return Container(
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
  }
}
