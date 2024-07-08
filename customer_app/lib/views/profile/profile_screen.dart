import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/dashed_divider.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';
import '../auth/phone_authentication_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: kWhite)),
        title: ReusableText(
            text: "Profile", style: appStyle(18, kWhite, FontWeight.normal)),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 5.w, right: 5.w),
          padding: EdgeInsets.only(left: 7.w, right: 12.w, top: 7.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 18.h),
              //top card
              GestureDetector(
                  // onTap: () => Get.to(() => ProfileDetailsScreen(),
                  //     transition: Transition.cupertino,
                  //     duration: const Duration(milliseconds: 900)),
                  child: buildTopProfileSection()),
              SizedBox(height: 18.h),

              Container(
                width: double.maxFinite,
                // margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Your Details",
                          style: appStyle(18, kPrimary, FontWeight.normal),
                        ),
                        SizedBox(width: 5.w),
                        Container(width: 30.w, height: 3.h, color: kHoverColor),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const DashedDivider(color: kPrimary),
                    SizedBox(height: 10.h),
                    buildListTile("Your Orders", () {}),
                    // () => Get.to(() => AllOrderHistoryScreen(),
                    //     transition: Transition.cupertino,
                    //     duration: const Duration(milliseconds: 900))),

                    buildListTile("Address Book", () {}),
                    // () => Get.to(
                    //     () => AddressManagementScreen(
                    //         userLat: 0, userLng: 0),
                    //     transition: Transition.cupertino,
                    //     duration: const Duration(milliseconds: 900))),
                    buildListTile("Your Profile", () {}),
                    // () => Get.to(() => ProfileDetailsScreen(),
                    //     transition: Transition.cupertino,
                    //     duration: const Duration(milliseconds: 900))),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.maxFinite,
                // margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Other Details",
                          style: appStyle(18, kPrimary, FontWeight.normal),
                        ),
                        SizedBox(width: 5.w),
                        Container(width: 30.w, height: 3.h, color: kHoverColor),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const DashedDivider(color: kPrimary),
                    SizedBox(height: 10.h),
                    buildListTile("About us", () {}),
                    // () => Get.to(() => AboutUsScreen(),
                    //     transition: Transition.cupertino,
                    //     duration: const Duration(milliseconds: 900))),
                    buildListTile(
                        // ignore: avoid_print
                        "Send Feedback",
                        () => print("Send Feedback")),
                    buildListTile("Privacy", () {}),
                    buildListTile("Notification", () {}),
                    // () => Get.to(() => NotificationScreen(),
                    //     transition: Transition.cupertino,
                    //     duration: const Duration(milliseconds: 900))),

                    buildListTile("Logout", () => signOut(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile buildListTile(String title, void Function() onTap) {
    return ListTile(
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: kGray),
      title: Text(title, style: appStyle(13, kDark, FontWeight.normal)),
      onTap: onTap,
    );
  }

//================================ top Profile section =============================
  Container buildTopProfileSection() {
    return Container(
      height: 120.h,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final profilePictureUrl = data['profilePicture'] ?? '';
          final userName = data['userName'] ?? '';
          final email = data['email'] ?? '';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 33.r,
                backgroundColor: kSecondary,
                child: profilePictureUrl.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0] : '',
                        style: appStyle(20, kWhite, FontWeight.bold),
                      )
                    : CircleAvatar(
                        radius: 33.r,
                        backgroundImage: NetworkImage(profilePictureUrl),
                      ),
              ),
              SizedBox(width: 10.w),
              Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: userName.isNotEmpty ? userName : '',
                      style: appStyle(15, kDark, FontWeight.bold),
                    ),
                    ReusableText(
                      text: email.isNotEmpty ? email : '',
                      style: appStyle(12, kDark, FontWeight.normal),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  //====================== signOut from app =====================
  void signOut(BuildContext context) async {
    try {
      await auth.signOut();
      Get.offAll(() => const PhoneAuthenticationScreen());
    } catch (e) {
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }
}
