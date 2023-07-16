import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';

import '../widgets/cardWidget.dart';
import '../widgets/scrollableCarouselWidget.dart';
import 'PlayWithFriendScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  Map<String, dynamic> _currentUserDetails = {};

  Future<Difficulty> showDifficultyDialog(BuildContext context) async {
    final difficultyLevels = [Difficulty.easy, Difficulty.medium, Difficulty.hard, Difficulty.master, Difficulty.grandmaster, Difficulty.donnottry];
    Difficulty selectedDifficulty = Difficulty.easy;
    bool isDifficultySelected = true;


    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Difficulty', style: TextStyle(color: Theme.of(context).primaryColor),),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListBody(
                      children: difficultyLevels.map((level) {
                        return ListTile(
                          title: Text(
                            level.name,
                            style: TextStyle(
                                color: selectedDifficulty == level ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                              fontWeight: selectedDifficulty == level ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          //tileColor: selectedDifficulty == level ? Colors.blueGrey : null,
                          onTap: () {
                            setState(() {
                              selectedDifficulty = level;
                              isDifficultySelected = true;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor),),
                          onPressed: () {
                            isDifficultySelected = false;
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Play',  style: TextStyle(color: Theme.of(context).cardColor),),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // actions: [
              //   TextButton(
              //     child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor),),
              //     onPressed: () {
              //       isDifficultySelected = false;
              //       Navigator.of(context).pop();
              //     },
              //   ),
              //   TextButton(
              //     child: Text('Play',  style: TextStyle(color: Theme.of(context).cardColor),),
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ],
            );
          },
        );
      },
    );

    if (!isDifficultySelected) {
      // Dialog was closed without selecting a difficulty level
      selectedDifficulty = Difficulty.none;
    }

    return selectedDifficulty;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String displayName = _currentUser!.displayName ?? '';
    List<String> nameParts = displayName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    print('name: ${firstName}');
    setState(() {
      _currentUserDetails = {
        'userFirstName': firstName,
        'coins': 10000000,
        'userRank': 10000000
      };
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: const Text(
          'Sudoku Mingle',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Hi ${_currentUserDetails['userFirstName']}'),
                  _currentUserDetails['userRank']>999999
                    ? Text('Rank: 999999+')
                    : Text('Rank: ${_currentUserDetails['userRank'].toString()}'),
                  _currentUserDetails['coins']>999999
                      ? Text('Coins: 999999+')
                      : Text('Coins: ${_currentUserDetails['coins'].toString()}')
                ],
              ),
            ),
            SizedBox(height: 8,),
            Text(
              'Live Contest',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                fontSize: 24,
              ),
            ),
            ScrollableCarousel(
              cards: [
                CardWidget(color: Colors.blueGrey),
                CardWidget(color: Colors.blueGrey),
                CardWidget(color: Colors.blueGrey),
                // Add more cards here
              ],
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDifficultyDialog(context).then((selectedDifficulty) {
                        if (selectedDifficulty != null && selectedDifficulty != Difficulty.none) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayWithFriendScreen(difficultyLevel: selectedDifficulty)),
                        );
                      }
                    });
                    },
                  child: Text('Play Online'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),
                    
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showDifficultyDialog(context).then((selectedDifficulty) {
                      if (selectedDifficulty != null && selectedDifficulty != Difficulty.none) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PraticeOfflineSudokuScreen(difficultyLevel: selectedDifficulty)),
                        );
                      }
                    });
                  },
                  child: Text('Practice Offline'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),
                  ),
                ),
              ],
            )

          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height*0.1,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Text('Space For Adds'),
        ),
      ),
    );
  }
}
