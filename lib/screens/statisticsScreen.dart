import 'package:flutter/material.dart';

import '../widgets/sidebarButtonWidget.dart';
import '../widgets/statisticsDetailsWidget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = false;
  bool isOnlineSelected = true; // Initially, "Online" is selected
  // bool isEasy = true;
  // bool isMedium = false;
  // bool isHard= false;
  // bool isMaster = false;
  // bool isGrandmaster = false;
  // bool isDoNotTry = false;
  String selectedDifficulty = 'Easy'; // Initially, "Easy" is selected

  // Simulated Firebase data
  Map<String, dynamic> gameDataMultiplayer = {
    'Easy': {
      'won': 10,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 80.0,
    },
    'Hard': {
      'won': 20,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 80.0,
    },
    'Medium': {
      'won': 30,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 30,
      'winningPercentage': 80.0,
    },
    'Master': {
      'won': 40,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 60,
      'winningPercentage': 80.0,
    },
    'Grandmaster': {
      'won': 50,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 200,
      'winningPercentage': 80.0,
    },
    'Do Not Try': {
      'won': 10,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 10.0,
    },
    // Add more data for other difficulty levels
  };

  Map<String, dynamic> gameDataSingleplayer = {
    'Easy': {
      'won': 10,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 80.0,
    },
    'Hard': {
      'won': 20,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 80.0,
    },
    'Medium': {
      'won': 30,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 30,
      'winningPercentage': 80.0,
    },
    'Master': {
      'won': 40,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 60,
      'winningPercentage': 80.0,
    },
    'Grandmaster': {
      'won': 50,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 200,
      'winningPercentage': 80.0,
    },
    'Do Not Try': {
      'won': 10,
      'bestTime': '00:01:30',
      'worstTime': '00:03:45',
      'totalGames': 20,
      'winningPercentage': 10.0,
    },
    // Add more data for other difficulty levels
  };


  Widget buildOnlineWidget(String difficulty) {
    final difficultyData = gameDataMultiplayer[difficulty];
    return StatisticsDetailsWidget(
        difficulty: difficulty,
        difficultyData: difficultyData,
        isMultiplayer: isOnlineSelected
    );
  }

  Widget buildOfflineWidget(String difficulty) {
    // Replace this with your offline widget implementation
    final difficultyData = gameDataSingleplayer[difficulty];
    return StatisticsDetailsWidget(
        difficulty: difficulty,
        difficultyData: difficultyData,
        isMultiplayer: isOnlineSelected
    );
  }



  @override
  Widget build(BuildContext context) {
    final fixedTopButtonSize = MaterialStateProperty.all(
        Size(MediaQuery.sizeOf(context).width* 0.5, 40));
    final fixedSideButtonSize = MaterialStateProperty.all(
        Size(0, MediaQuery.sizeOf(context).height* 0.15,));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics Screen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: Column(
        children: [

          //TOP BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isOnlineSelected = true;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    isOnlineSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  minimumSize: fixedTopButtonSize

                ),
                child: Text(
                  'Multiplayer',
                  style: TextStyle(
                    color: isOnlineSelected
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              // const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isOnlineSelected = false;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    !isOnlineSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  minimumSize: fixedTopButtonSize
                ),
                child: Text(
                  'Pratice',
                  style: TextStyle(
                    color: !isOnlineSelected
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),


          Expanded(
            child: Row(
              children: [
                // Sidebar with vertical text


                // SingleChildScrollView(
                //   child: Container(
                //     height: MediaQuery.sizeOf(context).height*1,
                //     width: MediaQuery.sizeOf(context).width*0.13,
                //     color: Theme.of(context).secondaryHeaderColor, // Set sidebar background color
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //       crossAxisAlignment: CrossAxisAlignment.end,
                //       children: [
                //
                //         ElevatedButton(
                //           onPressed: () {
                //             setState(() {
                //               isEasy = true;
                //               isHard = false;
                //               isMedium = false;
                //               isMaster = false;
                //               isGrandmaster = false;
                //               isDoNotTry = false;
                //             });
                //           },
                //           child: RotatedBox(
                //             quarterTurns: -1,
                //             child: Text(
                //               'Easy',
                //               style: TextStyle(
                //                 color: !isEasy
                //                     ? Theme.of(context).secondaryHeaderColor
                //                     : Theme.of(context).primaryColor,
                //               ),
                //             ),
                //           ),
                //           style: ButtonStyle(
                //             backgroundColor: MaterialStateProperty.all(
                //               isEasy
                //                   ? Theme.of(context).primaryColor
                //                   : Colors.grey,
                //             ),
                //             minimumSize: fixedSideButtonSize,
                //             // fixedSize: fixedSideButtonSize
                //           ),
                //         ),
                //         ElevatedButton(
                //           onPressed: () {
                //             setState(() {
                //               isEasy = false;
                //               isMedium = true;
                //               isHard = false;
                //               isMaster = false;
                //               isGrandmaster = false;
                //               isDoNotTry = false;
                //             });
                //           },
                //           child: RotatedBox(
                //             quarterTurns: -1,
                //             child: Text(
                //               'Medium',
                //               style: TextStyle(
                //                 color: !isMedium
                //                     ? Theme.of(context).secondaryHeaderColor
                //                     : Theme.of(context).primaryColor,
                //               ),
                //             ),
                //           ),
                //           style: ButtonStyle(
                //             backgroundColor: MaterialStateProperty.all(
                //               isMedium
                //                   ? Theme.of(context).primaryColor
                //                   : Colors.grey,
                //             ),
                //             minimumSize: fixedSideButtonSize,
                //             // fixedSize: fixedSideButtonSize
                //           ),
                //         ),
                //
                //
                //       ],
                //     ),
                //   ),
                // ),

                SidebarButtonWidget(
                  difficultyLevels: ['Easy', 'Medium', 'Hard', 'Master', 'Grandmaster', 'Do Not Try'],
                  onPressed: (difficulty) {
                    setState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                  selectedDifficulty: selectedDifficulty,
                ),



                Expanded(
                  child: isOnlineSelected ? buildOnlineWidget(selectedDifficulty) : buildOfflineWidget(selectedDifficulty),
                ),
              ]
            ),
          ),


        ],
      ),
    );
  }
}
