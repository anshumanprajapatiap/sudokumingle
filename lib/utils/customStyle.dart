import 'dart:ui';

import 'package:flutter/material.dart';


class SudokuMingleTheme {
  static final lightTheme = ThemeData(

    // colorScheme: const ColorScheme.light(),
    scaffoldBackgroundColor: Colors.blueGrey[50],
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    primaryColor: Colors.blueGrey,
    secondaryHeaderColor: Colors.blueGrey[50],
    cardColor: Color(0xFF2752E7),
  );

  static final darkTheme = ThemeData(
    //canvasColor: Color(0xFF1B1F24),
    scaffoldBackgroundColor: Colors.blueGrey[900],
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey.shade50),
    primaryColor: Colors.blueGrey[400],
    secondaryHeaderColor: Colors.blueGrey[900],
    cardColor: Color(0xFF5883FF),
  );

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
