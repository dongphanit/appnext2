import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_tour_app/constant/app_colors.dart';
import 'dart:io';

import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/upload.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({Key? key}) : super(key: key);

  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String? deviceId;
  List<DocumentSnapshot> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getDeviceId();
    await loadPosts();
  }

  Future<void> _getDeviceId() async {
    if (kIsWeb) {
      // For web, we can use a placeholder or a unique identifier
      deviceId = 'web-device-id';
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    String id = "unknown";

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id ?? 'unknown';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor ?? 'unknown';
    }

    setState(() {
      deviceId = id;
    });
  }

  Future<void> loadPosts() async {
    // if (deviceId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('post')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    setState(() {
      posts = querySnapshot.docs;
      isLoading = false;
    });
  }

  Future<void> _updatePostStatus(String postId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(postId)
          .update({'status': newStatus});

      // Cập nhật lại danh sách sau khi đổi trạng thái
      await loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái thành "$newStatus"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || deviceId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài đã đăng'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: posts.isEmpty
          ? const Center(child: Text('Bạn chưa đăng bài nào.'))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final data = posts[index].data() as Map<String, dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: data['imageUrl'] != null
                        ? Image.network(
                            ServerAddress.serverAddress + data['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image),
                    title: Text(data['title'] ?? 'Không có tiêu đề'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        _updatePostStatus(posts[index].id, value);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'available', child: Text('Đang bán')),
                        const PopupMenuItem(
                            value: 'sold', child: Text('Đã bán')),
                        const PopupMenuItem(value: 'hidden', child: Text('Ẩn')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? ''),
                        Text(
                          data['price'] != null ? '${data['price']} đ' : '',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        Text(data['location'] ?? ''),
                        Text(data['status'] == 'available'
                            ? 'Đang bán'
                            : data['status'] == "sold"
                                ? 'Đã bán'
                                : "Ẩn")
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
