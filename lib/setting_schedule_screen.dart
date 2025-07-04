// 📁 lib/models/study_schedule.dart

// 📁 lib/services/reminder_service.dart

// 📁 lib/screens/schedule_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habits/home_page.dart';
import 'package:habits/notifi_helper.dart';
import 'package:habits/setting_schedule_intro_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
// 📁 lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum StudySession { none, morning, afternoon }

class DatabaseService {
  static const String key = 'study_schedule_list';

  // Thêm lịch học
  static Future<void> insertSchedule(StudySchedule item) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getAllSchedules();

    // Check if the schedule already exists
    final existingIndex = currentList.indexWhere(
      (schedule) => schedule.dayOfWeek == item.dayOfWeek && schedule.period == item.period,
    );

    if (existingIndex != -1) {
      // Update the existing schedule
      currentList[existingIndex] = item;
    } else {
      // Add the new schedule
      currentList.add(item);
    }

    final encodedList = currentList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, encodedList);
  }

  // Lấy toàn bộ lịch học
  static Future<List<StudySchedule>> getAllSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getStringList(key);

    if (encodedList == null) return [];

    return encodedList
        .map((e) => StudySchedule.fromJson(jsonDecode(e)))
        .toList();
  }

  // Xoá toàn bộ lịch học
  static Future<void> clearSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
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

  // Dùng để convert thành JSON
  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'period': period,
        'subject': subject,
      };

  // Dùng để convert từ JSON
  factory StudySchedule.fromJson(Map<String, dynamic> json) {
    return StudySchedule(
      dayOfWeek: json['dayOfWeek'],
      period: json['period'],
      subject: json['subject'],
    );
  }
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
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  static Future<void> scheduleReminder(
      String subject, TimeOfDay time) async {
     // NotificationHelper.scheduleWeeklyNotification is not defined, so this line is commented out.
    // Uncomment and implement NotificationHelper if needed.
    final now = DateTime.now();
    NotificationHelper.scheduleDailyNotification('Đừng quên làm bài tập cho thứ ' + (now.weekday +1).toString(),  time.hour, time.minute);
    // await _notifications.zonedSchedule(
    //   id,
    //   'Nhắc nhở làm bài tập',
    //   'Đừng quên làm bài tập môn $subject nhé!',
    //   tz.TZDateTime.from(dateTime, tz.local),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'homework_channel',
    //       'Nhắc bài tập',
    //       channelDescription:
    //           'Nhắc bạn làm bài vào các ngày cố định trong tuần',
    //       importance: Importance.high,
    //     ),
    //   ),
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,

    //   /// 🔁 Lặp lại hàng tuần vào đúng thứ và giờ
    //   matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    // );
  }
}

class SettingScheduleScreen extends StatefulWidget {
  @override
  _SettingScheduleScreenState createState() => _SettingScheduleScreenState();
}

