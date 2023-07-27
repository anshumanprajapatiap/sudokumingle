import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/settingScreen.dart';

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
        actions: [
          DarkLightModeIconWidget(),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            color: Theme.of(context).primaryColor// Replace with your profile section content
          ),
          SizedBox(height: 30,),
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
          SizedBox(height: 30,),

          SizedBox(height: 30,),
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
          SizedBox(height: 30,),

          // LogoutWidget()
          // Add more ListTile widgets for additional items
        ],
      ),
    );
  }
}

