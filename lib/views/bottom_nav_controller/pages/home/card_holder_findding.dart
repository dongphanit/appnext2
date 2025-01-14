import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardHolderFindingScreen extends StatefulWidget {
  final String orderId;

  const CardHolderFindingScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  _CardHolderFindingScreenState createState() =>
      _CardHolderFindingScreenState();
}

class _CardHolderFindingScreenState extends State<CardHolderFindingScreen> {
  late Stream<DocumentSnapshot> _orderStream;

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
        title: Text("Finding Card Holder"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            var orderData = snapshot.data!.data() as Map<String, dynamic>;

            String status = orderData['status'] ?? 'pending';
            String? cardHolderId = orderData['cardHolderId'];

            if (status == 'accepted' && cardHolderId != null) {
              // Card holder đã chấp nhận thanh toán
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Payment Accepted!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Card Holder ID: $cardHolderId"),
                    ElevatedButton(
                      onPressed: () {
                        // Chuyển tới màn hình tiếp theo
                        Navigator.pop(context);
                      },
                      child: Text("Continue"),
                    ),
                  ],
                ),
              );
            } else {
              // Đang chờ card holder chấp nhận
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Finding the right card holder...",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }
          }

          return Center(child: Text("No data available."));
        },
      ),
    );
  }
}
