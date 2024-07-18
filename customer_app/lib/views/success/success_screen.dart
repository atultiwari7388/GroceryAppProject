import 'dart:async';
import 'package:customer_app/views/dashboard/dashboard_screen.dart';
import 'package:customer_app/views/entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart'; // Import for vibrating device

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Vibration.vibrate(duration: 1000); // Vibrate for 1 second
    // Start a timer to automatically redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => EntryScreen(),
          transition: Transition.fade, arguments: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.h,
            ),
            SizedBox(height: 20.h),
            Text('Order Successful!',
                style: appStyle(24, kDark, FontWeight.normal)),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ordered Food',
                    textAlign: TextAlign.center,
                    style: appStyle(18, kDark, FontWeight.normal),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            CustomGradientButton(
              text: "Back to History",
              onPress: () {
                Get.offAll(() => EntryScreen(),
                    transition: Transition.fade, arguments: 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
