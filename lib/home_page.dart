import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habits/habit.dart';
import 'package:intl/intl.dart';

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: const HomeScreen(),
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
          await HabitDatabase.instance.scheduleNotification(habit.title, timeOfDay, habit.id!);
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
    return '📅 Hôm nay: ';// $weekday, ${DateFormat('dd/MM/yyyy').format(now)}
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá thói quen'),
        content: const Text('Bạn có chắc muốn xoá thói quen này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
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

@override
void initState() {
  super.initState();
  _loadHabits();
  _bannerAd = BannerAd(
    adUnitId: 'ca-app-pub-4711642231404676/6804185643', // Replace with your real banner ID
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (_) {
        setState(() {
          _isBannerReady = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        debugPrint('Ad load failed (code=${error.code}): ${error.message}');
      },
    ),
  )..load();
}

@override
void dispose() {
  _bannerAd.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
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
                            style: TextStyle(fontSize: 18, color: Colors.grey),
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
                                  color: habit.isDone ? Colors.green : Colors.grey,
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
                                        await HabitDatabase.instance.updateHabit(updated);
                                        _loadHabits();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(habit.id!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                )
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
                            if (time != null) setState(() => selectedTime = time);
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
