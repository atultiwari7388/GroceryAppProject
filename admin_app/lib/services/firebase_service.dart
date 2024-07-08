import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/toast_msg.dart';
import '../views/authentication/authentication_screen.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

class FirebaseServices {
  //====================== signOut from app =====================
  void signOut(BuildContext context) async {
    try {
      if (kIsWeb) {
        auth.signOut().then((value) {
          showToastMessage("Logout", "Logout Successfully", Colors.red);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
                  (route) => false);
        });
      } else {
        await auth.signOut().then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
                  (route) => false);
        });
      }
    } catch (e) {
      showToastMessage("Error", e.toString(), Colors.red);
    }
  }
}
