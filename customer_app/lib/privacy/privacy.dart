import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Privacy", style: appStyle(17, kDark, FontWeight.normal)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("settings")
            .doc("privacy")
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
                      style: AppFontStyles.font18Style.copyWith(height: 1.8),
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
    );
  }
}
