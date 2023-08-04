import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/firebaseUserDataProvider.dart';
import '../widgets/sidebarButtonWidget.dart';
import '../widgets/statisticsDetailsWidget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isOnlineSelected = false; // Initially, "Online" is selected
  String selectedDifficulty = 'Easy'; // Initially, "Easy" is selected

  // Simulated Firebase data
  Map<String, dynamic> gameDataMultiplayer = {
  };
  // Map<String, dynamic> gameDataMultiplayer = {
  //   'Easy': {
  //     'won': 10,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 80.0,
  //   },
  //   'Hard': {
  //     'won': 20,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 80.0,
  //   },
  //   'Medium': {
  //     'won': 30,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 30,
  //     'winningPercentage': 80.0,
  //   },
  //   'Master': {
  //     'won': 40,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 60,
  //     'winningPercentage': 80.0,
  //   },
  //   'Grandmaster': {
  //     'won': 50,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 200,
  //     'winningPercentage': 80.0,
  //   },
  //   'Do Not Try': {
  //     'won': 10,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 10.0,
  //   },
  //   // Add more data for other difficulty levels
  // };

  Map<String, dynamic> gameDataSinglePlayer = {
  };

  // Map<String, dynamic> gameDataSingleplayer = {
  //   'Easy': {
  //     'won': 10,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 80.0,
  //   },
  //   'Hard': {
  //     'won': 20,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 80.0,
  //   },
  //   'Medium': {
  //     'won': 30,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 30,
  //     'winningPercentage': 80.0,
  //   },
  //   'Master': {
  //     'won': 40,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 60,
  //     'winningPercentage': 80.0,
  //   },
  //   'Grandmaster': {
  //     'won': 50,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 200,
  //     'winningPercentage': 80.0,
  //   },
  //   'Do Not Try': {
  //     'won': 10,
  //     'bestTime': '00:01:30',
  //     'worstTime': '00:03:45',
  //     'totalGames': 20,
  //     'winningPercentage': 10.0,
  //   },
  //   // Add more data for other difficulty levels
  // };

  loadGameHistoryData(BuildContext ctx) async{
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: true);
    setState(() {
      gameDataMultiplayer = userDataProvider.getOnlineGameHistory;
      gameDataSinglePlayer = userDataProvider.getPracticeGameHistory;
    });
  }
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   loadGameHistoryData(context);
  // }

  @override
  Widget build(BuildContext context) {
    final fixedTopButtonSize = MaterialStateProperty.all(
        Size(MediaQuery.sizeOf(context).width* 0.5, 40));
    final fixedSideButtonSize = MaterialStateProperty.all(
        Size(0, MediaQuery.sizeOf(context).height* 0.15,));
    loadGameHistoryData(context);
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
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor.withAlpha(50),
                  ),
                  minimumSize: fixedTopButtonSize,
                    elevation: MaterialStateProperty.all(0)

                ),
                child: Text(
                  'Multiplayer',
                  style: TextStyle(
                    color: isOnlineSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold
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
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor.withAlpha(50),
                  ),
                  minimumSize: fixedTopButtonSize,
                  elevation: MaterialStateProperty.all(0)
                ),
                child: Text(
                  'Pratice',
                  style: TextStyle(
                    color: !isOnlineSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [

                SidebarButtonWidget(
                  difficultyLevels: ['Easy', 'Medium', 'Hard', 'Master', 'Grandmaster', 'Do Not Try'],
                  onPressed: (difficulty) {
                    setState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                  selectedDifficulty: selectedDifficulty,
                ),

                gameDataMultiplayer[selectedDifficulty] == null || gameDataSinglePlayer[selectedDifficulty] == null
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    )
                  : Expanded(
                      child: isOnlineSelected
                      ? StatisticsDetailsWidget(
                          difficulty: selectedDifficulty,
                          difficultyData: gameDataMultiplayer[selectedDifficulty],
                          isMultiplayer: isOnlineSelected
                        )
                      : StatisticsDetailsWidget(
                          difficulty: selectedDifficulty,
                          difficultyData: gameDataSinglePlayer[selectedDifficulty],
                          isMultiplayer: isOnlineSelected
                        ),
              ),
              ]
            ),
          ),
        ],
      ),
    );

  }
}
