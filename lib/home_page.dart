import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habits/habit.dart';
import 'package:habits/homework_reminder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary =
      Color(0xFF2ECC71); // Xanh da trời sáng – tạo cảm giác tin tưởng
  static const secondary = Color(0xFF7ED6DF); // Xanh ngọc – nhẹ nhàng, thư giãn
  static const background = Color(0xFFFDFDFD); // Trắng ngà – nhẹ mắt khi đọc
  static const text = Color(0xFF2C3E50); // Đen xám – dễ đọc
  static const muted =
      Color(0xFFB0BEC5); // Xám nhẹ – dùng cho mô tả, tiêu đề phụ
  static const success =
      Color(0xFF2ECC71); // Xanh lá – hoàn thành bài, tích cực
  static const warning = Color(0xFFF1C40F); // Vàng – nhắc nhở
  static const error = Color(0xFFE74C3C); // Đỏ – lỗi
  static const card = Color(0xFFF3F7FA); // Nền cho ô, bảng
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lịch học',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(AppColors.primary),
        ),
      ),
      home: MainTabController(),
    );
  }
}

class MainTabController extends StatefulWidget {
  const MainTabController({super.key});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    checkAndShowIntro(context);
     _pages = [

      const HomeScreen(),
      ScheduleScreen(),
    ];
  }

  Future<void> checkAndShowIntro(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('firstApp') ?? false;

    if (!seenIntro) {
      _currentIndex = 1; // Start with the intro screen
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Colors.green),
            label: 'Lịch thói quen',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.green),
            label: 'Thiết lập',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> habits = [];

  Future<void> _loadHabits() async {
    habits = await HabitDatabase.instance.getHabits();
    for (final habit in habits) {
      try {
        final timeParts = habit.time.split(':');
        if (timeParts.length == 2) {
          final timeOfDay = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          await HabitDatabase.instance
              .scheduleNotification(habit.title, timeOfDay, habit.id!);
        } else {
          debugPrint('Invalid time format for habit: ${habit.time}');
        }
      } catch (e) {
        debugPrint('Error parsing time for habit: ${habit.time}, error: $e');
      }
    }

    setState(() {});
  }

  String _getToday() {
    final now = DateTime.now();
    // final weekday = DateFormat.EEEE('vi').format(now);
    return '📅 Hôm nay: '; // $weekday, ${DateFormat('dd/MM/yyyy').format(now)}
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá thói quen'),
        content: const Text('Bạn có chắc muốn xoá thói quen này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xoá')),
        ],
      ),
    );
    if (confirmed == true) {
      await HabitDatabase.instance.deleteHabit(id);
      _loadHabits();
    }
  }

  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  Map<String, bool> _subjectToday = {


  };

  @override
  void initState() {
    super.initState();
    _loadHabits();

    loadSubjectToday();
    //   _bannerAd = BannerAd(
    //   adUnitId:
    //       'ca-app-pub-4711642231404676/6804185643', // Replace with your real banner ID
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) {
    //       setState(() {
    //         _isBannerReady = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //       debugPrint('Ad load failed (code=${error.code}): ${error.message}');
    //     },
    //   ),
    // )..load();
  }
  void loadSubjectToday() async {
   
    // get dayOfWeek of today
    final now = DateTime.now();
     
    final dayOfWeek = "Tuesday"; // DateFormat.EEEE('vi').format(now);
       final schedules = await DatabaseService.getAllSchedules();
      final daySchedules = schedules
          .where((item) => item.dayOfWeek == dayOfWeek)
          .toList()
        ..sort((a, b) => a.period.compareTo(b.period));
      setState(() {
        _subjectToday = {for (var item in daySchedules.map((e) => e.subject)) item: true};
      });
    print(_subjectToday); 
    final prefs = await SharedPreferences.getInstance();
    final lastSavedDate = prefs.getString('lastSavedDate');
    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    if (lastSavedDate != todayDate) {
      prefs.setString('lastSavedDate', todayDate);
      prefs.remove('subjectToday'); // Clear previous day's data
    }

    final saveToday = prefs.getStringList('subjectToday') ?? [];
    // Update only the values of _subjectToday based on saveToday
    if (saveToday.isNotEmpty) {
      for (int i = 0; i < saveToday.length && i < _subjectToday.keys.length; i++) {
      _subjectToday[_subjectToday.keys.elementAt(i)] = saveToday[i] == 'true';
      }
    }
    print(saveToday);

    
  
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("asdsadasd: $_subjectToday");
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌞 Xin chào, bạn!'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          if (_isBannerReady)
            Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  _getToday(),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                  child: habits.isEmpty
                    ? const Center(
                      child: Text(
                        'Chưa có thói quen nào.',
                        style:
                          TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      )
                    : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: Icon(
                          habit.isDone
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                          color: habit.isDone
                            ? Colors.green
                            : Colors.grey,
                          size: 32,
                          ),
                          title: Text(
                          habit.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          ),
                          subtitle: Text(
                          '🔔 ${habit.time}',
                          style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                            value: habit.isDone,
                            onChanged: (val) async {
                              final updated = Habit(
                              id: habit.id,
                              title: habit.title,
                              time: habit.time,
                              isDone: val!,
                              );
                              await HabitDatabase.instance
                                .updateHabit(updated);
                              _loadHabits();
                            },
                            ),
                            IconButton(
                            icon: const Icon(Icons.delete,
                              color: Colors.red),
                            onPressed: () =>
                              _confirmDelete(habit.id!),
                            ),
                          ],
                          ),
                        ),
                        );
                      },
                      ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                  '📚 Môn học hôm nay:',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                  child: ListView(
                    children: _subjectToday.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                      // leading: Icon(
                      //   entry.value ? Icons.check_circle : Icons.circle_outlined,
                      //   color: entry.value ? Colors.green : Colors.grey,
                      //   size: 32,
                      // ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        entry.value ? '✅ Đã hoàn thành' : '⏳ Chưa hoàn thành',
                        style: TextStyle(
                        color: entry.value ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: Checkbox(
                        value: entry.value,
                        onChanged: (val) {
                        final prefs = SharedPreferences.getInstance();
                        // re save _subjectToday to shared preferences
                        prefs.then((prefs) {
                          final updatedSubjects = Map<String, bool>.from(_subjectToday);
                          updatedSubjects[entry.key] = val!;
                          prefs.setStringList('subjectToday', updatedSubjects.values.map((e) => e.toString()).toList());
                        }); 
                        setState(() {
                          _subjectToday[entry.key] = val!;
                        });
                        },
                      ),
                      ),
                    );
                    }).toList(),
                  ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Thêm thói quen',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
          _loadHabits();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _controller = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('➕ Thêm thói quen'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Tên thói quen',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Thời gian nhắc: '),
                        const SizedBox(width: 10),
                        Text(
                          selectedTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null)
                              setState(() => selectedTime = time);
                          },
                          child: const Text('Chọn giờ'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Lưu thói quen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (_controller.text.isEmpty) return;
                final newHabit = Habit(
                  title: _controller.text,
                  time: selectedTime.format(context),
                );
                await HabitDatabase.instance.insertHabit(newHabit);
                if (context.mounted) Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
