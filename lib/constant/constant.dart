// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/buyer_home.dart';

import '../views/bottom_nav_controller/pages/add_package/package_add_page.dart';

//Page
List pages = [
 HomeBuyer(),
 Settings()
];
//Firebase
var firebaseAuth = FirebaseAuth.instance;
var firestore = FirebaseFirestore.instance;
var firebaseStorage = FirebaseStorage.instance;

//Firebase collection name
const allPackages = "all-data";
const usersCollection = "users";
