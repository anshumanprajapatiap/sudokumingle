import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Color color;

  CardWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.5,
      height: MediaQuery.of(context).size.height * 1.5,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: color,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 50,),
            ),
          ),
          // Positioned.fill(
          //   child: Padding(
          //     padding: const EdgeInsets.all(20.0),
          //     child: Image.network(
          //       'https://example.com/image.jpg', // Replace with your image URL
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'On 24/06/2023',
              style: TextStyle(fontSize: 18, color: Colors.white24),
            ),
          ),
          // Positioned(
          //   top: 40,
          //   right: 25,
          //   child: Row(
          //     children: [
          //       const Text('participants', style: TextStyle(fontSize: 18, color: Colors.white),),
          //       IconButton(
          //         onPressed: () {  },
          //         icon: Icon(Icons.supervised_user_circle_rounded, color: Colors.white,),
          //       ),
          //       Text('60', style: TextStyle(fontSize: 18, color: Colors.white),),
          //     ],
          //   ),
          // ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                const Text('participants', style: TextStyle(fontSize: 18, color: Colors.white24),),
                IconButton(
                  onPressed: () {  },
                  icon: Icon(Icons.supervised_user_circle_rounded, color: Colors.white24,),
                ),
                Text('60', style: TextStyle(fontSize: 18, color: Colors.white24),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

