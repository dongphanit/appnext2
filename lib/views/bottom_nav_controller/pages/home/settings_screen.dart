
// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tour_app/constant/constant.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('users').doc(firebaseAuth.currentUser?.uid).update({
              'role': 'CardHolder',
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User upgraded to CardHolder!')),
            );
          },
          child: Text('Upgrade to CardHolder'),
        ),
      ),
    );
  }
}
