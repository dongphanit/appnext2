import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/card_holder_findding.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> orders = []; // Replace with your Order model

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    // Fetch orders from Firestore
    // You might need to adjust the logic based on your data structure
    var querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('available', isEqualTo: true) // Example of available orders
        .get();
    setState(() {
      orders = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void selectOrderAndProceed(Map<String, dynamic> order) {
    String orderId = order['orderId']; // Get the orderId from the order data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardHolderFindingScreen(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order['productName']),
                  subtitle: Text('Price: \$${order['productPrice']}'),
                  onTap: () => selectOrderAndProceed(order),
                );
              },
            ),
    );
  }
}