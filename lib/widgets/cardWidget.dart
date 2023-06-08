import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Color color;

  CardWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Center(
        child: Text(
          'Card',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
