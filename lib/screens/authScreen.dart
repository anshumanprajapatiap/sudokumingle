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
      appBar: AppBar(
        title: Text(
          'Sudoku Mingle',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width*0.8,
                height: MediaQuery.sizeOf(context).width*0.8,
                color: Theme.of(context).primaryColor,
                //adds
                child: Center(child: Text('')),
              ),
              SizedBox(
                height: 30,
              ),
              const GoogleSignInWidget(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height*0.1,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height*0.1,
                child: Text(
                  'Mingle Bytes',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      );
  }

}
