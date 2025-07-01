import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habits/setting_schedule_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  Map<String, bool> _subjectToday = {};

  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  @override
  void initState() {
    super.initState();
    loadSubjectToday();

      _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-4711642231404676/6804185643', // Replace with your real banner ID
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
      _subjectToday = {
        for (var item in daySchedules.map((e) => e.subject)) item: false
      };
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
      for (int i = 0;
          i < saveToday.length && i < _subjectToday.keys.length;
          i++) {
        _subjectToday[_subjectToday.keys.elementAt(i)] = saveToday[i] == 'true';
      }
    }
    print(saveToday);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học hôm nay'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Môn học:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                        onChanged: (val) async {
                          final prefs = await SharedPreferences.getInstance();
                          final updatedSubjects =
                              Map<String, bool>.from(_subjectToday);
                          updatedSubjects[entry.key] = val!;
                          await prefs.setStringList(
                            'subjectToday',
                            updatedSubjects.entries
                                .map((e) => '${e.key}:${e.value}')
                                .toList(),
                          );
                          setState(() {
                            _subjectToday[entry.key] = val;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}