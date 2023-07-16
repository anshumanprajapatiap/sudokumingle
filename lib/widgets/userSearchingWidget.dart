import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'circularImageWidget.dart';

class UserSearchingWidget extends StatefulWidget {
  final int milliSecondsDelayTime;
  final bool searching;
  int userAvatarIndex;
  UserSearchingWidget({super.key, required this.milliSecondsDelayTime, required this.searching, this.userAvatarIndex=0});

  @override
  State<UserSearchingWidget> createState() => _UserSearchingWidgetState();
}

class _UserSearchingWidgetState extends State<UserSearchingWidget> {
  String currentUrl = Constants.avatarList[0];
  int currentIndex = 0;
  int i = 0;
  void loadAvatarsWithDelay() async{
    for (i; i < Constants.avatarList.length; i++) {
      await Future.delayed(Duration(milliseconds: widget.milliSecondsDelayTime)); // Adjust the duration as needed
      if (mounted) {
        setState(() {
          currentIndex = i;
          if(i==Constants.avatarList.length-1){
            i = 0;
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    int currentRandom = Random().nextInt(Constants.avatarList.length);
    setState(() {
      currentUrl = Constants.avatarList[currentRandom];
    });
    if(widget.searching){
      loadAvatarsWithDelay();
    } else {
      setState(() {
        currentIndex = widget.userAvatarIndex;
        print('currentIndex = widget.userAvatarIndex;');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String url = Constants.avatarList[currentIndex];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularWidget(imageUrl: currentUrl, radius: MediaQuery.of(context).size.width * 0.08,),
          Icon(Icons.arrow_right_alt_sharp, size: 28, color: Theme.of(context).primaryColor,),
          CircularWidget(imageUrl: url, radius: MediaQuery.of(context).size.width * 0.08,),
        ],
      ),
    );
  }
}
