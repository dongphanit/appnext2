import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bbbb/views/bottom_nav_controller/pages/home/waiting_screen.dart';

class CardHolderFindingScreen extends StatefulWidget {
  final String orderId;

  const CardHolderFindingScreen({super.key, required this.orderId});

  @override
  _CardHolderFindingScreenState createState() =>
      _CardHolderFindingScreenState();
}

class _CardHolderFindingScreenState extends State<CardHolderFindingScreen> {
  late Stream<DocumentSnapshot> _orderStream;
int countdown = 3; // Countdown starting at 3 seconds
  late Timer _timer;


  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        _timer.cancel(); // Stop the timer when countdown reaches 0
        _navigateToWaitingScreen(); // Navigate to the next screen
      }
    });
  }

  void _navigateToWaitingScreen() {
    // Navigate to the WaitingScreen after the countdown is finished
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitingScreen(
          orderId: widget.orderId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi trên đơn hàng với ID cụ thể
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finding Card Holder"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            var orderData = snapshot.data!.data() as Map<String, dynamic>;

            String status = orderData['status'] ?? 'pending';
            String? cardHolderId = orderData['cardHolderId'];

            if (status == 'accepted' && cardHolderId != null) {
              if (countdown == 3){
                _startCountdown();
              }
              
              // Card holder đã chấp nhận thanh toán
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Payment Accepted!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Card Holder ID: $cardHolderId"),
                    // Countdown timer display
          Text("Redirecting in $countdown seconds..."),

                    ElevatedButton(
                      onPressed: () {
                        // Chuyển tới màn hình
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WaitingScreen(
                              orderId: widget.orderId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              );
            } else {
              // Đang chờ card holder chấp nhận
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Real time shopping',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Circle
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.1),
                                    Colors.purple.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            // Middle Circle
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.2),
                                    Colors.purple.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            // Inner Circle
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.purple.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            // Center Avatar
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150'), // Replace with actual URL
                            ),
                            // Floating Avatars
                            Positioned(
                              top: 40,
                              right: 10,
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/100'), // Replace with actual URL
                              ),
                            ),
                            Positioned(
                              top: 180,
                              left: 20,
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/100'), // Replace with actual URL
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              right: 50,
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/100'), // Replace with actual URL
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      'Finding the right card holder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait! This might take a few minutes.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: LinearProgressIndicator(
                        value: null, // Indeterminate progress bar
                        color: Colors.deepPurple,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
          }

          return const Center(child: Text("No data available."));
        },
      ),
    );
  }
}
