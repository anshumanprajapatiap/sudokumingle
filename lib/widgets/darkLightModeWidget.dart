
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../providers/darkThemeProvider.dart';


class DarkLightModeIconWidget extends StatefulWidget {
  const DarkLightModeIconWidget({Key? key}) : super(key: key);

  @override
  State<DarkLightModeIconWidget> createState() => _DarkLightModeIconWidgetState();
}

class _DarkLightModeIconWidgetState extends State<DarkLightModeIconWidget> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSwitchProvider>(context);

    return Builder(
      builder: (context) => IconButton(
        icon: themeProvider.isDarkMode ? Icon(Icons.dark_mode) : Icon(Icons.light_mode, color: Colors.black,),
        onPressed: () {
          themeProvider.toggleTheme();
          themeProvider.getTheme();
        },
      ),
    );
  }
}


