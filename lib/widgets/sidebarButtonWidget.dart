import 'package:flutter/material.dart';

class SidebarButtonWidget extends StatelessWidget {
  final List<String> difficultyLevels;
  final Function(String) onPressed;
  final String selectedDifficulty;

  SidebarButtonWidget({
    required this.difficultyLevels,
    required this.onPressed,
    required this.selectedDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    final fixedSideButtonSize =
    MaterialStateProperty.all(Size(0, MediaQuery.of(context).size.height * 0.15));

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 1,
        width: MediaQuery.of(context).size.width * 0.13,
        color: Theme.of(context).secondaryHeaderColor, // Set sidebar background color
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...difficultyLevels.map((difficulty) => ElevatedButton(
              onPressed: () => onPressed(difficulty),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  selectedDifficulty == difficulty
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                minimumSize: fixedSideButtonSize,
              ),
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  difficulty,
                  style: TextStyle(
                    color: selectedDifficulty != difficulty
                        ? Theme.of(context).secondaryHeaderColor.withOpacity(0.7)
                        : Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
