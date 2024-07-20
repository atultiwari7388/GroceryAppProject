//======================== Otp Verification section =================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/constants/constants.dart';
import 'package:driver_app/utils/toast_msg.dart';
import '../../../utils/app_style.dart';

Future<bool> verifyOTP(BuildContext context, String orderId) async {
  TextEditingController otpController = TextEditingController();
  bool isValid = false;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Otp ', style: appStyle(16, kDark, FontWeight.bold)),
        content: TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration:
              const InputDecoration(labelText: 'Enter OTP', hintText: '****'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: appStyle(16, kRed, FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Verify',
                style: appStyle(15, Colors.green, FontWeight.bold)),
            onPressed: () async {
              DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .get();
              if (rideSnapshot.exists) {
                Map<String, dynamic>? rideData =
                    rideSnapshot.data() as Map<String, dynamic>?;
                String? storedOTP = rideData?['otp'].toString();
                if (storedOTP == otpController.text) {
                  isValid = true;
                  Navigator.of(context).pop();
                } else {
                  showToastMessage("Error", "Invalid OTP", kRed);
                }
              } else {
                showToastMessage("Error", "Ride not found!", kRed);
              }
            },
          ),
        ],
      );
    },
  );
  return isValid;
}
