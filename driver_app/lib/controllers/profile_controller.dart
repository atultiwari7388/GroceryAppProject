import 'dart:io';
import 'package:driver_app/views/adminReview/admin_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_services.dart';
import '../utils/toast_msg.dart';
import '../views/dashboard/dashboard_screen.dart';

class ProfileController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  File? rcFile;
  File? licenseFile;
  DateTime? selectedDateOfBirth;
  DateTime? selectedAnniversary;
  String rcImage = "";
  String licenseImage = "";
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
        licenseImage,
        rcImage,
        selectedGender,
        selectedDateOfBirth!,
        selectedAnniversary!,
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

  Future<void> selectAnniversaryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedAnniversary ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedAnniversary) {
      selectedAnniversary = picked;
      update();
    }
  }
}
