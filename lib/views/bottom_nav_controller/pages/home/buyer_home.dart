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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.network(ServerAddress.serverAddress + image,
                width: 80, height: 80, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(location, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  // Tính khoảng cách từ vị trí hiện tại
                  // Giả sử gpsLat là vĩ độ, bạn có thể thêm logic để tính khoảng cách nếu cần
                 FutureBuilder<double?>(
  future: calculateDistanceFromUser(gpsLat),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(); // hoặc CircularProgressIndicator nhỏ
    }

    if (snapshot.hasData) {
      return Text(
        'Khoảng cách: ${snapshot.data!.toStringAsFixed(2)} km',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    return const Text(
      'Không rõ khoảng cách',
      style: TextStyle(color: Colors.grey),
    );
  },
),
                  const SizedBox(height: 6),
                  Text(
                    isFree ? '🎁 Miễn phí' : '💰 $price',
                    style: TextStyle(
                      color: isFree ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
