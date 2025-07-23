import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/new_post.dart';
// import 'package:flutter_tour_app/constant/app_strings.dart';
import 'package:get/get.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:intl/intl.dart' as intl;
import '../../../constant/app_colors.dart';

import 'package:flutter_tour_app/views/auth/login_screen.dart';

class BottomNavControllerScreen extends StatelessWidget {
  BottomNavControllerScreen({super.key});
  final RxInt _currentIndex = 0.obs;
  final RxBool _drawer = false.obs;

  void _onTabTapped(int index) {
    if (index == 1) {
      // Navigate to the new post page
      Get.to(() => PostItemPage());
      return;
    }
    // if (index == 2) {
    //   print(firebaseAuth.currentUser);
    //   // Check if user is logged in
    //   if (firebaseAuth.currentUser == null) {
    //     // Show login modal
    //     _showLoginDialog();
    //   } else {
    //     // Navigate to the selected tab
    //     _currentIndex.value = index;
    //   }
    // } else {
      // Navigate to the selected tab
      _currentIndex.value = index;
    // }
  }

  void _showLoginDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text(Localization.translate("login_required")),
          content: Text(Localization.translate(
              "you_must_be_logged_in_to_access_this_section.")),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Write code show model present  SignInScreen
                Future.delayed(Duration(milliseconds: 100), () {
                  // Navigate to the SignInScreen
                    Get.to(() => SignInScreen());
                });
              
                
              },  
              child: Text("Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedPositioned(
        duration: Duration(milliseconds: 400),
        top: _drawer.value == false ? 0 : 100.h,
        bottom: _drawer.value == false ? 0 : 100.h,
        left: _drawer.value == false ? 0 : 200.w,
        right: _drawer.value == false ? 0 : -100.w,
        child: Container(
          decoration: BoxDecoration(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              title: Text(
                "Chợ Thường",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
              leading: _drawer.value == false
                  ? IconButton(
                      onPressed: () {
                        _drawer.value = true;
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        _drawer.value = false;
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
              actions: [
                Center(
                  child: Text(
                    intl.DateFormat("").format(DateTime.now()),
                    style:
                        TextStyle(color: AppColors.textColor, fontSize: 18.sp),
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: BottomNavigationBar(
                  backgroundColor: AppColors.scaffoldColor,
                  selectedItemColor: AppColors.primaryColor, // dùng màu chủ đạo
                  unselectedItemColor: Colors.grey[500],
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  iconSize: 26,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex.value,
                  onTap: _onTabTapped,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: "Trang chủ",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle_outline),
                      label: "Đăng bài",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: "Tài khoản",
                    ),
                  ],
                ),
              ),
            ),
            body: pages[_currentIndex.value],
          ),
        ),
      ),
    );
  }
}
