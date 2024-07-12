import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor_app/views/adminReview/admin_review_screen.dart';
import '../services/database_services.dart';
import '../utils/toast_msg.dart';

class ProfileController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  File? rcFile;
  File? licenseFile;
  DateTime? selectedDateOfBirth;
  String gstImage = "";
  String fssaiImage = "";
  String selectedGender = "Male";
  bool isButtonEnabled = false;

  void updateUserProfile() async {
    isLoading = true;
    update();
    try {
      await DatabaseServices(uid: auth.currentUser!.uid.toString())
          .savingUserData(
        auth.currentUser!.email ?? emailAddressController.text.toString(),
        auth.currentUser!.displayName ?? nameController.text.toString(),
        auth.currentUser!.phoneNumber ?? phoneNumberController.text.toString(),
        "",
        gstImage,
        fssaiImage,
        selectedGender,
        selectedDateOfBirth!,
      )
          .then((value) async {
        isLoading = false;
        update();
        showToastMessage("Success", "Account created.", Colors.green);
        Get.offAll(() => AdminReviewScreen());
      }).onError((error, stackTrace) {
        isLoading = false;
        update();
        showToastMessage("Error", error.toString(), Colors.red);
      });
    } catch (e) {
      isLoading = false;
      update();
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }

  Future<void> selectDateOfBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateOfBirth) {
      selectedDateOfBirth = picked;
      update();
    }
  }
}
