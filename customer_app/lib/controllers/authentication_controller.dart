import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/views/entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/toast_msg.dart';
import '../views/auth/otp_verification.dart';
import '../views/auth/personal_details_screen.dart';
import '../views/auth/phone_authentication_screen.dart';

class AuthenticationController extends GetxController {
  //create firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String vid = "";
  bool isLoading = false;
  bool isVerification = false;

  //================ check for state auth changes  ================
  Stream<User?> get authChanges => _auth.authStateChanges();

  //================ all the users data ================
  User get user => _auth.currentUser!;

  //crate a function for verify phone

//================old code =======================================

  void verifyPhoneNumber() async {
    try {
      isLoading = true;
      update();
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91${phoneController.text}",
          verificationCompleted: (PhoneAuthCredential credential) async {},
          timeout: const Duration(seconds: 120),
          verificationFailed: (FirebaseAuthException exception) {
            if (exception.code == 'invalid-phone-number') {
              showToastMessage("Error", "Invalid Phone number", Colors.red);
            }
            log(exception.toString());
          },
          codeSent: (String verificationId, int? forcedRespondToken) {
            // showToastMessage("Success", "verified code sent", Colors.green);
            vid = verificationId;
            log(vid);
            isLoading = false;
            update();
            Get.to(
                () => OtpAuthenticationScreen(verificationId: verificationId));
            isLoading = false;
            update();
          },
          codeAutoRetrievalTimeout: (String e) {
            // showToastMessage("Error", e.toString(), Colors.red);
            log("Time out Error $e");

            return;
          });
    } catch (e) {
      isLoading = false;
      update();
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }

  //for sign in
//========================== Old Code ==========================================

  void signInWithPhoneNumber(BuildContext context, String otp) async {
    isVerification = true;
    update();
    final PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(
      verificationId: vid,
      smsCode: otp,
    );
    try {
      //for signIn with credential
      var signInUser = await _auth.signInWithCredential(phoneAuthCredential);

      log(signInUser.toString());

      final User? user = signInUser.user;
      if (user != null) {
        isVerification = false;
        update();
        if (signInUser.additionalUserInfo!.isNewUser) {
          //add the data to firebase or move to complete your profile screen
          Get.offAll(() => const PersonalDetailsScreen(),
              transition: Transition.leftToRightWithFade,
              duration: const Duration(seconds: 2));
        } else {
          final doc =
              await FirebaseFirestore.instance.doc("Users/${user.uid}").get();
          if (doc.exists) {
            if (doc["uid"] == _auth.currentUser!.uid &&
                doc["phoneNumber"] == _auth.currentUser!.phoneNumber) {
              Get.offAll(() => EntryScreen());
            } else {
              Get.offAll(() => const PhoneAuthenticationScreen());
            }
          } else {
            Get.offAll(() => const PhoneAuthenticationScreen());
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        isVerification = false;
        update();
        showToastMessage(
            "Error", "Invalid OTP. Enter correct OTP.", Colors.red);
        await _auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const PhoneAuthenticationScreen()),
              (route) => false);
        });
      }
    }
  }

  //====================== signOut from app =====================
  void signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Get.offAll(() => const PhoneAuthenticationScreen());
    } catch (e) {
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }
}
