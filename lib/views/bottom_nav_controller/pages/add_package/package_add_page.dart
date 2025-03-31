// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/localization/localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bbbb/constant/app_colors.dart';
import 'package:bbbb/constant/constant.dart';
import 'package:bbbb/views/widgets/custom_text_field.dart';
import 'package:bbbb/views/widgets/violetButton.dart';

import '../../../../controllers/profile_controller.dart';
import '../../../screens/home_screen.dart';

class PackageAddPage extends StatefulWidget {
  const PackageAddPage({super.key});

  @override
  State<PackageAddPage> createState() => _PackageAddPageState();
}

class _PackageAddPageState extends State<PackageAddPage> {
  late final nameController;
  late final phoneController;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _facilityController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final controller = Get.put(ProfileController());

  @override
  void initState() {
    controller.getUserData(uid: firebaseAuth.currentUser!.uid);
    super.initState();
    nameController = TextEditingController(text: controller.user['name']);
    phoneController =
        TextEditingController(text: controller.user['phone_number']);
  }

  final ImagePicker _picker = ImagePicker();

  var authCredential = firebaseAuth.currentUser;

  RxBool isLoading = false.obs;

  List<XFile>? multipleImages;
  List<String> imageUrlList = [];

  Future multipleImagePicker() async {
    multipleImages = await _picker.pickMultiImage();
    setState(() {});
  }

  Future uploadImages() async {
    uploadToDB();
    return;
    try {
      if (multipleImages != null) {
        for (int i = 0; i < multipleImages!.length; i += 1) {
          // upload to stroage
          File imageFile = File(multipleImages![i].path);

          UploadTask uploadTask = firebaseStorage
              .ref('${firebaseAuth.currentUser!.email}')
              .child(multipleImages![i].name)
              .putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          imageUrlList.add(imageUrl);
        }

        // upload to database
        uploadToDB();
      } else {
        Get.snackbar("Error", Localization.translate("something_is_wrong!"),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed");
      Get.back();
    }
  }

  uploadToDB() {
    // if (imageUrlList.isNotEmpty) {
      CollectionReference data = firestore.collection("all-data");
      int cost = int.parse(_costController.text);
      data.doc().set(
        {
          "owner_name": controller.user['name'],
          "description": _descriptionController.text,
          "cost": int.parse(_costController.text),
          "approved": false,
          "forYou": true,
          "topPlaces": cost >= 2000 && cost <= 5000 ? true : false,
          "economy": cost <= 3000 ? true : false,
          "luxury": cost >= 10000 ? true : false,
          "facilities": _facilityController.text,
          "destination": _destinationController.text,
          "phone": controller.user['phone_number'],
          "uid": firebaseAuth.currentUser!.uid,
          'date_time': DateTime.now(),
          // "gallery_img":
          //     FieldValue.arrayUnion(imageUrlList), //we create image list
        },
      ).whenComplete(() {
        Get.snackbar("Successful", Localization.translate("uploaded_successfully."));
      });
      Get.to(
        () => HomeScreen(),
      );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                customTextField(
                  Localization.translate("owner_name").tr,
                  nameController,
                  TextInputType.text,
                  onlyRead: true,
                ),
                customTextField(
                  Localization.translate("phone_number").tr,
                  phoneController,
                  TextInputType.number,
                  onlyRead: true,
                ),
                customTextField(
                  "Cost".tr,
                  _costController,
                  TextInputType.number,
                  onlyRead: false,
                ),
                customTextField(
                  "Destination".tr,
                  _destinationController,
                  TextInputType.text,
                  onlyRead: false,
                ),
                customTextField(
                  "Description".tr,
                  _descriptionController,
                  TextInputType.text,
                  onlyRead: false,
                ),
                customTextField(
                  "Facilites".tr,
                  _facilityController,
                  TextInputType.text,
                  maxline: 4,
                  onlyRead: false,
                ),
                Text(
                  Localization.translate("select_image").tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                  ),
                ),
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFE9EBED),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7.r),
                    ),
                  ),
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: AppColors.violetColor,
                      onPressed: () => multipleImagePicker(),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: multipleImages?.length != null ? 100 : 0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: multipleImages?.length ?? 0,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: SizedBox(
                          width: 100,
                          child: multipleImages?.length == null
                              ? const Center(
                                  child: Text("Images are empty"),
                                )
                              : Image.file(
                                  File(multipleImages![index].path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  return VioletButton(
                    isLoading: isLoading.value,
                    title: "Submit".tr,
                    onAction: () async {
                      if (_descriptionController.text.isEmpty ||
                          _descriptionController.text.length < 3) {
                        Fluttertoast.showToast(
                            msg: Localization.translate("description_must_be_at_least_3_character"));
                      } else if (_costController.text.isEmpty ||
                          _costController.text.length < 3) {
                        Fluttertoast.showToast(
                            msg: Localization.translate("cost_must_be_at_least_3_character"));
                      } else if (_facilityController.text.isEmpty ||
                          _facilityController.text.length < 3) {
                        Fluttertoast.showToast(
                            msg: Localization.translate("facility_must_be_at_least_3_character"));
                      } else if (_destinationController.text.isEmpty ||
                          _destinationController.text.length < 3) {
                        Fluttertoast.showToast(
                            msg: Localization.translate("destination_must_be_at_least_3_character"));
                      } else {
                        isLoading(true);
                        await uploadImages();
                        isLoading(false);
                        Get.back();
                      }
                    },
                  );
                }),
                  SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}