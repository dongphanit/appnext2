import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ServerAddress {
  static const String upload = 'storage/upload';
  static const String serverAddress = 'http://34.142.221.32:7000/';
}

class ImageUploader {
  Future<List<String>> uploadImage({
    required String base64Image,
    required String filename,
  }) async {
    List<String> imageUrls = [];

    try {
      // Giải mã base64 thành bytes
      List<int> imageBytes = base64Decode(base64Image);

      // Tạo multipart form
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
          contentType: MediaType("image", "jpeg"), // optional
        ),
      });

      // Gửi POST request đến server
      Response response = await Dio().post(
        "${ServerAddress.serverAddress}${ServerAddress.upload}",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        imageUrls = List<String>.from(
          (responseData as List).map((e) => e.toString()),
        );
        print("✅ Upload thành công: $imageUrls");
      } else {
        print("❌ Upload thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi khi upload ảnh: $e");
    }

    return imageUrls;
  }
}
