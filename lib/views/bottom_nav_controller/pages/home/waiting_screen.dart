import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbbb/views/screens/home_screen.dart';
import 'package:get/get.dart';

class WaitingScreen extends StatefulWidget {
  final String orderId;

  WaitingScreen({required this.orderId});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  String _imageUrl = '';
  late Stream<DocumentSnapshot> _paymentStream;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _paymentStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();
  }

  Future<void> _checkPaymentStatus(String orderId) async {
    try {
      // Additional logic if needed
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waiting for Payment Confirmation"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _paymentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            var paymentData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> imageUrls = paymentData['imageUrl'] ?? [];

            if (paymentData['status'] == 'completed') {
                return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var imageUrl in imageUrls) 
                    Image.network(
                      (imageUrl as Map<String, dynamic>)['url'],
                      width: 150, // Set the desired width
                      height: 300, // Set the desired height
                      fit: BoxFit.cover, // Adjust the image to cover the box
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Congratulations! Payment successfully completed.',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                       Get.to(() => HomeScreen());
                    },
                    child: Text('Go to Home'),
                  ),
                  ],
                ),
                );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                            'Waiting for payment confirmation...',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(),
                  ],
                ),
              );
            }
          } else {
            return Center(child: Text("No payment data available."));
          }
        },
      ),
    );
  }
}
