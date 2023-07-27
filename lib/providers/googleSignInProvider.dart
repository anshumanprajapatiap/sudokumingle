import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/constants.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  GoogleSignInAccount? get googleUser => _user;

  Future logoutFromGoogleAuth() async {
    try{
      await googleSignIn.signOut();
      _user = null;
      //await FirebaseAuth.instance.signOut();
      print('logoutFrom');
    }catch (e) {
      print('Error signing out. Try again.');
    }
  }

  Future signInWithGoogleAuth() async {
    //var db = FirebaseFirestore.instance;

    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );
      final loggedInUser = await FirebaseAuth.instance.signInWithCredential(credential);

      // Create a new CustomeUserProfile
      final _currentUser = FirebaseAuth.instance.currentUser!;

      print('currentuser->${_currentUser!.uid}');
      print(_currentUser);

      final userDoc = FirebaseFirestore.instance
          .collection(Constants.CUSTOM_USER_PROFILE)
          .doc(_currentUser!.uid);

      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        // Document already exists
        // You can handle the case when the document already exists
        print('allready exist');
      } else {
        // Document doesn't exist, create it
        final newUserData = {
          'name': _currentUser!.displayName,
          'email': _currentUser!.email,
          'mingleCoins': 1500,
          'rank': 0,
          'isPro': false,
        };

        await userDoc.set(newUserData);
      }

      print('newuser');
    } on FirebaseAuthException catch(e){
      if(e.code == 'email-already-in-use'){

      }
      print(e.toString());
    }
    notifyListeners();
  }

}