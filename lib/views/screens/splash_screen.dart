// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/views/auth/login_screen.dart';
import 'package:flutter_tour_app/views/screens/home_screen.dart';

import '../../constant/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      // ! ---To go to the next screen and cancel all previous routes (Get.to)
      firebaseAuth.authStateChanges().listen((event) {
        if (event == null && mounted) {
          Get.to(() => HomeScreen());
        } else {
          Get.to(() => HomeScreen());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/logo/logo.png",
                height: 250.h,
                width: 250.h,
              ),
            ),
            CircularProgressIndicator(color: AppColors.splashScreenTextColor),
          ],
        ),
      ),
    );
  }
}