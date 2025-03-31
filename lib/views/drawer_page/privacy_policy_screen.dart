// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/localization/localization.dart';
import 'package:get/get.dart';
import '../../constant/app_strings.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        Localization.translate("privacy_policy").tr,
        style: TextStyle(fontSize: 25.sp),
      )),
      body: Padding(
        padding: EdgeInsets.all(18.h),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                introEng.tr,
                style: TextStyle(
                  color: Colors.black,
                ),
                textAlign: TextAlign.justify,
              ),
              Text(
                headingEng.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 20.sp,
                ),
              ),
              customDescriptionText(title: title1Eng, desc: desc1Eng),
              customDescriptionText(title: title2Eng, desc: desc2Eng),
              customDescriptionText(title: title3Eng, desc: desc3Eng),
              customDescriptionText(title: title4Eng, desc: desc4Eng),
              customDescriptionText(title: title5Eng, desc: desc5Eng),
              customDescriptionText(title: title6Eng, desc: desc6Eng),
              customDescriptionText(title: title7Eng, desc: desc7Eng),
              customDescriptionText(title: title8Eng, desc: desc8Eng),
              customDescriptionText(title: title8Eng, desc: desc8Eng),
              Text(
                conclusionEng.tr,
                style: TextStyle(color: Colors.black, fontSize: 16.sp),
                textAlign: TextAlign.justify,
              ),
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
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
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