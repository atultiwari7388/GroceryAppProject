import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:otp_autofill/otp_autofill.dart';

import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../controllers/authentication_controller.dart';
import '../../utils/app_style.dart';

class OtpAuthenticationScreen extends StatefulWidget {
  const OtpAuthenticationScreen({super.key, required this.verificationId});

  final String verificationId;

  @override
  State<OtpAuthenticationScreen> createState() =>
      _OtpAuthenticationScreenState();
}

class _OtpAuthenticationScreenState extends State<OtpAuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    AuthenticationController controller = Get.find<AuthenticationController>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: kLightWhite,
        appBar: AppBar(),
        body: controller.isVerification
            ? Center(
          child: Lottie.asset(
            "assets/anime/animation_2.json",
            repeat: true,
            height: 200,
            width: 240,
            // fit: BoxFit.cover,
          ),
        )
            : Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(left: 10, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .2),
              Center(
                child: ReusableText(
                  text: "OTP Verification",
                  style: appStyle(20, kDark, FontWeight.normal),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text("We have sent a verification code to",
                    style: appStyle(14, kDark, FontWeight.normal)),
              ),
              SizedBox(height: 5.h),
              Center(
                child: Text(
                    " +91${controller.phoneController.text.toString()}",
                    style: appStyle(14, kDark, FontWeight.bold)),
              ),
              SizedBox(height: 20.h),
              Center(
                child: SizedBox(
                  height: size.height / 18,
                  width: size.width / 1.2,
                  child: PinCodeTextField(
                    appContext: context,
                    controller: controller.otpController,
                    length: 6,
                    onChanged: (val) {
                      log("Otp Value $val");
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(18),
                      fieldHeight: size.height / 19,
                      fieldWidth: size.width / 8,
                    ),
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onCompleted: (otp) {
                      controller.otpController.text = otp;
                      controller.signInWithPhoneNumber(context, otp);
                    },
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
