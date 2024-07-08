import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../utils/toast_msg.dart';
import '../views/adminHome/admin_home_screen.dart';
import '../views/appSideAdminHome/app_side_admin_home_dashboard.dart';

class AuthenticationController extends GetxController {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

//======================= Sign in With Email and Pass ==================================

  Future<void> loginWithEmailAndPassword() async {
    isLoading = true;
    update();
    try {
      final data = await auth
          .signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString())
          .then((value) {
        final ifUserExists = firebaseFireStore
            .collection("admin")
            .doc(auth.currentUser!.email)
            .get()
            .then((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            if (kIsWeb) {
              Get.off(() => const AdminHomeScreen(),
                  transition: Transition.leftToRightWithFade,
                  duration: const Duration(seconds: 2));
            } else {
              Get.off(() => const AppSideAdminDashBoardScreen(),
                  transition: Transition.leftToRightWithFade,
                  duration: const Duration(seconds: 2));
            }
            log("Login Successfully");
            showToastMessage("Success", "Login Successfully", Colors.green);
            isLoading = false;
            update();
          } else {
            if (auth.currentUser!.email == "adminmylex@gmail.com") {
              log("Welcome  Admin");
              if (kIsWeb) {
                Get.off(() => const AdminHomeScreen(),
                    transition: Transition.leftToRightWithFade,
                    duration: const Duration(seconds: 2));
              } else {
                Get.off(() => const AppSideAdminDashBoardScreen(),
                    transition: Transition.leftToRightWithFade,
                    duration: const Duration(seconds: 2));
              }
              showToastMessage("Success", "Welcome Admin", Colors.green);
              isLoading = false;
              update();
            } else {
              showToastMessage("Error", "Something went wrong", Colors.red);
              isLoading = false;
              update();
            }
          }
        }).onError((error, stackTrace) {
          showToastMessage("Error", error.toString(), Colors.red);
          isLoading = false;
          update();
        });
      }).onError((error, stackTrace) {
        showToastMessage("Error", error.toString(), Colors.red);
        isLoading = false;
        update();
      });
    } catch (e) {
      log(e.toString());
      showToastMessage("Error", e.toString(), Colors.red);
      isLoading = false;
      update();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
