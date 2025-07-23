import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/my_post.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  initState() {
    super.initState();
    _loadImageUrl();
  }
  Future<void> _loadImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('avatar');
    if (url != null) {
      setState(() {
        imageUrl = url;
      });
    }
  }
  String? imageUrl; // Dùng nullable để kiểm tra nếu chưa có ảnh

  Future<void> _pickImageWebCompatible() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      Uint8List? bytes = file.bytes;

      if (bytes != null) {
        String base64Image = base64Encode(bytes);
        final uploader = ImageUploader();

        List<String> urls = await uploader.uploadImage(
          base64Image: base64Image,
          filename: file.name,
        );

        if (urls.isNotEmpty) {
          setState(() {
            imageUrl = urls.first;
          });
          // In ra URL của ảnh đã upload
          print("✅ Image uploaded successfully");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar', imageUrl!);

          print("📤 Uploaded image URL: $imageUrl");
        }
      }
    } else {
      print("❌ No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImageWebCompatible,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null
                    ? NetworkImage(ServerAddress.serverAddress + imageUrl!)
                    : const AssetImage('assets/icons/add_user.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text("Bài đăng của tôi"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPostsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
