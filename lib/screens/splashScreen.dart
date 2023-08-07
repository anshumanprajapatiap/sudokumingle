import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/authScreen.dart';
import 'bottomNavigationBar.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({
    Key? key,
    required this.isLoggedIn
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    bool userDataPresent =  false;
    if(widget.isLoggedIn){
      final User? user = FirebaseAuth.instance.currentUser;
      userDataPresent = user != null ? true : false;
    }

    Widget content = Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/logo/sudoku-mingle-3.png',
              width: MediaQuery.of(context).size.width*0.5,
            ),
            //SizedBox(height: 30,),
            Text(
              'Sudoku Mingle',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            )
            ,

            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 0.0, right: 10),
                    child: Divider(
                      color: Colors.white,
                      height: MediaQuery.sizeOf(context).height*0.1,
                    ),
                  ),
                ),
                Text(
                  'Play With Your Sudoku Partner',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 15
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 0),
                    child: Divider(
                      color: Colors.white,
                      height: MediaQuery.sizeOf(context).height*0.1,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.sizeOf(context).height*0.1,),
            Text(
              'By Mingle Bytes',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          ],
        ),
      ),
    );

    return userDataPresent
        ? AnimatedSplashScreen(
          duration: 300,
          splash: content,
          splashTransition: SplashTransition.fadeTransition,
          splashIconSize: 600,
          backgroundColor: Theme.of(context).primaryColor,
          nextScreen: const TabsScreen(),
        )
        : AnimatedSplashScreen(
          duration: 300,
          splash: content,
          splashTransition: SplashTransition.fadeTransition,
          splashIconSize: 600,
          backgroundColor: Theme.of(context).primaryColor,
          nextScreen: const AuthScreen(),
         );
  }
}