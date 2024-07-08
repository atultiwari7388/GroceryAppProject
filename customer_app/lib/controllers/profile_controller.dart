import 'package:customer_app/views/dashboard/dashboard_screen.dart';
import 'package:customer_app/views/entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../utils/toast_msg.dart';

class ProfileController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController interestController = TextEditingController();

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
        //profilePicture
        "",
        "",
        //dob
        "", //anniversary
      )
          .then((value) async {
        isLoading = false;
        update();
        showToastMessage("Success", "Account created.", Colors.green);
        Get.offAll(() => EntryScreen());
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
}
