// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/controllers/profile_controller.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/bottom_nav_controller_screen.dart';
import 'package:flutter_tour_app/views/screens/drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  // final controller = Get.put(ProfileController());

  @override
  void initState() {
    //getConnectivity();
    // need for add package screen
    //controller.getUserData(uid: firebaseAuth.currentUser!.uid);
    super.initState();
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        } as void Function(List<ConnectivityResult> event)?,
      );

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future _exitDialog(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Localization.translate("are_you_sure_to_close_this_app?")),
          content: Row(
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("No"),
              ),
              SizedBox(
                width: 20.w,
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text("Yes"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _exitDialog(context);
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            DrawerScreen(),
            BottomNavControllerScreen(),
          ],
        ),
      ),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          // title: const Text(Localization.translate("no_connection")),
          // content: const Text(Localization.translate("please_check_your_internet_connectivity")),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
}
