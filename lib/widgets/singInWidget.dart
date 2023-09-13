import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/screens/bottomNavigationBar.dart';

import '../providers/googleSignInProvider.dart';
import '../screens/splashScreen.dart';

class GoogleSignInWidget extends StatefulWidget {
  const GoogleSignInWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {

  @override
  Widget build(BuildContext context) {
    final googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: true);

    return ElevatedButton.icon(
              onPressed: () {
                googleSignInProvider.signInWithGoogleAuth().then((_) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SplashScreen(isLoggedIn: true),
                  ));
                });
              },
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white,),
              label: const Text('SignIn with the Google'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(1000),
                  maximumSize: const Size(double.infinity, 100),
                  elevation: 10,
                  padding: const EdgeInsets.all(12),
                  minimumSize: Size(
                      MediaQuery.sizeOf(context).width*0.8,
                      50
                  )
              ),
            );
  }
}
