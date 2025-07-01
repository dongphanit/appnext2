import 'package:flutter/material.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController nameController = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('➕ Thêm Nhắc nhở')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên Nhắc nhở'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Chọn thời gian nhắc: '),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) setState(() => selectedTime = time);
                  },
                  child: Text(selectedTime?.format(context) ?? 'Chọn giờ'),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Lưu Nhắc nhở - thêm logic sau
                Navigator.pop(context);
              },
              child: Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
