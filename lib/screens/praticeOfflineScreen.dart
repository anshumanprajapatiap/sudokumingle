import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sudokumingle/utils/SudokuBoardEnums.dart';

import '../utils/adMobUtility.dart';
import '../utils/sudokuGeneratorNewAlgorithm.dart';
import '../widgets/sudokuGridWidget.dart';

class PraticeOfflineSudokuScreen extends StatefulWidget {
  Difficulty difficultyLevel;

  PraticeOfflineSudokuScreen({required this.difficultyLevel});

  @override
  State<PraticeOfflineSudokuScreen> createState() =>
      _PraticeOfflineSudokuScreenState();
}

class _PraticeOfflineSudokuScreenState
    extends State<PraticeOfflineSudokuScreen> {
  Difficulty selectedDifficulty = Difficulty.easy;
  late Map<String, dynamic> su;

  AdMobUtility adMobUtility = AdMobUtility();

  late BannerAd bannerAd;
  initBannerAd() {
    bannerAd = adMobUtility.bottomBarAd();
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    initBannerAd();
    selectedDifficulty = widget
        .difficultyLevel; // Initialize selectedDifficulty using widget.difficultyLevel
    final sudokuPuzzler = SudokuGeneratorAgorithmV2();
    Map<String, dynamic> res = sudokuPuzzler.generatePuzzle(selectedDifficulty);
    setState(() {
      su = res;
    });
  }

  bool _showColorOptions = false; // Track if color options are shown

  void _toggleColorOptions() {
    setState(() {
      _showColorOptions = !_showColorOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Pratice Sudoku'),
      ),

      // body: SudokuGridWidget(
      //   generatedSudoku: su,
      // ),
      body: Stack(
        children: [
          SudokuGridWidget(
            generatedSudoku: su,
          ),
          if (_showColorOptions)
            Positioned(
              top: 0,
              left: MediaQuery.sizeOf(context).width * 0.4,
              right: 0,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ColorOption(
                          color:
                              Colors.red), // Customize with your color options
                      ColorOption(color: Colors.blue),
                      ColorOption(color: Colors.green),
                      // ColorOption(color: Colors.red), // Customize with your color options
                      // ColorOption(color: Colors.blue),
                      // ColorOption(color: Colors.green),
                      // Add more color options as needed
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: SizedBox(
        height: bannerAd.size.height.toDouble(),
        width: bannerAd.size.width.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;

  ColorOption({required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle color option selection here
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
