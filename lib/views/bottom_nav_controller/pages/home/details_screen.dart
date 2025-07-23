import 'package:flutter/material.dart';
import 'package:flutter_tour_app/constant/app_colors.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/upload.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final String title;
   final String userInfo;
  final String phone;
  final String image;
  final String location;
  final String? gpsLat;
  final String? price;
  final bool isFree;

  const DetailPage({
    super.key,
    required this.title,
    required this.image,
     required this.userInfo,
    this.gpsLat,
    required this.phone,
    required this.location,

    this.price,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: const Text("Chi tiết món đồ"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Image.network(ServerAddress.serverAddress + image, height: 200, width: double.infinity, fit: BoxFit.cover),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(location, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(
                  isFree ? '🎁 Miễn phí' : '💰 $price',
                  style: TextStyle(
                    color: isFree ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/icons/users.png')),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       Text(userInfo, style: TextStyle(fontWeight: FontWeight.bold)),
                       Text(location, style: const TextStyle(color: Colors.grey)),
                    ])
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          // Logic to call the user phone
                          print("Calling user...");
                          var phoneNumber = phone; // Số điện thoại cần gọi
                            final Uri url = Uri(scheme: 'tel', path: phoneNumber);

                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              print('Không thể gọi điện đến số này.');
                            }

                           
                        },
                        child: const Text("Gọi Điện"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          // Logic to view location on map
                          print("Viewing location on map...");
                          final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$gpsLat');

                          if (await canLaunchUrl(url)) {
                            launchUrl(url);
                          } else {
                            print('Không thể mở bản đồ với vị trí này.');
                          }
                        },
                        child: Text( "Xem vị trí" ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
