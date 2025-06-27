// 📁 lib/models/study_schedule.dart

// 📁 lib/services/reminder_service.dart


// 📁 lib/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// 📁 lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseService {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'schedule.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dayOfWeek TEXT,
            period INTEGER,
            subject TEXT
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  static Future<void> insertSchedule(StudySchedule item) async {
    final db = await getDatabase();
    await db.insert('schedule', {
      'dayOfWeek': item.dayOfWeek,
      'period': item.period,
      'subject': item.subject,
    });
  }

  static Future<List<StudySchedule>> getAllSchedules() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('schedule');

    return maps.map((map) => StudySchedule(
      dayOfWeek: map['dayOfWeek'],
      period: map['period'],
      subject: map['subject'],
    )).toList();
  }

  static Future<void> clearSchedule() async {
    final db = await getDatabase();
    await db.delete('schedule');
  }
}

class StudySchedule {
  final String dayOfWeek; // e.g., "Monday"
  final int period; // 1, 2, 3...
  final String subject;

  StudySchedule({
    required this.dayOfWeek,
    required this.period,
    required this.subject,
  });
}

// 📁 lib/models/homework_reminder.dart
class HomeworkReminder {
  final DateTime dateTime;
  final String subject;
  bool isCompleted;

  HomeworkReminder({
    required this.dateTime,
    required this.subject,
    this.isCompleted = false,
  });
}


class ReminderService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  static Future<void> scheduleReminder(String subject, DateTime dateTime) async {
    final id = dateTime.millisecondsSinceEpoch.remainder(100000);
    await _notifications.zonedSchedule(
      id,
      'Nhắc nhở làm bài tập',
      'Đừng quên làm bài tập môn $subject nhé!',
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'homework_channel',
          'Nhắc bài tập',
          importance: Importance.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> subjects = [
    'Toán', 'Ngữ văn', 'Tiếng Anh', 'Vật lý', 'Hóa học', 'Sinh học',
    'Lịch sử', 'Địa lý', 'Giáo dục công dân', 'Tin học', 'Công nghệ',
    'Thể dục', 'Âm nhạc', 'Mỹ thuật', 'Tiếng Pháp', 'Tiếng Trung',
    'Tiếng Nhật', 'Quốc phòng - An ninh', 'Hoạt động trải nghiệm', 'Nghề nghiệp - Hướng nghiệp'
  ];

  final List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'];
  final Map<String, List<String?>> schedule = {};

  @override
  void initState() {
    super.initState();
    for (var day in days) {
      schedule[day] = List.filled(5, null); // 5 tiết mỗi ngày
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch học tuần')),
      body: ListView(
        children: days.map((day) {
          return FutureBuilder<List<StudySchedule>>(
        future: DatabaseService.getAllSchedules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final daySchedules = snapshot.data!
              .where((item) => item.dayOfWeek == day)
              .toList()
            ..sort((a, b) => a.period.compareTo(b.period));

          return ListView.builder(
            itemCount: daySchedules.length,
            itemBuilder: (context, index) {
              final item = daySchedules[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${item.period}')),
                title: Text(item.subject),
              );
            },
          );
        },
      );
          // return Card(
          //   margin: EdgeInsets.all(8),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          //       ),
          //       GridView.builder(
          //         shrinkWrap: true,
          //         physics: NeverScrollableScrollPhysics(),
          //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //           crossAxisCount: 5,
          //           childAspectRatio: 2,
          //           crossAxisSpacing: 4,
          //           mainAxisSpacing: 4,
          //         ),
          //         itemCount: 5,
          //         itemBuilder: (context, period) {
          //           final selected = schedule[day]![period];
          //           return ElevatedButton(
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: selected == null ? Colors.grey[300] : Colors.blueAccent,
          //             ),
          //             onPressed: () => _showSubjectPicker(context, day, period),
          //             child: Text(selected ?? 'Tiết ${period + 1}', textAlign: TextAlign.center),
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // );
        }).toList(),
      ),
    );
  }

  void _showSubjectPicker(BuildContext context, String day, int period) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: subjects.map((subject) => ListTile(
          title: Text(subject),
          onTap: () {
            DatabaseService.insertSchedule(
  StudySchedule(dayOfWeek: day, period: period + 1, subject: subject),
);

            setState(() {
              schedule[day]![period] = subject;
              final now = DateTime.now();
              final reminderTime = DateTime(now.year, now.month, now.day, 18, 0);
              ReminderService.scheduleReminder(subject, reminderTime);
            });
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }
}

class DailyScheduleScreen extends StatelessWidget {
  final String selectedDay;

  DailyScheduleScreen({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thời khoá biểu $selectedDay')),
      body: FutureBuilder<List<StudySchedule>>(
        future: DatabaseService.getAllSchedules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final daySchedules = snapshot.data!
              .where((item) => item.dayOfWeek == selectedDay)
              .toList()
            ..sort((a, b) => a.period.compareTo(b.period));

          return ListView.builder(
            itemCount: daySchedules.length,
            itemBuilder: (context, index) {
              final item = daySchedules[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${item.period}')),
                title: Text(item.subject),
              );
            },
          );
        },
      ),
    );
  }
}
