import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/firebaseUserDataProvider.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/widgets/adDialogBoxWidget.dart';

import '../providers/firebaseRoomManagementProvider.dart';
import '../utils/constants.dart';
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
  bool _isLoading = false;
  bool _isRoomLoading = false;

  // Map<String, dynamic> _currentUserDetails = {
  //   'userFirstName': '',
  //   'coins': 0,
  //   'userRank': 0
  // };

  List<Map<String, dynamic>> contestData = [
    // {'color': Colors.blue},
    // {'color': Colors.red},
    // {'color': Colors.green},
  ];

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
            return Dialog(
              insetAnimationCurve: Curves.bounceOut,
              insetAnimationDuration: const Duration(milliseconds: 100),
              backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Select Difficulty',
                        style: topHeading.copyWith(fontSize: 20)
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: difficultyLevels.map((level) {
                          return ListTile(
                            title: Text(
                              level.name,
                              style: TextStyle(
                                color: selectedDifficulty == level
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColor.withOpacity(0.5),
                                fontWeight: selectedDifficulty == level
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            isDifficultySelected = false;
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Play',
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
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

  void showAdDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AdDialogBoxWidget();
      },
    );
  }

  void navigateToPlayWithFriendScreen(BuildContext context, Difficulty selectedDifficulty, String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayWithFriendScreen(difficultyLevel: selectedDifficulty, roomId: roomId)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final topHeading = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
      fontSize: 12,
    );

  @override
  Widget build(BuildContext context) {
    final firebaseUserDataProvider = Provider.of<FirebaseUserDataProvider>(context);
    final firebaseRoomManagementProvider = Provider.of<FirebaseRoomManagementProvider>(context, listen: false);
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
              child: Stack(
                children :[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: _isLoading
                            ? Center(
                          child: Text(
                            'Loading.....',
                            style: topHeading,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Hi, ${firebaseUserDataProvider.getUserData['userFirstName']}',
                              style: topHeading,
                            ),
                            firebaseUserDataProvider.getUserData['userRank']!=null
                                ? firebaseUserDataProvider.getUserData['userRank'] > 999999
                                  ? Text(
                                      'Rank: 999999+',
                                      style: topHeading,
                                    )
                                  : Text(
                                      'Rank: ${firebaseUserDataProvider.getUserData['userRank'].toString()}',
                                      style: topHeading,
                                    )
                                : const Text(''),
                            firebaseUserDataProvider.getUserData['coins'] != null
                                ? firebaseUserDataProvider.getUserData['coins'] > 999999
                                    ? Text(
                                        'Coins: 999999+',
                                        style: topHeading,
                                      )
                                    : Text(
                                        'Coins: ${firebaseUserDataProvider.getUserData['coins'].toString()}',
                                        style: topHeading,
                                      )
                                : const Text(''),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10,),

                      Text(
                        'Live Contest',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),

                      ScrollableCarousel(
                        cards: [
                          ...contestData.map((data) => CardWidget(color: data['color'])),
                        ],
                        // cards: [
                        //   CardWidget(color: Theme.of(context).primaryColor),
                        //   CardWidget(color: Theme.of(context).primaryColor),
                        //   CardWidget(color: Theme.of(context).primaryColor),
                        //   // Add more cards here
                        // ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if(firebaseUserDataProvider.getUserData['coins'] <= 0){
                                showAdDialog(context);
                                return;
                              }
                              showDifficultyDialog(context).then((selectedDifficulty) async{
                                if (selectedDifficulty != null && selectedDifficulty != Difficulty.none) {
                                  setState(() {
                                    _isRoomLoading = true;
                                  });
                                  await firebaseRoomManagementProvider.fetchRoomDetailsOnFirebase(selectedDifficulty);
                                  String rId = firebaseRoomManagementProvider.getRoomDetails['roomId'];
                                  while(true){
                                    if(rId!=''){
                                      setState(() {
                                        _isRoomLoading = false;
                                      });
                                      break;
                                    }
                                  }
                                  // await Future.delayed(Duration(seconds: 2), () {print('delayName');});
                                  navigateToPlayWithFriendScreen(context, selectedDifficulty, rId);
                                }
                              });
                            },
                            child: Text('Play Online', style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                              fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),

                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if(firebaseUserDataProvider.getUserData['coins'] <= 0){
                                showAdDialog(context);
                                return;
                              }
                              showDifficultyDialog(context).then((selectedDifficulty) {
                                if (selectedDifficulty != null && selectedDifficulty != Difficulty.none) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PraticeOfflineSudokuScreen(difficultyLevel: selectedDifficulty)),
                                  );
                                }
                              });
                            },
                            child: Text('Practice Offline', style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                              fixedSize: MaterialStateProperty.all(Size.fromWidth(150)),
                            ),
                          ),
                        ],
                      )

                    ],
                  ),
                  if (_isRoomLoading) // Show the loading box if _isRoomLoading is true
                    AbsorbPointer(
                      absorbing: true,
                      child: Stack(
                        children: [
                          ModalBarrier(
                            color: Colors.black54,
                            dismissible: false,
                          ),
                          Center(
                            child: Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.7),
                              child: Center(
                                child: CircularProgressIndicator(color: Theme.of(context).primaryColor), // You can replace this with your custom loading widget
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ]
              ),
            ),
            bottomNavigationBar: Container(
              height: MediaQuery.of(context).size.height*0.08,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(''),
              ),
            ),
    );
  }
}
