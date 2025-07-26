// firestore_services.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Function to create a new order in Firestore
  Future<String> createOrder({
    required String buyerId,
    required String productLink,
    required String shippingAddress,
    required double amount,
  }) async {
    try {
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'buyerId': buyerId,
        'productLink': productLink,
        'shippingAddress': shippingAddress,
        'amount': amount,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Create post
  Future<String> createPost({
    required String deviceId,
    required String userInfo,
    required String category,
    required String title,
    required String phone,
    required String description,
    required String imageUrl,
    required String location,
    required String gpsLat,
    required String price,
    required bool isFree,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String avatar = prefs.getString('avatar') ?? '';
      DocumentReference postRef = await _firestore.collection('post').add({
        'deviceId': deviceId,
        'userInfo': userInfo,
        'category': category,
        'title': title,
        'phone': phone,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
        'price': price,
        'isFree': isFree,
        'gpsLat': gpsLat,
        'avatar': avatar,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return postRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Function to fetch order details
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      DocumentSnapshot orderSnapshot =
          await _firestore.collection('orders').doc(orderId).get();
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
      return _firestore
          .collection('orders')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  })
              .toList());
    } catch (e) {
      throw Exception('Failed to listen to orders: $e');
    }
  }

Future<void> deleteAllPosts() async {
  try {
    // Lấy tất cả document trong collection 'post'
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('post').get();

    // Duyệt qua từng document và xoá
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print('Đã xoá tất cả các bài post.');
  } catch (e) {
    print('Lỗi khi xoá bài post: $e');
    throw Exception('Failed to delete all posts: $e');
  }
}
Future<void> deleteAllPostsBatch() async {
  final firestore = FirebaseFirestore.instance;
  const batchSize = 100;

  try {
    while (true) {
      QuerySnapshot snapshot = await firestore
          .collection('post')
          .limit(batchSize)
          .get();

      if (snapshot.docs.isEmpty) break;

      WriteBatch batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    print('Đã xoá toàn bộ post theo batch.');
  } catch (e) {
    print('Lỗi xoá batch: $e');
    throw Exception('Failed to delete posts in batch: $e');
  }
}

  // list of all posts
  Future<List<Map<String, dynamic>>> getAllPosts(int category) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('post')
          .where('category', isEqualTo: ['Đồ ăn', 'Quần áo', 'Điện tử', 'Sách', 'Đồ chơi'][category])
          .limit(20)
      .get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchPosts(String keyword, int category) async {
  try {
    
    QuerySnapshot snapshot = await _firestore.collection('post') .where('category', isEqualTo: ['Đồ ăn', 'Quần áo', 'Điện tử', 'Sách', 'Đồ chơi'][category]).get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          return title.contains(keyword.toLowerCase());
        })
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  } catch (e) {
    throw Exception('Failed to search posts: $e');
  }
}


}
