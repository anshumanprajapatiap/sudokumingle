import 'dart:math';

import 'package:sudokumingle/utils/sudokuListInString.dart';

import 'SudokuBoardEnums.dart';

class SudokuGenerator {

  List<List<int>> getSudokuFromString(String stringOfSudoku){
    List<List<int>> rtn = List.generate(9, (i) => List.generate(9, (j) => 0));

    for (int i = 0; i < 81; i++) {
      int row = i ~/ 9;
      int col = i % 9;
      rtn[row][col] = int.parse(stringOfSudoku[i]);
    }
    return rtn;
  }

  late List<List<int?>> grid;
  late Random random;

  SudokuGenerator() {
    grid = List.generate(9, (index) => List<int?>.filled(9, null));
    random = Random();
  }

  bool checkValue(int row, int col, int value) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == value || grid[i][col] == value) {
        return false;
      }
    }

    final int startRow = 3 * (row ~/ 3);
    final int startCol = 3 * (col ~/ 3);

    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (grid[r][c] == value) {
          return false;
        }
      }
    }

    return true;
  }

  bool solveGrid() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int value = 1; value <= 9; value++) {
            if (checkValue(row, col, value)) {
              grid[row][col] = value;
              if (solveGrid()) {
                return true;
              } else {
                grid[row][col] = 0;
              }
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  List<List<int?>> generateSudoku(String input, Difficulty difficulty) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        final int value = int.parse(input[i * 9 + j]);
        grid[i][j] = value;
      }
    }

    final solvedSudoku = List.generate(9, (index) => List<int>.from(grid[index]));

    List<List<int?>> toBeSolvedSudoku = List.generate(9, (index) => List<int?>.from(grid[index]));

    final List<int> emptyCellsIndices = List.generate(81, (index) => index);
    emptyCellsIndices.shuffle(random);

    int emptyCells = 0;
    switch (difficulty) {
      case Difficulty.none:
        emptyCells = 0;
        break;
      case Difficulty.easy:
        emptyCells = 2; //needtochange
        break;
      case Difficulty.medium:
        emptyCells = 50;
        break;
      case Difficulty.hard:
        emptyCells = 60;
        break;
      case Difficulty.master:
        emptyCells = 65;
        break;
      case Difficulty.grandmaster:
        emptyCells = 70;
        break;
      case Difficulty.donnottry:
        emptyCells = 75;
        break;
    }

    for (int i = 0; i < emptyCells; i++) {
      final int index = emptyCellsIndices[i];
      final int row = index ~/ 9;
      final int col = index % 9;
      toBeSolvedSudoku[row][col] = null;
    }

    return toBeSolvedSudoku;
  }

  void printGrid(List<List<int?>> grid) {
    for (final row in grid) {
      print(row);
    }
  }
}

class SudokuGeneratorAgorithmV2{
  final sudoku = SudokuGenerator();

  Map<String, dynamic> generatePuzzle(Difficulty difficulty){
    // Generate correct Sudoku puzzle
    Random random = Random();
    String randomString = localSudokuListInString[random.nextInt(localSudokuListInString.length)];

    final correctSudoku = sudoku.getSudokuFromString(randomString);
    final toBeSolvedSudoku = sudoku.generateSudoku(randomString, difficulty);
    print('fromSudokuGeneratorAgorithmV2 $correctSudoku');
    return {
      'correctSudoku': correctSudoku,
      'toBeSolvedSudoku': toBeSolvedSudoku,
      'difficulty': difficulty
    };
  }
}

// void main() {
//   //final validSudokuString = "864371259325849761971265843436192587198657432257483916689734125713528694542916378";
//   final difficulty = Difficulty.medium;
//   final sudokuPuzzler = SudokuGeneratorAgorithmV2();
//
//   final res = sudokuPuzzler.generatePuzzle(difficulty);
//   print("Solved Sudoku:");
//   sudokuPuzzler.sudoku.printGrid(res['correctSudoku']);
//   print("Puzzle Solved Sudoku:");
//   sudokuPuzzler.sudoku.printGrid(res['toBeSolvedSudoku']);
// }
