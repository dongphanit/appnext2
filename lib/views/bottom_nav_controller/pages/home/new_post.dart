import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tour_app/constant/app_colors.dart';
import 'package:flutter_tour_app/services/firestore_services.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/gps_screen.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/upload.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:latlong2/latlong.dart';

class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final _formKey = GlobalKey<FormState>();
  String category = 'Đồ ăn';
  String deviceId = '';
  String userInfo = '';
  String mode = 'Cho miễn phí';
  String location = '';
  String gpsLat = '15.80896740868602, 108.3942308977846';
  String title = '';
  String description = '';
  String phone = '';
  String imageUrl = '';
  String price = '';
  bool isFree = true;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  @override
  void initState() {
    super.initState();
    getDeviceId().then((id) {
      setState(() {
        deviceId = id;
      });
    });
    _controller.text = price;
  }

  final _controller = TextEditingController();
  final formatter =
      NumberFormat.decimalPattern(); // định dạng số theo locale (vd: 1,000,000)

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    // Xóa tất cả ký tự không phải số
    String digitsOnly = s.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';

    // Chuyển về số nguyên
    int value = int.parse(digitsOnly);
    return formatter.format(value);
  }

  Future<void> _pickImageWebCompatible() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // để lấy bytes trực tiếp
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      Uint8List? bytes = file.bytes;

      if (bytes != null) {
        String base64Image = base64Encode(bytes);
        final uploader = ImageUploader();
        List<String> urls = await uploader.uploadImage(
          base64Image: base64Image,
          filename: file.name,
        );
        // imageUrl = urls.join(', '); // Giả sử upload trả về danh sách URL
        print("📤 Uploaded image URL: $urls");

        // Nếu bạn muốn lưu ảnh để hiển thị:
        setState(() {
          imageUrl = urls.first; // Uint8List? dùng cho Image.memory
        });
      }
    } else {
      print("❌ No image selected");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Đọc ảnh thành bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Mã hóa base64
      String base64Image = base64Encode(imageBytes);

      // Gọi uploader
      final uploader = ImageUploader();

      List<String> urls = await uploader.uploadImage(
        base64Image: base64Image,
        filename: "my_image.jpg",
      );

      // In kết quả hoặc xử lý tiếp
      print("Uploaded image URL: $urls");

      setState(() {
        _image = pickedFile; // hiển thị ảnh nếu muốn
      });
    } else {
      print("No image selected");
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        String downloadURL;

        if (kIsWeb) {
          TaskSnapshot snapshot = await _storage
              .ref('hinhanh/$fileName')
              .putData(await _image!.readAsBytes());
          downloadURL = await snapshot.ref.getDownloadURL();
        } else {
          TaskSnapshot snapshot = await _storage
              .ref('hinhanh/$fileName')
              .putFile(File(_image!.path));
          downloadURL = await snapshot.ref.getDownloadURL();
        }
        setState(() {
          imageUrl = downloadURL;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload successful!')),
          );
        }
      } on FirebaseException catch (e) {
        if (e.code == 'unauthorized') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'User is not authorized to perform the desired action.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected!')),
        );
      }
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      return 'web-device-id'; // Placeholder for web, as device ID is not applicable
    }
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'unknown';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    } else {
      return 'unsupported-platform';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng món đồ'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.textFormColor, width: 1.5),
                ),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _pickImageWebCompatible,
                    icon: const Icon(Icons.camera_alt,
                        color: AppColors.textFormColor),
                    label: const Text(
                      "Chọn hình ảnh",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textFormColor,
                    ),
                  ),
                ),
              ),
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ServerAddress.serverAddress + imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Thông tin người đăng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textFormIconColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Tên người đăng',
                onChanged: (value) => setState(() => userInfo = value),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thông tin món đồ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textFormIconColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Tên món đồ',
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Địa điểm',
                onChanged: (value) => setState(() => location = value),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  final LatLng? selectedLocation =
                      await Get.to(() => LocationPickerWebPage());
                  if (selectedLocation != null) {
                    setState(() {
                      gpsLat =
                          "${selectedLocation.latitude}, ${selectedLocation.longitude}";
                      // location = "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
                    });
                  }
                },
                icon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textFormColor),
                label: const Text('Chọn vị trí'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textFormColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration(label: 'Danh mục'),
                value: category,
                items: ['Đồ ăn', 'Quần áo', 'Điện tử', 'Sách', 'Đồ chơi']
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Mô tả',
                maxLines: 3,
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                maxLines: 1,
                onChanged: (value) => setState(() => phone = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration(label: 'Hình thức'),
                value: mode,
                items: ['Cho miễn phí', 'Bán giá rẻ']
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => mode = value!),
              ),
              const SizedBox(height: 16),
              if (mode == 'Bán giá rẻ')
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(label: 'Giá tiền (VND)'),
                  onChanged: (value) {
                    String formatted = _formatNumber(value);
                    if (formatted != _controller.text) {
                      _controller.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                    setState(() {
                      price = formatted;
                      isFree = false;
                    });
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textFormColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _submitForm,
                child: const Text('Đăng bài'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textFormColor),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textFormColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textFormColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (title.isEmpty ||
        description.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        gpsLat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hình ảnh')),
      );
      return;
    }
    if (mode == 'Cho miễn phí') {
      price = '0';
      isFree = true;
    } else {
      isFree = false;
    }
    if (phone.isNotEmpty && !RegExp(r'^\d{10,11}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không hợp lệ')),
      );
      return;
    }
    if (price.isNotEmpty && !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá tiền không hợp lệ')),
      );
      return;
    }
    if (gpsLat.isEmpty ||
        !RegExp(r'^-?\d{1,3}\.\d+,\s*-?\d{1,3}\.\d+$').hasMatch(gpsLat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vị trí GPS không hợp lệ')),
      );
      return;
    }

    FirestoreServices().createPost(
      deviceId: deviceId,
      userInfo: userInfo,
      category: category,
      title: title,
      phone: phone,
      description: description,
      imageUrl: imageUrl,
      location: location,
      price: double.tryParse(price) ?? 0.0,
      isFree: isFree,
      gpsLat: gpsLat,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng bài thành công!')),
    );
    Get.back();
  }
}
