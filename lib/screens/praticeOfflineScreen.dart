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
    //su = SudokuGenerators.generateSudoku(selectedDifficulty);
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
        isMultiplayer: false,
        activeGameId: '',
        activePuzzleId: '',
      ),

    );
  }
}
// body: Column(
//   mainAxisAlignment: MainAxisAlignment.start,
//   children: [
//
//     Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Text('Difficulty'),
//         Text('Mistakes: 3/3'),
//         TextButton.icon(onPressed: () {}, icon: Icon(Icons.pause), label: Text('00:00'),)
//       ],
//     ),
//
//     SizedBox(height: 8),
//
//     Container(
//       padding: EdgeInsets.all(16.0),
//       child: SudokuGridWidget(),
//     ),
//
//     SizedBox(height: 8),
//
//     // Padding(
//     //   padding: EdgeInsets.symmetric(horizontal: 8.0),
//     //   child: Row(
//     //     mainAxisAlignment: MainAxisAlignment.center,
//     //     children: [
//     //       ElevatedButton(
//     //         onPressed: () {
//     //           // Handle reset button tap here
//     //         },
//     //         style: ElevatedButton.styleFrom(
//     //           padding: EdgeInsets.zero, // Remove default padding
//     //         ),
//     //         child: Column(
//     //           mainAxisSize: MainAxisSize.min,
//     //           children: [
//     //             Icon(Icons.restore),
//     //             SizedBox(height: 4),
//     //             Text('Reset'),
//     //           ],
//     //         ),
//     //       ),
//     //       ElevatedButton(
//     //         onPressed: () {
//     //           // Handle reset button tap here
//     //         },
//     //         style: ElevatedButton.styleFrom(
//     //           padding: EdgeInsets.zero, // Remove default padding
//     //         ),
//     //         child: Column(
//     //           mainAxisSize: MainAxisSize.min,
//     //           children: [
//     //             Icon(Icons.backspace),
//     //             SizedBox(height: 4),
//     //             Text('Erase'),
//     //           ],
//     //         ),
//     //       ),
//     //       ElevatedButton(
//     //         onPressed: () {
//     //           // Handle reset button tap here
//     //         },
//     //         style: ElevatedButton.styleFrom(
//     //           padding: EdgeInsets.zero, // Remove default padding
//     //         ),
//     //         child: Column(
//     //           mainAxisSize: MainAxisSize.min,
//     //           children: [
//     //             Icon(Icons.note),
//     //             SizedBox(height: 4),
//     //             Text('Notes'),
//     //           ],
//     //         ),
//     //       ),
//     //       ElevatedButton(
//     //         onPressed: () {
//     //           // Handle reset button tap here
//     //         },
//     //         style: ElevatedButton.styleFrom(
//     //           padding: EdgeInsets.zero, // Remove default padding
//     //         ),
//     //         child: Column(
//     //           mainAxisSize: MainAxisSize.min,
//     //           children: [
//     //             Icon(Icons.lightbulb),
//     //             SizedBox(height: 4),
//     //             Text('Hint'),
//     //           ],
//     //         ),
//     //       ),
//     //     ],
//     //   ),
//     // ),
//     //
//     // SizedBox(height: 50),
//     //
//     // Padding(
//     //
//     //   padding: EdgeInsets.symmetric(horizontal: 16.0),
//     //   child: FractionallySizedBox(// Adjust this value as needed
//     //     child: Row(
//     //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     //       children: List.generate(9, (index) {
//     //         int number = index + 1;
//     //         return GestureDetector(
//     //           onTap: () {
//     //             // Handle number button tap here
//     //             print(number);
//     //           },
//     //           child: Container(
//     //             width: 35,
//     //             height: 35,
//     //             decoration: BoxDecoration(
//     //               color: Theme.of(context).primaryColor,
//     //               borderRadius: BorderRadius.circular(8.0),
//     //             ),
//     //             child: Center(
//     //               child: Text(
//     //                 number.toString(),
//     //                 style: TextStyle(
//     //                   color: Colors.white,
//     //                   fontSize: 30,
//     //                 ),
//     //               ),
//     //             ),
//     //           ),
//     //         );
//     //       }),
//     //     ),
//     //   ),
//     // ),
//
//   ],
// ),