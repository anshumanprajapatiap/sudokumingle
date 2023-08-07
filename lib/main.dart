import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/darkThemeProvider.dart';
import 'package:sudokumingle/providers/firebaseGamePoolProvider.dart';
import 'package:sudokumingle/providers/firebaseRoomManagementProvider.dart';
import 'package:sudokumingle/providers/firebaseUserDataProvider.dart';
import 'package:sudokumingle/providers/googleSignInProvider.dart';
import 'package:sudokumingle/providers/soundProvider.dart';
import 'package:sudokumingle/screens/bottomNavigationBar.dart';
import 'package:sudokumingle/screens/splashScreen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  } else {
    // print('AdMob skipped for Ios');
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeSwitchProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseRoomManagementProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseUserDataProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseGamePoolProvider())
      ],
      child: const MyApp(),
    )
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwitchProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          routes: {
            TabsScreen.routeName: (ctx) => const TabsScreen(),
          },
          title: 'My App',
          theme: themeProvider.getTheme(),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                );
              } else if (snapshot.hasData) {
                return const SplashScreen(isLoggedIn: true);
              } else if (snapshot.hasError) {
                return const Center(child: Text('Check your connection, Something Went Wrong!'));
              } else {
                return const SplashScreen(isLoggedIn: false);
              }
            },
          ),
        );
      },
    );
  }
}

