import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/firebaseUserDataProvider.dart';
import 'package:sudokumingle/screens/settingScreen.dart';

import '../utils/adMobUtility.dart';
import '../widgets/darkLightModeWidget.dart';
import '../widgets/logoutWidget.dart';
import 'aboutScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final lineHeight = 0.3;
  AdMobUtility adMobUtility = AdMobUtility();

  late BannerAd bannerAd;
  late BannerAd upperProfileAd;
  initBannerAd(){
    bannerAd = adMobUtility.bottomBarAd();
    bannerAd.load();
    upperProfileAd = adMobUtility.largeBannerAd();
    upperProfileAd.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBannerAd();
  }

  void _showClearContentDialog(BuildContext context) {
    final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
    bool clearOnlineData = false;
    bool clearOfflineData = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState){
            return Dialog(
              insetAnimationCurve: Curves.bounceOut,
              insetAnimationDuration: const Duration(milliseconds: 100),
              backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Clear Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Column(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: clearOnlineData,
                              onChanged: (value) {
                                setState(() {
                                  clearOnlineData = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            Text('Clear Online Data', style: TextStyle(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: clearOfflineData,
                              onChanged: (value) {
                                setState(() {
                                  clearOfflineData = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            Text('Clear Offline Data', style: TextStyle(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Perform the clear operation here
                              if (clearOnlineData) {
                                // Clear online data logic
                                // ...
                                userDataProvider.deleteOnlineGameHistoryData();
                              }

                              if (clearOfflineData) {
                                // Clear offline data logic
                                // ...
                                userDataProvider.deleteOfflineGameHistoryData();
                              }

                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                          TextButton(
                            onPressed: () {
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                            ),
                            child: Text('Cancel', style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),
                          ),
                        ]
                    ),
                  ],
                ),
              ),

            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: Text(
            'Profile',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor
        ),
        ),
        actions: const [
          DarkLightModeIconWidget(),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 200,
            width: upperProfileAd.size.width.toDouble(),
            child: AdWidget(ad: upperProfileAd),
          ),
          const SizedBox(height: 30,),
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
                ListTile(

                  title:  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  leading: Icon(
                      Icons.info,
                      size: 25,
                      color: Theme.of(context).primaryColor
                  ),
                  trailing: Icon(
                      Icons.arrow_right,
                      size: 30,
                      color: Theme.of(context).primaryColor
                  ),
                  onTap: () {
                    // AboutScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutScreen()),
                    );
                  },
                ),
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
                ListTile(

                  title:  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  leading: Icon(
                      Icons.settings,
                      size: 25,
                      color: Theme.of(context).primaryColor
                  ),
                  trailing: Icon(
                      Icons.arrow_right,
                      size: 30,
                      color: Theme.of(context).primaryColor
                  ),
                  onTap: () {
                    // Handle settings tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 30,),

          const SizedBox(height: 30,),
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
                ListTile(

                  title:  Text(
                    'Clear Content',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  leading: Icon(
                      Icons.lock_reset_outlined,
                      size: 25,
                      color: Theme.of(context).primaryColor
                  ),
                  trailing: Icon(
                      Icons.arrow_right,
                      size: 30,
                      color: Theme.of(context).primaryColor
                  ),
                  onTap: () {
                    // Clear Content
                    _showClearContentDialog(context);
                  },
                ),
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 30,),

          const SizedBox(height: 30,),
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Container(height: lineHeight, color:Theme.of(context).primaryColor),

                Container(height: lineHeight, color:Theme.of(context).primaryColor),
                ListTile(

                  title:  LogoutWidget(),
                  leading: Icon(
                      Icons.account_circle,
                      size: 25,
                      color: Theme.of(context).primaryColor
                  ),
                  trailing: Icon(
                      Icons.logout,
                      size: 20,
                      color: Theme.of(context).primaryColor
                  ),
                  onTap: () {
                    // Handle settings tap

                  },
                ),
                Container(height: lineHeight, color:Theme.of(context).primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 30,),

          // LogoutWidget()
          // Add more ListTile widgets for additional items
        ],
      ),

      // To Show Ads
      bottomNavigationBar: SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}

