import 'package:flutter/material.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/my_post.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/avatar.png')),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text("Bài đăng của tôi"),
              onTap: () {
                // Navigate to user's posts
                Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPostsScreen(),
                      ),
                );

              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.favorite),
            //   title: const Text("Đã yêu thích"),
            //   onTap: () {
            //     // Navigate to user's favorite posts
            //     Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => MyPostsScreen(), // Replace with actual favorite posts screen
            //           ),
            //     );
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text("Cài đặt"),
            //   onTap: () {},
            // ),
            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text("Đăng xuất"),
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }
}
