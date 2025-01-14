// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tour_app/localization/localization.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/details_screen.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/controllers/profile_controller.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/bottom_nav_controller_screen.dart';
import 'package:flutter_tour_app/views/screens/drawer_screen.dart';
// Screen 2: Avail Credit Card Offers
class HomeBuyer extends StatelessWidget {
   TextEditingController _controller = TextEditingController();

  void _checkAndNavigate(BuildContext context) {
    String searchQuery = _controller.text;
    if (searchQuery.isNotEmpty) {
      // Navigate to ProductDetailPage and pass the search query as a parameter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(productUrl: _controller.text),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avail credit card offers without owning credit cards',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Paste a Flipkart link',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => _checkAndNavigate(context),
            ),
              SizedBox(height: 16),
              Container(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    BannerCard(image: 'assets/banner1.jpg', title: 'Electronic Day'),
                    BannerCard(image: 'assets/banner2.jpg', title: 'Grocery Deals'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              OfferCard(
                offerText: '10% off upto ₹50',
                details: 'WELCOME | EXPIRES ON 24th APR',
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CategoryIcon(icon: Icons.shopping_cart, label: 'Flipkart'),
                  CategoryIcon(icon: Icons.ac_unit, label: 'Nutrition'),
                  CategoryIcon(icon: Icons.health_and_safety, label: 'Health'),
                  CategoryIcon(icon: Icons.ac_unit_rounded, label: 'Beauty'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final String image;
  final String title;

  const BannerCard({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String offerText;
  final String details;

  const OfferCard({required this.offerText, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offerText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          child: Icon(icon, size: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

