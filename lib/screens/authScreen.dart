import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import '../providers/googleSignInProvider.dart';
import '../widgets/singInWidget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.8,
                height: MediaQuery.of(context).size.width*0.8,
                color: Theme.of(context).secondaryHeaderColor,
                child: Center(child: Text('Space for Ads')),
              ),
              SizedBox(
                height: 30,
              ),
              GoogleSignInWidget(),
            ],
          ),
          ),
        ),
      );
  }

}
