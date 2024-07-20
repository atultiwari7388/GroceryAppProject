import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:driver_app/utils/app_style.dart';

import '../../constants/constants.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("About Us", style: appStyle(17, kDark, FontWeight.normal)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("settings")
            .doc("aboutUs")
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            final documentData = snap.data!.data() as Map<String, dynamic>;
            final content = documentData["content"];

            return content == null
                ? const Center(child: Text('No Data Found'))
                : Padding(
                    padding: EdgeInsets.all(28.h),
                    child: Text(
                      content,
                      style: appStyle(13, kDark, FontWeight.normal)
                          .copyWith(height: 1.8),
                      // textAlign: TextAlign.l,
                    ),
                  );
          }
          if (snap.hasError) {
            return const Text("Something went wrong");
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Text("Something went wrong");
          }
        },
      ),
      //
      // body: BackgroundContainer(
      //     child: Container(
      //       margin: EdgeInsets.all(12.h),
      //       padding: EdgeInsets.all(12.h),
      //       child: Text(
      //         "Welcome to FOODOTG, your number one source for food. We're dedicated to providing you the very best of food service, with an emphasis on Local Restaurant.  Founded in 2023 by FOODOTG , FoodOTG has come a long way from its beginnings in Punjab. When FoodOTG  first started out, his passion for all in one food services drove them to start their own business.  We hope you enjoy our foods as much as we enjoy offering them to you. If you have any questions or comments, please don't hesitate to contact us....",
      //         style: AppFontStyles.font18Style.copyWith(height: 1.8),
      //         // textAlign: TextAlign.l,
      //       ),
      //     ),
      //     color: kWhite),
    );
  }
}
