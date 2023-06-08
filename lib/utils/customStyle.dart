import 'dart:ui';

import 'package:flutter/material.dart';


class SudokuMingleTheme {
  static final lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(),
    //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );

  static final darkTheme = ThemeData(
    canvasColor: Color(0xFF1B1F24),
    colorScheme: const ColorScheme.dark(),
    secondaryHeaderColor: Colors.cyan
    //colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
  );

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
