import 'package:flutter/material.dart';

TextStyle get titleStyle => const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF0D47A1),
    );

TextStyle get habitTitleStyle => const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

TextStyle get habitDescriptionStyle => const TextStyle(
      fontSize: 8,
      color: Colors.black87,
    );

Widget buildHabit(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: habitTitleStyle),
        // const SizedBox(height: 4),
        Text(description, style: habitDescriptionStyle),
      ],
    ),
  );
}

Widget buildSection(String heading, List<Widget> habits) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: titleStyle),
        const SizedBox(height: 12),
        ...habits,
      ],
    ),
  );
}

Widget introductionStep(Function callBack) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: ListView(
      children: [
        // Title

        Text(
            'Ứng dụng giúp bạn xây dựng Nhắc nhở học tập và sinh hoạt hiệu quả.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            )),

        const SizedBox(height: 5),
        // Example habits text
        Text(
            'Dưới đây là một số Nhắc nhở bạn có thể áp dụng để nâng cao hiệu quả học tập:',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              height: 1.5,
            )),

        buildSection('🌅 Buổi Sáng', [
          buildHabit('🕔 Thức dậy lúc 5:00 sáng',
              '→ Tạo khởi đầu ngày mới năng suất và nhiều thời gian chuẩn bị.'),
          buildHabit('💧 Uống một ly nước sau khi thức dậy',
              '→ Bắt đầu ngày mới bằng cách bù nước cho cơ thể.'),
          buildHabit('🧘‍♂️ Vận động nhẹ 10 phút',
              '→ Kéo giãn cơ thể, tập yoga hoặc đi bộ giúp tinh thần tỉnh táo.'),
        ]),
        buildSection('📚 Trong Ngày', [
          buildHabit('📖 Đọc sách 20 phút mỗi ngày',
              '→ Có thể đọc sách giáo khoa, truyện tranh khoa học, hoặc sách phát triển bản thân.'),
          buildHabit('📔 Học từ vựng mới mỗi ngày (5–10 từ)',
              '→ Tăng vốn từ tiếng Anh hoặc môn học khác bằng flashcard hoặc app từ vựng.'),
          buildHabit('⏰ Ôn bài vào một thời điểm cố định (ví dụ 19:00)',
              '→ Tạo Nhắc nhở học đều đặn, tránh học dồn trước kỳ thi.'),
        ]),
        buildSection('🌙 Buổi Tối', [
          buildHabit('✍️ Ghi lại cảm xúc cuối ngày',
              '→ Dành 5 phút viết nhật ký giúp bạn hiểu và cân bằng cảm xúc.'),
          buildHabit('📵 Không dùng điện thoại 30 phút trước khi ngủ',
              '→ Giúp bạn ngủ ngon và sâu hơn.'),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => callBack(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Bắt đầu ngay',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        )
      ],
    ),
  );
}
