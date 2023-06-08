import 'dart:math';

import 'package:sudokumingle/utils/sudokuListInString.dart';

List<List<List<int>>> globalSudokuList = [[[]]];


class SudokuGenerators {

  static List<List<int>> getSudokuFromString(String stringOfSudoku){
    List<List<int>> rtn = List.generate(9, (i) => List.generate(9, (j) => 0));

    for (int i = 0; i < 81; i++) {
      int row = i ~/ 9;
      int col = i % 9;
      rtn[row][col] = int.parse(stringOfSudoku[i]);
    }
    return rtn;
  }

  static Map<String, dynamic> generateSudoku(String difficulty) {
    List<List<int>> correctSudoku =
    List.generate(9, (i) => List.generate(9, (j) => 0));
    List<List<int?>> toBeSolvedSudoku =
    List.generate(9, (i) => List.generate(9, (j) => null));

    // Generate correct Sudoku puzzle
    Random random = Random();
    String randomString = localSudokuListInString[random.nextInt(localSudokuListInString.length)];

    correctSudoku = getSudokuFromString(randomString);

    // Set difficulty level
    int numValues;
    int gap = random.nextInt(5);
    switch (difficulty) {
      case 'Easy':
        numValues = 50 - gap;
        break;
      case 'Medium':
        numValues = 40 - gap;
        break;
      case 'Hard':
        numValues = 30 - gap;
        break;
      case 'Master':
        numValues = 20 - gap;
        break;
      case 'Grandmaster':
        numValues = 10 - gap;
        break;
      default:
        numValues = 50 - gap;
        break;
    }

    // Generate toBeSolvedSudoku based on difficulty level
    int count = 0;
    while (count < numValues) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      if (toBeSolvedSudoku[row][col] == null) {
        toBeSolvedSudoku[row][col] = correctSudoku[row][col];
        count++;
      }
    }

    return {
      'correctSudoku': correctSudoku,
      'toBeSolvedSudoku': toBeSolvedSudoku,
      'difficulty': difficulty
    };
  }
}

// void main() {
//   Map<String, dynamic> rtn =
//   SudokuGenerators.generateSudoku('medium');
//
//   print(rtn['correctSudoku']);
//   print(rtn['toBeSolvedSudoku']);
//   print(rtn['difficulty']);
// }