class _SettingScheduleScreenState extends State<SettingScheduleScreen> {
 
Map<String, IconData> subjectIcons = {
  'Toán': Icons.calculate,
  'Ngữ văn': Icons.book,
  'Tiếng Anh': Icons.language,
  'Vật lý': Icons.space_dashboard,
  'Hóa học': Icons.science,
  'Sinh học': Icons.eco,
  'Lịch sử': Icons.history_edu,
  'Địa lý': Icons.public,
  'Giáo dục công dân': Icons.people,
  'Tin học': Icons.computer,
  'Công nghệ': Icons.build,
  'Thể dục': Icons.sports,
  'Âm nhạc': Icons.music_note,
  'Mỹ thuật': Icons.brush,
  'Tiếng Pháp': Icons.translate,
  'Tiếng Trung': Icons.translate,
  'Tiếng Nhật': Icons.translate,
  'Quốc phòng - An ninh': Icons.security,
  'Hoạt động trải nghiệm': Icons.explore,
  'Nghề nghiệp - Hướng nghiệp': Icons.work,
};

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  final Map<String, int> dayToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
  };

  final Map<String, List<String?>> schedule = {};
  StudySession selectedSession = StudySession.morning;
  @override
  void initState() {
    super.initState();
    // notifi với selectedSession
       for (var day in days) {
      schedule[day] = List.filled(5, null); // 5 tiết mỗi ngày
    }
    _saveReminder();
  }

  Future<void> checkAndShowIntro(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('seen_intro') ?? false;

    if (!seenIntro) {
      showReminderIntro(context);
      await prefs.setBool('seen_intro', true);
    }
  }

  void showReminderIntro(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 500,
          child: SettingIntroScreen(),
        ),
      ),
    );
  }

  // Mặc định giờ nhắc
  TimeOfDay afternoonTime = TimeOfDay(hour: 13, minute: 0);
  TimeOfDay eveningTime = TimeOfDay(hour: 19, minute: 0);
  TimeOfDay nextMorningTime = TimeOfDay(hour: 7, minute: 0);
  String reminderMsg = '';

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime,
      void Function(TimeOfDay) onConfirm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) onConfirm(picked);
  }

  void _saveReminder() {
   if (selectedSession == StudySession.morning) {
    
      ReminderService.scheduleReminder("", afternoonTime);
      
      ReminderService.scheduleReminder("", eveningTime);
    } else if (selectedSession == StudySession.afternoon) {
        ReminderService.scheduleReminder("", eveningTime);
      ReminderService.scheduleReminder("", nextMorningTime);
    }
    // Notifi lịch nhắc với các môn học đã chọn
    // Bạn có thể sử dụng Flutter Local Notifications để hiển thị thông báo
    // Ví dụ thông báo
    // Bạn có thể sử dụng ScaffoldMessenger để hiển thị thông báo tạm thời
    // Hoặc sử dụng một package khác để hiển thị thông báo

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message)),
    // );

    // TODO: Đặt lịch nhắc nhở bằng flutter_local_notifications
  }

  @override
  Widget build(BuildContext context) {
    checkAndShowIntro(context);
    return Scaffold(
        appBar: AppBar(title: Text('Lịch học tuần')),
        body: SingleChildScrollView(
            // scrollDirection: Axis.horizontal,
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bạn học buổi nào?',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<StudySession>(
                          title: Text('Sáng', style: TextStyle(fontSize: 12)),
                          value: StudySession.morning,
                          groupValue: selectedSession,
                          onChanged: (value) =>
                              setState(() => selectedSession = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<StudySession>(
                          title: Text('Chiều', style: TextStyle(fontSize: 12)),
                          value: StudySession.afternoon,
                          groupValue: selectedSession,
                          onChanged: (value) =>
                              setState(() => selectedSession = value!),
                        ),
                      ),
                    ],
                  ),
                  if (selectedSession != StudySession.none)
                    Text("Tôi sẽ nhắc bạn lúc:",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  if (selectedSession == StudySession.morning) ...[
                  ListTile(
  title: Text("Chiều: ${formatTime(afternoonTime)}", style: TextStyle(fontSize: 12)),
  trailing: Icon(Icons.access_time, size: 16),
  onTap: () => _pickTime(
    context,
    afternoonTime,
    (val) {
      // Huỷ notification cũ
      NotificationHelper.cancelDailyNotification(
         afternoonTime.hour,
         afternoonTime.minute,
      );
      // Cập nhật thời gian mới
      setState(() => afternoonTime = val);
    },
  ),
),
ListTile(
  title: Text("Tối: ${formatTime(eveningTime)}", style: TextStyle(fontSize: 12)),
  trailing: Icon(Icons.access_time, size: 16),
  onTap: () => _pickTime(
    context,
    eveningTime,
    (val) {
      // Huỷ notification cũ
      NotificationHelper.cancelDailyNotification(
         eveningTime.hour,
         eveningTime.minute,
      );
      // Cập nhật thời gian mới
      setState(() => eveningTime = val);
    },
  ),
),

                  ],
                  if (selectedSession == StudySession.afternoon) ...[
                    ListTile(
                      title: Text("Tối: ${formatTime(eveningTime)}",
                          style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.access_time, size: 16),
                      onTap: () => _pickTime(context, eveningTime,
                          (val) => setState(() => eveningTime = val)),
                    ),
                    ListTile(
                      title: Text("Sáng: ${formatTime(nextMorningTime)}",
                          style: TextStyle(fontSize: 12)),
                      trailing: Icon(Icons.access_time, size: 16),
                      onTap: () => _pickTime(context, nextMorningTime,
                          (val) => setState(() => nextMorningTime = val)),
                    ),
                  ],
                ],
              ),
            ),
            // add nút thiết lập lịch để sổ giao diện, thêm bút checkbox
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Chọn lịch học của bạn',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            // add các môn học đã làm bài, khi làm bài xong sẽ tick vào môn đó để hoàn thành


            // if checkbox is true, will show settingSchedule
            // else will show empty container
            // CheckboxListTile(
            //   title: Text('Thiết lập lịch học'),
            //   value: _isSettingSchedule,
            //   onChanged: (value) {
            //     setState(() {
            //       _isSettingSchedule = value!;
            //     });
            //   },
            // ),
        settingSchedule(),

            SizedBox(height: 20),
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: _saveReminder,
            //     icon: Icon(Icons.save, size: 16),
            //     label: Text("Lưu",
            //         style:
            //             TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            //     style: ElevatedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       backgroundColor: Colors.blue,
            //     ),
            //   ),
            // ),
            SizedBox(height: 20),
          ],
        )));
  }

  DateTime getWeekdayOfCurrentWeek(int weekday) {
    final now = DateTime.now();

    /// Lấy ngày đầu tuần (Thứ 2)
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - DateTime.monday));

    /// Cộng thêm để đến thứ mong muốn
    final day = startOfWeek.add(Duration(days: weekday - DateTime.monday));

    return DateTime(day.year, day.month, day.day); // reset giờ
  }

  Widget settingSchedule() {
    return FutureBuilder<List<StudySchedule>>(
      future: DatabaseService.getAllSchedules(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final allSchedules = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: IntrinsicWidth(
                      child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const {
                          0: FixedColumnWidth(60),
                        },
                        defaultColumnWidth: FlexColumnWidth(),
                        children: [
                          // Tiêu đề
                          TableRow(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.blue[50],
                                child: Text('Tiết',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              ...days.map((day) => Container(
                                    padding: EdgeInsets.all(8),
                                    color: Colors.blue[50],
                                    child: Text(day,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ],
                          ),

                          // Hàng dữ liệu
                          for (int period = 1; period <= 5; period++)
                            TableRow(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.blue[50],
                                  child: Text('Tiết $period',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                ...days.map((day) {
                                  final item = allSchedules.firstWhere(
                                    (s) =>
                                        s.dayOfWeek == day &&
                                        s.period == period,
                                    orElse: () => StudySchedule(
                                        dayOfWeek: day,
                                        period: period,
                                        subject: ''),
                                  );

                                  final isEmpty = item.subject.isEmpty;

                                  return InkWell(
                                    onTap: () => _showSubjectPickerWithIcons(
                                        context, day, period - 1, subjectIcons.keys.toList()),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      height: 60,
                                      color: isEmpty
                                          ? Colors.grey[100]
                                          : AppColors.secondary
                                              .withOpacity(0.1),
                                      child: Center(
                                        child: Text(
                                          isEmpty ? 'Chưa có' : item.subject,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isEmpty
                                                ? Colors.grey
                                                : Colors.black,
                                            fontWeight: isEmpty
                                                ? FontWeight.normal
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )),
            );
          },
        );
      },
    );
  }

void _showSubjectPickerWithIcons(BuildContext context, String day, int period, List<String> subjects) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        children: subjects
            .map((subject) => ListTile(
                  leading: Icon(
                    subjectIcons[subject] ?? Icons.help_outline,
                    color: Colors.blue,
                  ),
                  title: Text(subject),
                  onTap: () {
                    DatabaseService.insertSchedule(
                      StudySchedule(
                          dayOfWeek: day, period: period + 1, subject: subject),
                    );

                    setState(() {
                      schedule[day]![period] = subject;
                      final weekday = dayToWeekday[day]!;
                      final dayDate = getWeekdayOfCurrentWeek(weekday);

                      final now = DateTime.now();
                      final reminderTime = DateTime(
                          now.year,
                          now.month,
                          dayDate.day,
                          nextMorningTime.hour,
                          nextMorningTime.minute);
                      // ReminderService.scheduleReminder(subject, reminderTime);

                      final reminderTime1 = DateTime(
                          now.year,
                          now.month,
                          dayDate.day,
                          afternoonTime.hour,
                          afternoonTime.minute);
                      // ReminderService.scheduleReminder(subject, reminderTime1);
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    ),
  );
}

Widget subjectWithIcon(String subject) {
  return Row(
    children: [
      Icon(
        subjectIcons[subject] ?? Icons.help_outline,
        size: 20,
        color: Colors.blue,
      ),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          subject,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ],
  );
}
}


class DailySettingScheduleScreen extends StatelessWidget {
  final String selectedDay;

  DailySettingScheduleScreen({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thời khoá biểu $selectedDay')),
      body: FutureBuilder<List<StudySchedule>>(
        future: DatabaseService.getAllSchedules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

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
