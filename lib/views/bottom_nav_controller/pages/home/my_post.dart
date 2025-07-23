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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: data['imageUrl'] != null
                          ? Image.network(
                              ServerAddress.serverAddress + data['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image,
                                  size: 32, color: Colors.grey),
                            ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Không có tiêu đề',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            _updatePostStatus(posts[index].id, value);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'available', child: Text('Đang bán')),
                            PopupMenuItem(value: 'sold', child: Text('Đã bán')),
                            PopupMenuItem(value: 'hidden', child: Text('Ẩn')),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        if ((data['description'] ?? '').toString().isNotEmpty)
                          Text(
                            data['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        const SizedBox(height: 4),
                        if (data['price'] != null &&
                            data['price'].toString().isNotEmpty)
                          Text(
                            '${data['price']} đ',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (data['location'] != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['location'],
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              data['status'] == 'available'
                                  ? 'Đang bán'
                                  : data['status'] == 'sold'
                                      ? 'Đã bán'
                                      : 'Ẩn',
                              style: TextStyle(
                                color: data['status'] == 'available'
                                    ? Colors.green
                                    : data['status'] == 'sold'
                                        ? Colors.red
                                        : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
