import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dữ liệu tạm thời
    final totalHabits = 5;
    final longestStreak = 7;

    return Scaffold(
      appBar: AppBar(title: Text('📊 Thống kê')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Tổng số thói quen: $totalHabits'),
            Text('Chuỗi ngày liên tục dài nhất: $longestStreak ngày'),
            SizedBox(height: 24),
            Text('Biểu đồ hiệu suất (demo)'),
            SizedBox(height: 100, child: Placeholder()), // Dùng chart sau
          ],
        ),
      ),
    );
  }
}
