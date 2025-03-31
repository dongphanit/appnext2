// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/constant/app_colors.dart';
import 'package:bbbb/constant/app_strings.dart';
import 'package:bbbb/localization/localization.dart';
import 'package:get/get.dart';
import 'package:bbbb/controllers/language_controller.dart';
import 'package:bbbb/views/drawer_page/faq_screen.dart';
import 'package:bbbb/views/drawer_page/privacy_policy_screen.dart';
import 'package:bbbb/views/drawer_page/support_screen.dart';
import 'package:bbbb/views/widgets/drawer_item.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});

  final controller = Get.put(LanguageControler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.scaffoldColor,
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, top: 50.h, bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
               appName,
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 40.h),
              drawerItem(
                itemName: 'Support'.tr,
                onClick: () => Get.to(() => SupportScreen()),
              ),
              SizedBox(height: 10.h),
              drawerItem(
                itemName: 'Privacy'.tr,
                onClick: () => Get.to(() => PrivacyPolicyScreen()),
              ),
              SizedBox(height: 10.h),
              drawerItem(
                itemName: 'Faq'.tr,
                onClick: () => Get.to(
                  () => FaqScreen(),
                ),
              ),
              SizedBox(
                width: 150.w,
                child: ExpansionTile(
                  title: Text("Language".tr,style: TextStyle(fontSize: 20.sp),),
                  tilePadding: EdgeInsets.all(0.0),
                  childrenPadding: EdgeInsets.all(0.0),
                  children: [
                    Obx(() {
                      return Row(
                        children: [
                          Radio(
                            value: "Bangla",
                            groupValue: controller.selectedLanguage.value,
                            onChanged: (value) {
                              controller.changeLanguage(value);
                              Get.updateLocale(const Locale('bn', 'BD'));
                              Localization.setLanguage(Get.locale?.languageCode??"en");
                            },
                          ),
                          Text("Bangla".tr),
                        ],
                      );
                    }),
                    Obx(() {
                      return Row(
                        children: [
                          Radio(
                            value: "English",
                            groupValue: controller.selectedLanguage.value,
                            onChanged: (value) {
                              controller.changeLanguage(value);
                              Get.updateLocale(const Locale('en', 'US'));
                              Localization.setLanguage(Get.locale?.languageCode??"en");
                            },
                          ),
                          Text("English".tr),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              InkWell(
                onTap: () => Get.to(() => Settings()),
                child: Text(
                  "Settings".tr,
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
