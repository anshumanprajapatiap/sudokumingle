import 'package:flutter/material.dart';

import '../widgets/darkLightModeWidget.dart';
import '../widgets/logoutWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: const Text(
            'Profile',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal
        ),
        ),
        actions: [
          DarkLightModeIconWidget(),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            color: Theme.of(context).primaryColor// Replace with your profile section content
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),
          ListTile(
            title: const Text('Options'),
            onTap: () {
              // Handle options tap
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              // Handle settings tap
            },
          ),

          LogoutWidget()
          // Add more ListTile widgets for additional items
        ],
      ),
    );
  }
}

