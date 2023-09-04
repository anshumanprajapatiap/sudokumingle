import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/constants.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  GoogleSignInAccount? get googleUser => _user;

  bool _isLoading = false;
  bool _isError = false;
  String __errorValue = '';
  bool get getIsLoading => _isLoading;
  bool get getIsError => _isError;
  String get getErrorValue => __errorValue;

  setIsError(bool value, String error){
    _isError = value;
    __errorValue = error;
  }

  setIsLoading(bool value){
    _isLoading = value;
  }

  Future<void> logoutFromGoogleAuth() async {
    try{
      await googleSignIn.signOut();
      _user = null;
      //await FirebaseAuth.instance.signOut();
      // print('logoutFrom');
    }catch (e) {
      print('Error signing out. Try again.');
    }
  }

  Future<void> signInWithGoogleAuth() async {
    //var db = FirebaseFirestore.instance;
    setIsLoading(true);
    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null){
        setIsLoading(false);
        return;
      }

      _user = googleUser;

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );
      final loggedInUser = await FirebaseAuth.instance.signInWithCredential(credential);

      // Create a new CustomeUserProfile
      final _currentUser = FirebaseAuth.instance.currentUser!;

      // print('currentuser->${_currentUser!.uid}');
      // print(_currentUser);

      final userDoc = FirebaseFirestore.instance
          .collection(Constants.CUSTOM_USER_PROFILE)
          .doc(_currentUser!.uid);

      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        // Document already exists
        // You can handle the case when the document already exists
        // print('allready exist');
      } else {
        // Document doesn't exist, create it
        final newUserData = {
          'name': _currentUser!.displayName,
          'email': _currentUser!.email,
          'mingleCoins': 1500,
          'rank': 0,
          'userAvatar': 0,
          'isPro': false,
        };
        // print('newuser');
        await userDoc.set(newUserData);
      }

    } on FirebaseAuthException catch(e){
      print(e.toString());
      // setIsError(true, e.toString());
    } on PlatformException catch (e) {
      // Handle different platform exceptions
      String exp = 'Google Sign-In PlatformException: ${e.code} - ${e.message}';
      setIsError(true, exp);
    } catch (e) {
      // Handle other exceptions
      setIsError(true, e.toString());
      print('Error during Google Sign-In: $e');
    }finally {
      setIsError(false, '');
      setIsLoading(false);
      notifyListeners();
    }
  }

}