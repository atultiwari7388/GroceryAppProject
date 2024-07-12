import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_style.dart';
import '../constants/constants.dart';
import '../utils/toast_msg.dart';

//========================= Upload image to firebase =========================
Future<String> uploadImageToFirebase(File imageFile, String folderName) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref =
      storage.ref().child("$folderName/${DateTime.now().toString()}.jpg");
  UploadTask uploadTask = ref.putFile(imageFile);

  await uploadTask.whenComplete(() => {});
  String imageUrl = await ref.getDownloadURL();
  return imageUrl;
}

// Define a function to map numeric status to string status
String getStatusString(int status) {
  switch (status) {
    case 0:
      return "Pending";
    case 1:
      return "Order Confirmed";
    case 2:
      return "Pick up the item";
    case 3:
      return "Ongoing";
    case 4:
      return "Wait for Payment";
    case 5:
      return "Order Delivered";
    case -1:
      return "Order Cancelled";
    // Add more cases as needed for other statuses
    default:
      return "Unknown Status";
  }
}

//======================== Otp Verification section =================================
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
