import 'dart:async';
import 'dart:developer';
import 'package:customer_app/views/entry/entry.dart';
import 'package:customer_app/views/onBoard/on_boarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';

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
    Timer(const Duration(seconds: 2), () {
      if (user != null) {
        Get.offAll(() => EntryScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900));
        log("User is authenticated");
      } else {
        Get.offAll(() => const OnBoardingScreen(),
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
              "assets/assets/logo-no-background.png",
              height: 300.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
