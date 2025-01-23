import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/verification_order.dart';

class BuyerOrderListScreen extends StatefulWidget {
  const BuyerOrderListScreen({Key? key}) : super(key: key);

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<BuyerOrderListScreen> {
  final Stream<QuerySnapshot> _orderStream = FirebaseFirestore.instance
      .collection('orders')
      .where('userId',isEqualTo: firebaseAuth.currentUser?.uid ?? "")
      .snapshots();

  void selectOrderAndProceed(Map<String, dynamic> order) async {
    String orderId = order['id']; // Get the orderId from the order data
     await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                      'status': "Order Received",
                    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders available'));
          }

          var orders = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID to data
            return data;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Dashboard Header
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome to the Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Icon(Icons.dashboard, color: Colors.white),
                    ],
                  ),
                ),
                // Orders Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                            return ListTile(
                            title: Text(order['product_name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text('Price: \$${order['product_price']}'),
                              Text('Status: ${order['status']}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                               backgroundColor: order['status'] == 'Order Received' ? Colors.grey : Colors.blue,
                              ),
                              onPressed:order['status'] == 'Order Received' ? null : () {
                            selectOrderAndProceed(order);
                            },
                              child: Text('Order received'),
                            ));
                        },
                      ),
                    ],
                  ),
                ),
                // Add more sections as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
