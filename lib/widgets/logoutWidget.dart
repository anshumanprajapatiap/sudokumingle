import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/screens/authScreen.dart';
import 'package:sudokumingle/screens/splashScreen.dart';
import '../providers/googleSignInProvider.dart';

class LogoutWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleSignInProvider>(
        builder: (context, signInProvider, _) {
          return TextButton(
              onPressed: () {
                signInProvider.logoutFromGoogleAuth().then((_) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SplashScreen(isLoggedIn: false),
                  ));
                });
              },
              child: Row(
                children:[
                  Text(
                      'SignOut',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ]
              )
          );
        }
    );
  }
}