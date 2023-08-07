import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/googleSignInProvider.dart';
import '../utils/adMobUtility.dart';
import '../widgets/singInWidget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AdMobUtility adMobUtility = AdMobUtility();

  late BannerAd upperProfileAd;
  initBannerAd(){
    upperProfileAd = adMobUtility.largeBannerAd();
    upperProfileAd.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: false);
    googleSignInProvider.setIsLoading(false);
    initBannerAd();
  }

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

              SizedBox(
                height: MediaQuery.sizeOf(context).width*0.8,
                width: MediaQuery.sizeOf(context).width*0.8,
                child: AdWidget(ad: upperProfileAd),
              ),

              // Container(
              //
              //   width: MediaQuery.sizeOf(context).width*0.8,
              //   height: MediaQuery.sizeOf(context).width*0.8,
              //   color: Theme.of(context).primaryColor,
              //   //adds
              //   child: const Center(child: Text('')),
              // ),

              const SizedBox(
                height: 30,
              ),

              GoogleSignInWidget(),

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
