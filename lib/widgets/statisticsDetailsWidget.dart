

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sudokumingle/widgets/rectangularStatWidget.dart';

class StatisticsDetailsWidget extends StatefulWidget {
  final String difficulty;
  final Map<String, dynamic> difficultyData;
  final bool isMultiplayer;

  StatisticsDetailsWidget({
    required this.difficulty,
    required this.difficultyData,
    required this.isMultiplayer,
  });

  @override
  State<StatisticsDetailsWidget> createState() => _StatisticsDetailsWidgetState();
}

class _StatisticsDetailsWidgetState extends State<StatisticsDetailsWidget> {
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return widget.difficultyData == {}
        ? CircularProgressIndicator(color: Theme.of(context).primaryColor,)
        : widget.difficultyData['totalGames'] ==  0
          ? Center(
              child: Text(
                  'No Data for ${widget.difficulty} Level',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              ),
            )
          : SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Game title start
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:Text(
                      widget.isMultiplayer
                          ? 'Online Game'
                          : 'Offline Game',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //Game Title end
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse: Icons.grid_4x4_sharp, text: 'Difficulty', value: widget.difficulty,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.kayaking_sharp, text: 'Games Won', value: widget.difficultyData['won'].toString(),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.percent, text: 'Wining Rate', value:'${((widget.difficultyData['won'] / widget.difficultyData['totalGames']) * 100).toStringAsFixed(2)}',),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.star, text: 'Win with No Mistakes', value: widget.difficultyData['wonWithoutMistake'].toString(),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.padding, text: 'Total Game', value: widget.difficultyData['totalGames'].toString(),),
                  ),

                  //Time title start
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //Time Title end
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse: Icons.timer, text: 'Best Time', value: '${formatDuration(widget.difficultyData['bestTime']).toString()}',),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.share_arrival_time_rounded, text: 'Worst Time', value: formatDuration(widget.difficultyData['worstTime']).toString(),),
                  ),

                  //Score title start
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //Score Title end
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse: Icons.score, text: 'Best Score', value: widget.difficultyData['bestScore'].toString(),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RectangularStatWidget(iconToUse:Icons.format_overline, text: 'Average Score', value: (widget.difficultyData['avgScore']/widget.difficultyData['totalGames']).toStringAsFixed(2),),
                  ),
                ],
              ),
          );
  }
}
