import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';

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

  Future<String> showDifficultyDialog(BuildContext context) async {
    final difficultyLevels = ['Easy', 'Medium', 'Hard', 'Master', 'Grandmaster'];
    String selectedDifficulty = '';
    bool isDifficultySelected = false;


    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Difficulty'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: difficultyLevels.map((level) {
                    return ListTile(
                      title: Text(
                        level,
                        style: TextStyle(color: selectedDifficulty == level ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark),
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
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    isDifficultySelected = false;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Play'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (!isDifficultySelected) {
      // Dialog was closed without selecting a difficulty level
      selectedDifficulty = '';
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
              color: Colors.teal
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
              style:
              TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, //Theme.of(context).textTheme.displayLarge
              ),
            ),
            ScrollableCarousel(
              cards: [
                CardWidget(color: Colors.teal),
                CardWidget(color: Colors.blue),
                CardWidget(color: Colors.deepPurpleAccent),
                // Add more cards here
              ],
            ),
            SizedBox(height: 10),

            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlayWithFriendScreen()),
                    );
                  },
                  child: Text('Play with Friends'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showDifficultyDialog(context).then((selectedDifficulty) {
                      if (selectedDifficulty != '') {
                        print(selectedDifficulty);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PraticeOfflineSudokuScreen(difficultyLevel: selectedDifficulty)),
                        );
                      }
                    });
                  },
                  child: Text('Practice Offline'),
                ),
              ],
            )

          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height*0.1,
        color: Colors.teal,
        child: Center(
          child: Text('Space For Adds'),
        ),
      ),
    );
  }
}
