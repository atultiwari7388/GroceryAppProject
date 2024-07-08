import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/app_style.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTertiary,
        iconTheme: const IconThemeData(color: kPrimary),
        title: Text('Personal Details',
            style: appStyle(20, kDark, FontWeight.w500)),
        elevation: 3,
        centerTitle: true,
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (!controller.isLoading) {
            return Container(
              color: kWhite,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    const Text(
                      "What's your name?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: controller.nameController,
                      onChanged: (value) {
                        setState(() {
                          controller.isButtonEnabled = value.isNotEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(height: 20.h),
                    const Text(
                      "Enter your email",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: controller.emailAddressController,
                      onChanged: (value) {
                        setState(() {
                          controller.isButtonEnabled = value.isNotEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 40.h),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(8.w),
                      child: controller.isButtonEnabled
                          ? CustomGradientButton(
                              onPress: () => controller.updateUserProfile(),
                              text: "Done")
                          : Container(
                              height: 45.h,
                              width: 320.w,
                              decoration: BoxDecoration(
                                color: kLightWhite,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Done",
                                  style: appStyle(16, kDark, FontWeight.w500),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
