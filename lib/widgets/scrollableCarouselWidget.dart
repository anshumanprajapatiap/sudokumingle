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
        return Dialog(
          insetAnimationCurve: Curves.bounceOut,
          insetAnimationDuration: const Duration(milliseconds: 100),
          backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                Text(
                  'Confirmation',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize:  28
                  ),
                ),
                SizedBox(height: 40,),
                isLive
                    ? Text(
                      'Oppss you are late content is not live',
                      style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.normal,
                          fontSize:  18,
                      ),
                    )
                    : Text(
                      'Do you want to play this Game?',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize:  18
                        ),
                      ),
                SizedBox(height: 40,),
                isLive
                    ? TextButton(
                      child: Text(
                          'Go Back',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize:  18
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                    : Row(
                      children: [
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
                    ),


              ]
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/carosuelBGImage.png'),
          fit: BoxFit.cover,
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      child: cards.isEmpty
          ?  Card(
              color: Theme.of(context).secondaryHeaderColor,
              child: Center(
                  child:  Text(
                      'No Active Contest',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold

                    ),
                  )
              ),
            )
          : ListView.builder(
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
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: cards[index],
                ),
              );
            },
          ),
    );
  }
}
