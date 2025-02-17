// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';

import '../../constant/app_colors.dart';

class VioletButton extends StatelessWidget {
  bool isLoading;
  String title;
  final VoidCallback onAction;
  VioletButton(
      {super.key,
      required this.isLoading,
      required this.title,
      required this.onAction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAction,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppColors.violetColor,
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        child: isLoading == false
            ? Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Localization.translate("please_wait"),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Transform.scale(
                    scale: 0.5,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
