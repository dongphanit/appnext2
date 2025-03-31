// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbbb/constant/constant.dart';
import 'package:bbbb/views/auth/login_screen.dart';
import 'package:bbbb/views/bottom_nav_controller/pages/home/buyer_order.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('My Order'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerOrderListScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Upgrade to CardHolder'),
            onTap: () {
              FirebaseFirestore.instance.collection('users').doc(firebaseAuth.currentUser?.uid).set({
                'role': 'CardHolder',
              }, SetOptions(merge: true));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User upgraded to CardHolder!')),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () async {
              // Open privacy policy URL
              // const url = 'https://your-privacy-policy-url.com';
              // if (await canLaunch(url)) {
              //   await launch(url);
              // } else {
              //   throw 'Could not launch $url';
              // }
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              firebaseAuth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
