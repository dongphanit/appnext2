// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';
import 'package:get/get.dart';

import '../../constant/app_strings.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Chính sách",
        style: TextStyle(fontSize: 25.sp),
      )),
      body: Padding(
        padding: EdgeInsets.all(18.h),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disputeIntroVie,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  Text(
                    disputeHeadingVie,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                    ),
                  ),
                  customDescriptionText(title: "", desc: disputeDetail1Vie),
                  customDescriptionText(title: "", desc: disputeDetail2Vie),
                  Text(
                    disputeProcessTitleVie,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                    ),
                  ),
                  customDescriptionText(title: "", desc: disputeStep1Vie),
                  customDescriptionText(title: "", desc: disputeStep2Vie),
                  customDescriptionText(title: "", desc: disputeStep3Vie),
                  Text(
                    disputeContactInfoVie,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget customDescriptionText({required String title, required String desc}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            fontSize: 13.sp,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            desc.tr,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
