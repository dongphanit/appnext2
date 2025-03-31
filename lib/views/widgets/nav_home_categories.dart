// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/localization/localization.dart';

Widget navHomeCategories(String categoryName, onClick) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            categoryName,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
        InkWell(
          onTap: onClick,
          child: Text(
            Localization.translate("see_more"),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,color: Color(0xFF2BA018)),
          ),
        ),
      ],
    ),
  );
}