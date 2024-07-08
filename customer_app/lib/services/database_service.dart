import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String? uid;

  DatabaseServices({required this.uid});

//===============reference from user collection====================

  final fireStoreDatabase = FirebaseFirestore.instance.collection("Users");

//save user data to firebase

  Future savingUserData(
      String emailAddress,
      String userName,
      String phoneNumber,
      String profilePicture,
      String gender,
      String dob,
      String anniversary) async {
    return fireStoreDatabase.doc(uid!).set({
      "uid": uid,
      "email": emailAddress,
      "userName": userName,
      "phoneNumber": phoneNumber,
      "profilePicture": profilePicture,
      "gender": gender,
      "dob": dob,
      "anniversary": anniversary,
      "isNotificationOn": true,
      "created_at": DateTime.now(),
    });
  }
}
