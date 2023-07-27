// void main() {
//   List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
//   List<int> numberList = [1,2,3,4,5,6,7,8,9];
//
//   List<int> counter = [0]; // Wrap counter inside a List to pass by reference
//   solveGrid(grid, counter);
//   print(counter[0]);
//
//
//
//   // Display the grid row by row
//   for (int row = 0; row < 9; row++) {
//     print(grid[row].join(' '));
//   }
// }
//
// bool checkGrid(List<List<int>> grid) {
//   for (int row = 0; row < 9; row++) {
//     for (int col = 0; col < 9; col++) {
//       if (grid[row][col] == 0) {
//         return false;
//       }
//     }
//   }
//   return true;
// }
//
// bool solveGrid(List<List<int>> grid, List<int> counter) {
//   int row = -1;
//   int col = -1;
//
//   // Find next empty cell
//   for (int i = 0; i < 81; i++) {
//     row = i ~/ 9;
//     col = i % 9;
//     if (grid[row][col] == 0) {
//       for (int value = 1; value <= 9; value++) {
//         // Check that this value has not already been used on this row
//         if (!grid[row].contains(value)) {
//           // Check that this value has not already been used on this column
//           if (!grid.any((element) => element[col] == value)) {
//             // Identify which of the 9 squares we are working on
//             int startRow = (row ~/ 3) * 3;
//             int startCol = (col ~/ 3) * 3;
//
//             // Check that this value has not already been used in this 3x3 square
//             if (!_isValueInSquare(grid, startRow, startCol, value)) {
//               grid[row][col] = value;
//               if (checkGrid(grid)) {
//                 counter[0]++;
//                 break;
//               } else {
//                 if (solveGrid(grid, counter)) {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }
//       break;
//     }
//   }
//
//   // If we reach here, it means we didn't find a valid value for the current cell
//   // So, reset the cell value to 0 and backtrack
//   grid[row][col] = 0;
//   return false;
// }
//
//
// bool _isValueInSquare(List<List<int>> grid, int startRow, int startCol, int value) {
//   for (int i = 0; i < 3; i++) {
//     for (int j = 0; j < 3; j++) {
//       if (grid[startRow + i][startCol + j] == value) {
//         return true;
//       }
//     }
//   }
//   return false;
// }