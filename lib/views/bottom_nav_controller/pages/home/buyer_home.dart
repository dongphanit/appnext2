import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tour_app/constant/app_colors.dart';
import 'package:flutter_tour_app/services/firestore_services.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/details_screen.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/upload.dart';
import 'package:geolocator/geolocator.dart'; // Firestore package

import 'package:geolocator/geolocator.dart';

class ChoLangHomePage extends StatefulWidget {
  const ChoLangHomePage({super.key});

  @override
  State<ChoLangHomePage> createState() => _ChoLangHomePageState();
}

class _ChoLangHomePageState extends State<ChoLangHomePage> {
  int categoryIndex = 0; // Index to track selected category
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts(); // Gọi hàm bất đồng bộ
  }

  void loadPosts() async {
    final fetchedPosts = await FirestoreServices().getAllPosts(categoryIndex);
    setState(() {
      posts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món bạn cần...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) async {
                final fetchedPosts =
                    await FirestoreServices().searchPosts(value, categoryIndex);
                setState(() {
                  posts = fetchedPosts;
                });
                // Logic to filter items based on search input
                // For now, we just print the value to the console.
                print('Searching for: $value');
              },
            ),
            const SizedBox(height: 16),

            // Danh mục
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryItem('🍎 Đồ ăn', 0),
                  _buildCategoryItem('👕 Quần áo', 1),
                  _buildCategoryItem('📱 Điện tử', 2),
                  _buildCategoryItem('📚 Sách', 3),
                  _buildCategoryItem('🧸 Đồ chơi', 4),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề mục
            const Text(
              "Gần bạn",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Fetch and display items from Firestore
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          phone: post['phone'] ?? '',
                          title: post['title'] ?? 'Không có tiêu đề',
                          location: post['location'] ?? 'Không rõ địa điểm',
                          gpsLat: post['gpsLat'] ?? '',
                          isFree: post['isFree'] ?? false,
                          price: post['price'].toString() ?? '0',
                          image: post['imageUrl'] ?? '',
                          userInfo: post["userInfo"], // Placeholder image
                        ),
                      ),
                    );
                  },
                  child: _buildItemCard(
                    image: post['imageUrl'] ?? '', // Placeholder image
                    title: post['title'] ?? 'Không có tiêu đề',
                    location: post['location'] ?? 'Không rõ địa điểm',
                    isFree: post['isFree'] ?? false,
                    price: post['price'].toString() ?? '0',
                    gpsLat: '${post['gpsLat'] ?? ''}',
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, int index) {
    // This widget builds a category item with a button
    // that filters items based on the selected category.

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            index == categoryIndex ? Colors.grey.shade100 : Colors.transparent,
        border: Border.all(
          color: index == categoryIndex
              ? AppColors.secondaryColor
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildFilterButton(
        label,
        () => _filterCategory(label, index),
      ),
    );
  }

  void _filterCategory(String category, int index) {
    // Logic to filter items based on the selected category
    // For now, we just print the category to the console.
    setState(() {
      categoryIndex = index; // Update the selected category index
      // Update the state to reflect the selected category
      // This could be used to filter the displayed items
    });
    loadPosts(); // Reload posts based on the selected category
    print('Selected category: $category');
  }

  Widget _buildFilterButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Future<double?> calculateDistanceFromUser(String gpsLat) async {
    try {
      // Lấy vị trí hiện tại
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Tách tọa độ bài đăng
      List<String> parts = gpsLat.split(',');
      double lat = double.parse(parts[0].trim());
      double lng = double.parse(parts[1].trim());

      // Tính khoảng cách
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      return distanceInMeters / 1000; // đổi sang km
    } catch (e) {
      print('Lỗi khi tính khoảng cách: $e');
      return null;
    }
  }

  Widget _buildItemCard({
  required String image,
  required String title,
  required String location,
  required String gpsLat,
  required bool isFree,
  String? price,
}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ServerAddress.serverAddress + image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FutureBuilder<double?>(
                  future: calculateDistanceFromUser(gpsLat),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 16);
                    }
                    if (snapshot.hasData) {
                      return Text(
                        '📍 ${snapshot.data!.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const Text(
                      'Khoảng cách không rõ',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  isFree ? '🎁 Miễn phí' : '💰 ${price ?? 'Đang cập nhật'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isFree ? Colors.green : Colors.orange[800],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
