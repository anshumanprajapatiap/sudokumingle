import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/customStyle.dart';
import 'darkThemePreference.dart';

class ThemeSwitchProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    // print('mode: -${_isDarkMode}');
    darkThemePreference.setDarkTheme(_isDarkMode);
    notifyListeners();
  }

  ThemeData getTheme() {
    if (darkThemePreference.getTheme() != null) {
      _isDarkMode = darkThemePreference.getTheme()!;
    }
    // print('getign theme');
    return _isDarkMode ? SudokuMingleTheme.darkTheme : SudokuMingleTheme.lightTheme;
  }

}