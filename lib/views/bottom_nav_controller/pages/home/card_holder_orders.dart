import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bbbb/views/bottom_nav_controller/pages/home/verification_order.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  final Stream<QuerySnapshot> _orderStream = FirebaseFirestore.instance
      .collection('orders')
      .where('available', isEqualTo: true)
      .snapshots();

  void selectOrderAndProceed(Map<String, dynamic> order) {
    String orderId = order['id']; // Get the orderId from the order data
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationOrderScreen(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
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
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Text(
                                'Product Name: ${order['product_name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  Text('Product ID: ${order['product_id']}'),
                                  Text('Price: \$${order['product_price']}'),
                                  Text('Buyer Address: ${order['buyer_address']}'),
                                  Text('Buyer Phone: ${order['buyer_phone']}'),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () => selectOrderAndProceed(order),
                            ),
                          );
                           
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
