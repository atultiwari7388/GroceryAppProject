import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';



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
