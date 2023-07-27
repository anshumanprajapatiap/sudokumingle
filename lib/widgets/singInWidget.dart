import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/googleSignInProvider.dart';
import '../screens/splashScreen.dart';

class GoogleSignInWidget extends StatefulWidget {
  const GoogleSignInWidget({Key? key}) : super(key: key);

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  var _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return _isAuthenticating
        ? CircularProgressIndicator()
        :Consumer<GoogleSignInProvider>(
      builder: (context, signInProvider, _) {
        return ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isAuthenticating=true;
            });
            signInProvider.signInWithGoogleAuth().then((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => SplashScreen(isLoggedIn: true,),
              ));
            });
            setState(() {
              _isAuthenticating=false;
            });

          },
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white,),
          label: const Text('SignIn with the Google'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(1000),
            maximumSize: const Size(double.infinity, 100),
            elevation: 10,
            padding: EdgeInsets.all(12),
            minimumSize: Size(
                MediaQuery.sizeOf(context).width*0.8,
                50
            )
          ),
        );
      }
    );
  }
}
