import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        .collection('payment_verifications')
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
            String imageUrl = paymentData['imageUrl'] ?? '';

            if (paymentData['status'] == 'completed') {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(imageUrl),
                    SizedBox(height: 20),
                    Text(
                      'Congratulations! Payment successfully completed.',
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(imageUrl)
                        : Text(
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
