

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class Habit {
  final int? id;
  final String title;
  final String time;
  final bool isDone;

  Habit({this.id, required this.title, required this.time, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'isDone': isDone ? 1 : 0,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      isDone: map['isDone'] == 1,
    );
  }
}

class HabitDatabase {
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE habits(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      time TEXT,
      isDone INTEGER
    )
    ''');
  }

  Future<List<Habit>> getHabits() async {
    final db = await instance.database;
    final result = await db.query('habits');
    return result.map((e) => Habit.fromMap(e)).toList();
  }

  Future<void> insertHabit(Habit habit) async {
    final db = await instance.database;
    await db.insert('habits', habit.toMap());
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await instance.database;
    await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> deleteHabit(int id) async {
    final db = await instance.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  
  }
  Future<void> scheduleNotification(String title, TimeOfDay time, int id) async {
  final androidDetails = AndroidNotificationDetails(
    'habit_channel',
    'Habit Reminders',
    channelDescription: 'Reminders to complete your habits',
    importance: Importance.max,
    priority: Priority.high,
  );
  final notificationDetails = NotificationDetails(android: androidDetails);

  final now = DateTime.now();
  final hour = time.hour;
  final minute = time.minute;
  final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
  final adjustedTime = scheduledTime.isBefore(now) ? scheduledTime.add(const Duration(days: 1)) : scheduledTime;

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Nhắc nhở Nhắc nhở',
    title,
    adjustedTime.toLocal().timeZoneOffset as TZDateTime,
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
}

