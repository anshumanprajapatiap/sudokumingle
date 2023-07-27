import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  final String contactEmail = "minglebytes@gmail.com";
  final String developerName = "Mingle Bytes";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              // height: MediaQuery.sizeOf(context).width*0.5,
              child: Image.asset(
                "assets/images/logo/sudoku-mingle-3.png",
                // width: MediaQuery.of(context).size.width*0.5,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'SudokuMingle',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Version:  $_version',
              style: TextStyle(
                  fontSize: 16.0,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24.0),

            Text(
              'Contact Details:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
                'Email: $contactEmail',
              style: TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.normal,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 100,)
            // / Add some spacing

          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        child: Container(
          alignment: Alignment.center,
          // color: Theme.of(context).primaryColor,
          height: 60,
          child: Text(
            '$developerName',
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),),
        ),
      )
    );
  }
}
