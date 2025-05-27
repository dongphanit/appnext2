// firestore_services.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String allOrders = 'orders';
Future<QuerySnapshot> getOrders({bool available = true}) async {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('availability', isEqualTo: available)
      .get();
}
Future<Map<String, dynamic>?> getSettings() async {
  try {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance.collection('settings').doc("discount").get();
    
    return orderSnapshot.data() as Map<String, dynamic>?;
   
  } catch (e) {
    print("Error fetching orders: $e");
  }
  return null;
  
}
// Function to create a new order in Firestore
Future<String> createOrder({
  required String buyerAddress,
  required String buyerPhone,
  required String cardHolderId,
  required String productId,
  required String productName,
  required double productPrice,
  required String productUrl,
  required String userId,
}) async {
  try {
    DocumentReference orderRef = await _firestore.collection('orders').add({
      'buyer_address': buyerAddress,
      'buyer_phone': buyerPhone,
      'cardHolderId': cardHolderId,
      'createdAt': FieldValue.serverTimestamp(),
      'productId': productId,
      'product_name': productName,
      'product_price': productPrice,
      'product_url': productUrl,
      'status': 'pending',
      'userId': userId,
      'imageUrl': []
    });
    return orderRef.id;
  } catch (e) {
    throw Exception('Failed to create order: $e');
  }
}
  // Function to fetch order details
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      DocumentSnapshot orderSnapshot = await _firestore.collection('orders').doc(orderId).get();
      return orderSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Function to update order status (e.g., after payment by Card Holder)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Function to upload invoice to Firebase Storage
  Future<String> uploadInvoice(String orderId, String filePath) async {
    try {
      final storageRef = _storage.ref().child('invoices/$orderId');
      final uploadTask = await storageRef.putFile(File(filePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload invoice: $e');
    }
  }

  // Function for Card Holder to update invoice link in Firestore
  Future<void> addInvoiceToOrder(String orderId, String invoiceUrl) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'invoiceUrl': invoiceUrl,
      });
    } catch (e) {
      throw Exception('Failed to update order with invoice: $e');
    }
  }

  // Function to listen for new orders (for Card Holder)
  Stream<List<Map<String, dynamic>>> listenToOrders() {
    try {
      return _firestore.collection('orders').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toList());
    } catch (e) {
      throw Exception('Failed to listen to orders: $e');
    }
  }
}
