import 'package:flutter/material.dart';

class CircularWidget extends StatelessWidget {
  final String imageUrl;
  final double radius;
  const CircularWidget({super.key, required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.fill,
        // color: Colors.green,
      ),
    );
  }
}
