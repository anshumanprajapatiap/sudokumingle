import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsDetailsWidget extends StatelessWidget {
  final String difficulty;
  final Map<String, dynamic> difficultyData;
  final bool isMultiplayer;

  StatisticsDetailsWidget({
    required this.difficulty,
    required this.difficultyData,
    required this.isMultiplayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Difficulty: $difficulty',
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: MediaQuery.sizeOf(context).height*0.4,
          width: MediaQuery.sizeOf(context).width*0.8,
          color: Theme.of(context).primaryColor.withOpacity(0.5),

        ),
        SizedBox(height: 16),
        Text(
          'Games Won: ${difficultyData['won']}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Best Time: ${difficultyData['bestTime']}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Worst Time: ${difficultyData['worstTime']}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isMultiplayer) ...[
          // Additional data for multiplayer mode
          Text(
            'Winning Percentage: ${((difficultyData['won'] / difficultyData['totalGames']) * 100).toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Total Games Played: ${difficultyData['totalGames']}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
