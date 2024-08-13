import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isNotificationOn = true;
  bool isNotificationInitialized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: appStyle(17, kDark, FontWeight.normal)),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.0.w, right: 20.w, top: 20.w, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableText(
                  text: "Notification Setting",
                  style: appStyle(14, kDark, FontWeight.normal)),
              Switch(
                  value: isNotificationOn,
                  onChanged: isNotificationInitialized
                      ? (value) async {
                          setState(() {
                            isNotificationOn = value;
                          });

                          await FirebaseFirestore.instance
                              .doc("Users/${currentUId}")
                              .update({"isNotificationOn": isNotificationOn});

                          if (isNotificationOn) {
                            showToastMessage("Notification",
                                "Notifications turned on", Colors.green);
                          } else {
                            showToastMessage("Notification",
                                "Notifications turned off", Colors.red);
                          }
                        }
                      : null)
            ],
          ),
        ),
      ),
    );
  }
}
