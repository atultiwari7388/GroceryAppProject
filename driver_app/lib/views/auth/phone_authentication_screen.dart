import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../controllers/authentication_controller.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class PhoneAuthenticationScreen extends StatelessWidget {
  const PhoneAuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<AuthenticationController>(
        init: AuthenticationController(),
        builder: (controller) {
          if (!controller.isLoading) {
            return Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image or App Logo
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        image: DecorationImage(
                          image: AssetImage("assets/logo-no-background.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // phone auth and login section
                  Expanded(
                    flex: 1,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Heading
                        SizedBox(height: 7.h),
                        Text("Welcome to GroceryApp\n Driver",
                            textAlign: TextAlign.center,
                            style: appStyle(19, kDark, FontWeight.bold)),
                        // Login or Signup Text
                        SizedBox(height: 7.h),
                        // Login or Signup Text
                        Padding(
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Center the children horizontally
                            children: [
                              Expanded(
                                child: Divider(), // Divider on the left
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                // Adjust the padding as needed
                                child: Text(
                                  "Login or Signup",
                                  textAlign: TextAlign.center,
                                  style: appStyle(14, kGray, FontWeight.w400),
                                ),
                              ),
                              Expanded(
                                child: Divider(), // Divider on the right
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              // Indian Flag Symbol
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: kGrayLight),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: kOffWhite),
                                child: Container(
                                  padding:
                                      EdgeInsets.only(left: 4.w, right: 7.w),
                                  // Add padding for spacing around the image
                                  alignment: Alignment.center,
                                  // Center the image within its container
                                  child: Image.asset(
                                    "assets/india.png",
                                    width: 40.w,
                                    height: 40.h,
                                  ),
                                ),
                              ),

                              SizedBox(width: 16.w), // Horizontal Space

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.h),
                                      border: Border.all(color: kGray),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: controller.phoneController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "  Enter your phone number",
                                          prefixText: " ",
                                          prefixStyle: appStyle(
                                              14, kDark, FontWeight.w200)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        CustomGradientButton(
                            text: "Continue",
                            onPress: () {
                              if (controller.phoneController.text.length ==
                                  10) {
                                controller.verifyPhoneNumber();
                              } else {
                                showToastMessage(
                                  "Error",
                                  "Please enter a valid 10-digit number",
                                  Colors.red,
                                );
                              }
                            },
                            h: 45.h,
                            w: 350.w),
                        // SizedBox(height: 20.h),
                        Spacer(),
                        SizedBox(
                          width: 260.w,
                          child: Text(
                              "By Continuing , you agree to our Terms of Service Privacy Policy Content Policy.",
                              textAlign: TextAlign.center,
                              style: appStyle(10, kGray, FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
