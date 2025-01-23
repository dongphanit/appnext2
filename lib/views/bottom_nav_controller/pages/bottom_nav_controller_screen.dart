import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';
// import 'package:flutter_tour_app/constant/app_strings.dart';
import 'package:get/get.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:intl/intl.dart' as intl;
import '../../../constant/app_colors.dart';

import 'package:flutter_tour_app/views/auth/login_screen.dart';

class BottomNavControllerScreen extends StatefulWidget {
  BottomNavControllerScreen({super.key});

  @override
  _BottomNavControllerScreenState createState() =>
      _BottomNavControllerScreenState();
}

class _BottomNavControllerScreenState extends State<BottomNavControllerScreen> {
  final RxInt _currentIndex = 0.obs;
  final RxBool _drawer = false.obs;
  String? role;

  @override
  void initState() {
    super.initState();
    getDate();
  }

  Future<void> getDate() async {
    if (firebaseAuth.currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .get();
      var userData = userSnapshot.data() as Map<String, dynamic>?;
      
      setState(() {
        role = userData?['role'];
      });
      debugPrint(role);
    }
  }

  void _onTabTapped(int index) {
    if (index == 1 || index == 2) {
      debugPrint(firebaseAuth.currentUser.toString());
      // Check if user is logged in
      if (firebaseAuth.currentUser == null) {
        // Show login modal
        _showLoginDialog();
      } else {
        // Navigate to the selected tab
        setState(() {
          _currentIndex.value = index;
        });
      }
    } else {
      // Navigate to the selected tab
      setState(() {
        _currentIndex.value = index;
      });
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text(Localization.translate("login_required")),
          content: Text(Localization.translate("you_must_be_logged_in_to_access_this_section")),
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
                // Navigate to the login screen

                Get.to(() => SignInScreen());
                // Add your login navigation logic here
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        // leading: _drawer.value == false
        //     ? IconButton(
        //         onPressed: () {
        //           _drawer.value = true;
        //         },
        //         icon: Icon(
        //           Icons.menu,
        //           color: Colors.black,
        //         ),
        //       )
        //     : IconButton(
        //         onPressed: () {
        //           _drawer.value = false;
        //         },
        //         icon: Icon(
        //           Icons.close,
        //           color: Colors.black,
        //         ),
        //       ),
        // actions: [
        //   Center(
        //     child: Text(
        //       intl.DateFormat("eee,_mmm_d,_").format(DateTime.now()),
        //       style: TextStyle(color: AppColors.textColor, fontSize: 18.sp),
        //     ),
        //   ),
        //   SizedBox(width: 15.w),
        // ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.scaffoldColor,
        selectedItemColor: AppColors.textColor,
        elevation: 0,
        onTap: _onTabTapped, // Updated onTap logic
        currentIndex: _currentIndex.value,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 30,
            ),
            label: "Home".tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings".tr,
          ),
          // BottomNavigationBarItem(
          //   icon: Image(
          //     image: AssetImage('assets/images/direction.png'),
          //     height: 30,
          //   ),
          //   label: "TourGuide".tr,
          // ),
        ],
      ),
      body: role == 'CardHolder'
          ? pagesCardHolder[_currentIndex.value]
          : pages[_currentIndex.value],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  // color: AppColors.primaryColor,
                  ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                _currentIndex.value = 0;
                _drawer.value = false;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                _currentIndex.value = 1;
                _drawer.value = false;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
