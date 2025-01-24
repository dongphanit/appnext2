// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/views/auth/login_screen.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/buyer_order.dart';
import 'package:url_launcher/url_launcher.dart'; // Import your login screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
            const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Settings',
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            ),
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
              const url = 'https://your-privacy-policy-url.com';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
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
