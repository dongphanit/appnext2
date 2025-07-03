import 'package:flutter/services.dart';

class NotificationHelper {
  static const platform = MethodChannel('com.example.local_notifications');

  // Gửi notification mỗi ngày
  static Future<void> scheduleDailyNotification(String content, int hour, int minute) async {
    try {
      final result = await platform.invokeMethod('scheduleDailyNotification', {
        'content': content,
        'hour': hour,
        'minute': minute,
      });
      print(result);
    } on PlatformException catch (e) {
      print("❌ Daily Failed: ${e.message}");
    }
  }

  // Gửi notification hàng tuần (theo thứ)
  static Future<void> scheduleWeeklyNotification( String content,int weekday, int hour, int minute) async {
    try {
      final result = await platform.invokeMethod('scheduleWeeklyNotification', {
        'content': content,
        'weekday': weekday, // Từ 1 (Chủ nhật) đến 7 (Thứ 7)
        'hour': hour,
        'minute': minute,
      });
      print(result);
    } on PlatformException catch (e) {
      print("❌ Weekly Failed: ${e.message}");
    }
  }
}
