
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/firebaseUserDataProvider.dart';
import 'package:sudokumingle/screens/authScreen.dart';
import '../main.dart';
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
  void initState() {
    // TODO: implement initState

    Future.delayed(const Duration(microseconds: 5), () async {
      final userDataProvider = Provider.of<FirebaseUserDataProvider>(context, listen: false);
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await userDataProvider.fetchCustomUserProfileData();
        await userDataProvider.fetchUserGameHistory();
      }
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //   builder: (ctx) => const TabsScreen(),
      // ));
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
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

            SizedBox(height: MediaQuery.sizeOf(context).height*0.2,),
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

    return widget.isLoggedIn
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