// 📁 lib/screens/reminder_intro_screen.dart

import 'package:flutter/material.dart';

class ReminderIntroScreen extends StatelessWidget {
  const ReminderIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'icon': Icons.calendar_month,
        'title': 'Nhập thời khoá biểu',
        'desc': 'Bạn hãy nhập lịch học theo các môn và tiết học trong tuần.'
      },
      {
        'icon': Icons.alarm,
        'title': 'Tự động nhắc nhở',
        'desc': 'Trước mỗi buổi học, hệ thống sẽ nhắc bạn chuẩn bị bài và làm bài tập.  Ví dụ 🛎️ "Hôm nay bạn cần làm các môn học là Toán, Lý, Hóa..."'
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Đánh dấu đã hoàn thành',
        'desc': 'Bạn có thể đánh dấu những bài đã hoàn thành để dễ theo dõi tiến độ.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu tính năng nhắc nhở'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(step['icon'] as IconData, size: 32, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step['title'] as String,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(step['desc'] as String,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: chuyển đến màn hình lịch học chính
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Bắt đầu sử dụng'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
