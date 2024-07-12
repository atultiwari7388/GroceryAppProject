import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String? uid;

  DatabaseServices({required this.uid});

//===============reference from user collection====================

  final fireStoreDatabase = FirebaseFirestore.instance.collection("Vendors");

//save user data to firebase

  Future savingUserData(
    String emailAddress,
    String driverName,
    String phoneNumber,
    String profilePicture,
    String gstImage,
    String fssaiImage,
    String male,
    DateTime dob,
  ) async {
    return fireStoreDatabase.doc(uid!).set({
      "uid": uid,
      "email": emailAddress,
      "userName": driverName,
      "phoneNumber": phoneNumber,
      "profilePicture": profilePicture,
      "gstImage": gstImage,
      "gender": male,
      "fssaiImage": fssaiImage,
      "dob": dob,
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