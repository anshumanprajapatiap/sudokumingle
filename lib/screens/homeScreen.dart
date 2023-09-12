import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/firebaseUserDataProvider.dart';
import 'package:sudokumingle/screens/praticeOfflineScreen.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';
import 'package:sudokumingle/widgets/adDialogBoxWidget.dart';

import '../providers/firebaseRoomManagementProvider.dart';
import '../utils/adMobUtility.dart';
import '../utils/constants.dart';
import '../widgets/cardWidget.dart';
import '../widgets/scrollableCarouselWidget.dart';
import 'PlayWithFriendScreen.dart';
import 'onlineGameLandingScreen.dart';

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

  // /* all about adds */
  // late BannerAd bannerAd;
  // bool _isAdLoaded = false;
  // String productionBannerAdUnitId = '{makingerror}ca-app-pub-1710164244221834/9253797898';
  // String developmentBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // initBannerAd(){
  //   bannerAd = BannerAd(
  //       size: AdSize.banner,
  //       adUnitId: developmentBannerAdUnitId,
  //       listener: BannerAdListener(
  //         onAdLoaded: (ad) {
  //           setState(() {
  //             _isAdLoaded = true;
  //           });
  //         },
  //         onAdFailedToLoad: (ad, error) {
  //           ad.dispose();
  //           print(error);
  //         }
  //       ),
  //       request: AdRequest()
  //   );
  //   bannerAd.load();
  // }


  AdMobUtility adMobUtility = AdMobUtility();

  late InterstitialAd interstitialAd;
  late BannerAd bannerAd;
  RewardedAd? rewardedAd;
  initBannerAd(){
    bannerAd = adMobUtility.bottomBarAd();
    bannerAd.load();
  }

  void winCoinAd(){

    InterstitialAd.load(
      adUnitId: adMobUtility.productionCoinWinAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad){
          interstitialAd = ad;
        },
        onAdFailedToLoad: ((error) {
          interstitialAd.dispose();
        }),
      ),
    );
  }

  void rewardedAdFn(){
    RewardedAd.load(
        adUnitId: adMobUtility.productionRewardedAdUnitId,
        request: const AdRequest(
            keywords: ['game', 'rewarded', '30 seconds'],
            httpTimeoutMillis: 30,
            nonPersonalizedAds: true,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad){

              setState(() {
                rewardedAd = ad;
              });

            },
            onAdFailedToLoad: (error){
              setState(() {
                rewardedAd = null;
              });

            }
        )
    );

  }

  void showRewardedAd(BuildContext ctx){
    final firebaseUserDataProviderReward = Provider.of<FirebaseUserDataProvider>(ctx, listen: false);
    if(rewardedAd != null){
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad){
          ad.dispose();
          rewardedAdFn();
        },
        onAdFailedToShowFullScreenContent: (ad, error){
          ad.dispose();
          rewardedAdFn();
        },
      );
      rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            firebaseUserDataProviderReward.setCustomUserProfileDataCoin(150);
          }
      );
    }
  }


  List<Map<String, dynamic>> contestData = [
    {'color': Colors.blueGrey},
    {'color': Colors.blueGrey},
    {'color': Colors.blueGrey},
    {'color': Colors.blueGrey},
    {'color': Colors.blueGrey},
    {'color': Colors.blueGrey},
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
                            // trailing: Text(
                            //     '${100.toString()}',
                            //   style: TextStyle(
                            //     color: Theme.of(context).primaryColor
                            //   ),
                            // ),
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

  userNotDefined(BuildContext context){
    return AlertDialog(
      title: Text('Not Logged In'),
      content: Text('You need to log in to access this feature.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('OK'),
        ),
      ],
    );
  }
  // void showAdDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AdDialogBoxWidget();
  //     },
  //   );
  // }

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
    winCoinAd();
    initBannerAd();
    rewardedAdFn();
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
        actions: [
          IconButton(
              onPressed: () {
                showRewardedAd(context);
                // interstitialAd.show();
                // showAdDialog(context);
                },
              icon: Icon(Icons.ads_click, color: Theme.of(context).primaryColor,))
        ],
      ),
      body: Center(
              child: Stack(
                children :[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: firebaseUserDataProvider.getUserData['userFirstName']==null
                            ? Center(
                          child: Text(
                            'Loading.....',
                            style: topHeading,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            firebaseUserDataProvider.getUserData['userFirstName']!=null
                            ? Text(
                              'Hi, ${firebaseUserDataProvider.getUserData['userFirstName']?? ''}',
                                style: topHeading,
                              )
                            : Text(
                              '',
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => OnlineGameLandingScreen()),
                              // );
                              if(firebaseUserDataProvider.getUserData['userFirstName']==null
                              || firebaseUserDataProvider.getUserData['userFirstName']==''){
                                userNotDefined(context);
                                return;
                              }
                              if(firebaseUserDataProvider.getUserData['coins'] <= 0){
                                // showAdDialog(context);
                                showRewardedAd(context);
                                return;
                              }
                              showDifficultyDialog(context).then((selectedDifficulty) async{
                                if (selectedDifficulty != null && selectedDifficulty != Difficulty.none) {
                                  setState(() {
                                    _isRoomLoading = true;
                                  });
                                  await firebaseRoomManagementProvider.joinOrCreateRoomTesting(selectedDifficulty);
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
                                showRewardedAd(context);
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
                      ),
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

      // To Show Ads
      bottomNavigationBar: SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),

      // bottomNavigationBar: Container(
      //         height: MediaQuery.of(context).size.height*0.08,
      //         color: Theme.of(context).primaryColor,
      //         child: Center(
      //           child: Text(''),
      //         ),
      //       ),
    );
  }
}
