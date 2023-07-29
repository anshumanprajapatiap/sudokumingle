import 'package:flutter/material.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';

import '../utils/sudokuGeneratorNewAlgorithm.dart';
import '../utils/sudokuGenerators.dart';
import '../widgets/sudokuGridWidget.dart';

class PraticeOfflineSudokuScreen extends StatefulWidget {
  Difficulty difficultyLevel;

  PraticeOfflineSudokuScreen({required this.difficultyLevel});

  @override
  State<PraticeOfflineSudokuScreen> createState() => _PraticeOfflineSudokuScreenState();
}

class _PraticeOfflineSudokuScreenState extends State<PraticeOfflineSudokuScreen> {
  Difficulty selectedDifficulty = Difficulty.easy;
  late Map<String, dynamic> su;

  @override
  void initState() {
    super.initState();
    selectedDifficulty = widget.difficultyLevel; // Initialize selectedDifficulty using widget.difficultyLevel
    final sudokuPuzzler = SudokuGeneratorAgorithmV2();
    Map<String, dynamic> res = sudokuPuzzler.generatePuzzle(selectedDifficulty);
    setState(() {
      su = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Pratice Sudoku'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle theme change button tap here
            },
            icon: Icon(Icons.color_lens),
          ),
          IconButton(
            onPressed: () {
              // Handle settings button tap here
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),

      body: SudokuGridWidget(
        generatedSudoku: su,
      ),

    );
  }
}