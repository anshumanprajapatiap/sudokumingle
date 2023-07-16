import 'dart:ui';

import 'package:flutter/material.dart';


class SudokuMingleTheme {
  static final lightTheme = ThemeData(

    // colorScheme: const ColorScheme.light(),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    primaryColor: Colors.blueGrey,
    secondaryHeaderColor: Colors.blueGrey[50],
    cardColor: Color(0xFF2752E7),
  );

  static final darkTheme = ThemeData(
    //canvasColor: Color(0xFF1B1F24),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    primaryColor: Colors.blueGrey[50],
    secondaryHeaderColor: Colors.blueGrey,
    cardColor: Color(0xFF12286C),
  );

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
