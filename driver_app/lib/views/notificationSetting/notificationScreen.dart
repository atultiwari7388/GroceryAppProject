import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:driver_app/services/collection_refrences.dart';
import 'package:driver_app/utils/toast_msg.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool isNotificationOn = true;
  bool isNotificationInitialized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Notification', style: appStyle(17, kDark, FontWeight.normal)),
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
                              .doc("Drivers/${currentUId}")
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
