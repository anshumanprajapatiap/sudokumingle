import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudokumingle/providers/darkThemeProvider.dart';
import 'package:sudokumingle/providers/googleSignInProvider.dart';
import 'package:sudokumingle/screens/bottomNavigationBar.dart';
import 'package:sudokumingle/screens/splashScreen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeSwitchProvider()),
      ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
    ],
    child: MyApp(),
  )
  );
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
        print('THEME');
        print(themeProvider.getTheme());
        return MaterialApp(
          title: 'My App',
          theme: themeProvider.getTheme(),
          //home: TabsScreen(),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              //print(snapshot.data!.displayName);
              //splash Screen
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                );
              } else if (snapshot.hasData) {
                // toward dashboard
                return SplashScreen(isLoggedIn: true);
              } else if (snapshot.hasError) {
                return Center(child: const Text('Check your connection, Something Went Wrong!'));
              } else {
                // towards login page
                return SplashScreen(isLoggedIn: false);
              }
            },
          ),
        );
      },
    );
  }
}

