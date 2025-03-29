import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  String? msg;

  @override
  void initState() {
    super.initState();
    // _sendOTP();
  }

  // Hàm gửi OTP đến số điện thoại
  Future<void> _sendOTP() async {
    setState(() {
          msg='_sendOTP';
        });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
         setState(() {
          msg='Xác minh tự động thành công!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác minh tự động thành công!')),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Lỗi xác minh: ${e.message}');
           setState(() {
          msg='Lỗi xác minh: ${e.message}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xác minh: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          msg='OTP đã được gửi đến ${widget.phoneNumber}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP đã được gửi đến ${widget.phoneNumber}')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // Hàm xác minh OTP
  Future<void> _verifyOTP() async {
    setState(() {
          msg='_verifyOTP';
        });
    if (_verificationId != null) {
      final otp = _otpController.text;
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() {
          msg='Xác minh thành công!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác minh thành công!')),
        );
      } catch (e) {
         setState(() {
          msg='Xác minh thất bại: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác minh thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xác minh OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Số điện thoại: ${widget.phoneNumber}'),

            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
                hintText: 'Nhập OTP',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOTP,
              child: Text('Xác minh OTP'),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Xác minh OTP'),
            ),
             Text('Số điện thoại: ${msg}'),
          ],
        ),
      ),
    );
  }
}
