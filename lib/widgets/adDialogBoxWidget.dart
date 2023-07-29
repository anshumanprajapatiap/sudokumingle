import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/firebaseUserDataProvider.dart';

class AdDialogBoxWidget extends StatefulWidget {
  @override
  _AdDialogBoxWidgetState createState() => _AdDialogBoxWidgetState();
}

class _AdDialogBoxWidgetState extends State<AdDialogBoxWidget> {
  int _secondsRemaining = 6;
  bool _timerExpired = false;

  void startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timerExpired = true;
          }
        });
      }
      startTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUserDataProvider = Provider.of<FirebaseUserDataProvider>(context);
    return Dialog(
      insetAnimationCurve: Curves.bounceOut,
      insetAnimationDuration: const Duration(milliseconds: 100),
      backgroundColor: Theme.of(context).secondaryHeaderColor, // Set your desired background color here
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Advertisement',
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 5,),
            // Add your ad widget here
            Text('Do watch ad to get coins ',
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5,),
            
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.5,
              width: MediaQuery.sizeOf(context).width*0.9,
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            _timerExpired
                ? ElevatedButton(
              onPressed: () {
                firebaseUserDataProvider.setCustomUserProfileDataCoin(250);
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withAlpha(500)),
                minimumSize: MaterialStateProperty.all(Size(MediaQuery.sizeOf(context).width*0.5, 40)),
              ),
              child: Text('Exit',),
            )
                : ElevatedButton(
                onPressed: (){

                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withAlpha(500)),
                    minimumSize: MaterialStateProperty.all(Size(MediaQuery.sizeOf(context).width*0.5, 40)),
                ),
                child: Text('$_secondsRemaining seconds remaining...')
              ),
          ],
        ),
      ),
    );
  }
}
