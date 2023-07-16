
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:sudokumingle/screens/authScreen.dart';
import '../main.dart';
import 'bottomNavigationBar.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoggedIn;
  const SplashScreen({
    Key? key,
    required this.isLoggedIn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(40.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/sudokuMingleLogo.png'),
            SizedBox(height: 30,),
            Text(
              'Sudoku Mingle',
              style: Theme.of(context).textTheme.titleLarge,)
            ,
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 0.0, right: 10),
                    child: const Divider(
                      color: Colors.white,
                      height: 80,
                    ),
                  ),
                ),
                Text(
                  'Play With Your Sudoku Partner',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 0),
                    child: const Divider(
                      color: Colors.white,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),
            Text(
              'By Mingle Bytes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );

    return isLoggedIn
        ? AnimatedSplashScreen(
          duration: 300,
          splash: content,
          splashTransition: SplashTransition.fadeTransition,
          //pageTransitionType: PageTransitionType.scale,
          splashIconSize: 600,
          backgroundColor: Theme.of(context).primaryColor,
          nextScreen: TabsScreen(),
        )
        : AnimatedSplashScreen(
          duration: 300,
          splash: content,
          splashTransition: SplashTransition.fadeTransition,
          //pageTransitionType: PageTransitionType.scale,
          splashIconSize: 600,
          backgroundColor: Theme.of(context).primaryColor,
          nextScreen: AuthScreen(),
         );
  }
}