import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String? uid;

  DatabaseServices({required this.uid});

//===============reference from user collection====================

  final fireStoreDatabase = FirebaseFirestore.instance.collection("Drivers");

//save user data to firebase

  Future savingUserData(
    String emailAddress,
    String driverName,
    String phoneNumber,
    String profilePicture,
    String license,
    String rc,
    String male,
    DateTime dob,
    DateTime anniversary,
  ) async {
    return fireStoreDatabase.doc(uid!).set({
      "uid": uid,
      "email": emailAddress,
      "userName": driverName,
      "phoneNumber": phoneNumber,
      "profilePicture": profilePicture,
      "license": license,
      "gender": male,
      "rc": rc,
      "dob": dob,
      "anniversary": anniversary,
      "isNotificationOn": true,
      "approved": false,
      "active": false,
      "totalEarning": 0,
      "todaysEarning": 0,
      "orderCompleted": 0,
      "totalOrders": 0,
      "created_at": DateTime.now(),
      "updated_at": DateTime.now(),
    });
  }
}
