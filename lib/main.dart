import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habits/habit.dart';
import 'package:habits/home_page.dart';
import 'package:habits/setting_schedule_screen.dart';

import 'package:timezone/timezone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // cách test
  Future.delayed( const Duration(seconds: 1), () async {
   flutterLocalNotificationsPlugin
      .show(0, 'Test Notification', 'This is a test notification', const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(),
      ));
  final now = DateTime.now();
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Nhắc nhở Nhắc nhở',
    'Đây là một thông báo nhắc nhở',
    TZDateTime.from(now, local).add(const Duration(seconds: 5)), // Thời gian nhắc nhở
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_channel',
        'Habit Reminders',
        channelDescription: 'Reminders to complete your habits',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
  });
  runApp(HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HabitApp();
  }
}
