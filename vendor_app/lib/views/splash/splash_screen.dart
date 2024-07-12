import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../services/collection_reference.dart';
import '../adminReview/admin_review_screen.dart';
import '../auth/phone_auth_screen.dart';
import '../dashboardScreen/dash_board_scren.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () async {
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance.doc("Vendors/$currentUId").get();

        if (doc.exists) {
          if (doc["approved"] == true) {
            log("Go to Dashboard Screen");
            Get.offAll(() => DashboardScreen(),
                transition: Transition.cupertino,
                duration: const Duration(milliseconds: 900));
            log("User is authenticated");
          } else if (doc["approved"] == false) {
            log("go to admin review screen");
            //send to admin review screen
            Get.offAll(() => AdminReviewScreen());
          } else {
            Get.offAll(() => const PhoneAuthenticationScreen());
          }
        }
      } else {
        Get.offAll(() => const PhoneAuthenticationScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900));
        log("User is null");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Image.asset(
            "assets/logo.png",
            height: 250.h,
            fit: BoxFit.cover,
          )),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
