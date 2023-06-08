import 'package:flutter/material.dart';

class ScrollableCarousel extends StatelessWidget {
  final List<Widget> cards;

  ScrollableCarousel({required this.cards});

  Future<void> _showConfirmationDialog(BuildContext context, Widget cards) async {
    bool isLive = true; // change if after
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: isLive ? Text('Oppss you are late content is not live') : Text('Do you want to play this Game?'),
          actions: isLive
              ? [
                  TextButton(
                    child: Text('Go Back'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]
              : [
                  TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      // Handle "Yes" button click here
                      Navigator.of(context).pop();
                    },
                  ),
                ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/carosuelBGImage.png'),
          fit: BoxFit.cover,
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // Handle card tap here
              _showConfirmationDialog(context, cards[index]);
              //print('Card $index tapped');
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: cards[index],
            ),
          );
        },
      ),
    );
  }
}
