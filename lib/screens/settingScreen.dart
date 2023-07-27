import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/soundProvider.dart';

import '../providers/darkThemeProvider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Define boolean variables to store the on/off state of each setting
  bool notificationEnabled = false;
  bool soundEnabled = false;
  final lineHeight = 0.3;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSwitchProvider>(context);
    final soundProvider = Provider.of<SoundProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Column(
          children: [
            Container(height: lineHeight, color: Theme.of(context).primaryColor),
            // Notification Setting
            SwitchListTile(
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              value: notificationEnabled,
              onChanged: (value) {
                setState(() {
                  notificationEnabled = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              secondary: Icon(
                Icons.notifications,
                size: 25,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(height: lineHeight, color: Theme.of(context).primaryColor),

            // Sound Setting
            SwitchListTile(
              title: Text(
                'Sound',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              value: soundProvider.isSoundOn,
              onChanged: (value) {
                soundProvider.toggleSound();
                soundProvider.getSound();
              },
              activeColor: Theme.of(context).primaryColor,
              secondary: Icon(
                Icons.volume_up,
                size: 25,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(height: lineHeight, color: Theme.of(context).primaryColor),

            // Dark Mode Setting
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
                themeProvider.getTheme();
              },
              activeColor: Theme.of(context).primaryColor,
              secondary: Icon(
                Icons.dark_mode,
                size: 25,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(height: lineHeight, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
