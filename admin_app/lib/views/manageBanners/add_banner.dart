import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class AddbBannerScreen extends StatefulWidget {
  const AddbBannerScreen({Key? key}) : super(key: key);

  @override
  State<AddbBannerScreen> createState() => _AddbBannerScreenState();
}

class _AddbBannerScreenState extends State<AddbBannerScreen> {
  // Controller for the text fields
  final TextEditingController _bannerNameController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _bannerImage = [];
  bool _isUploading = false;

  //========================= Select Image ====================
  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _bannerImage = [pickedFile];
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kDark,
        title: Text(
          "Add Banner",
          style: appStyle(18, kSecondary, FontWeight.normal),
        ),
      ),
      body: kIsWeb
          ? SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(left: 450, right: 450, top: 50),
                decoration: BoxDecoration(
                    color: kLightWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kDark)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _bannerNameController,
                      decoration:
                          const InputDecoration(labelText: 'Banner Name'),
                    ),
                    SizedBox(height: 20),
                    _buildImageSection(),
                    SizedBox(height: 20),
                    TextField(
                      controller: _priorityController,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Banner",
                      onPress: _AddbBannerScreenToFirebase,
                      h: 45,
                      w: 220,
                    )
                  ],
                ),
              ),
            )
          : _isUploading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
                    decoration: BoxDecoration(
                        color: kLightWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kDark)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _bannerNameController,
                          decoration:
                              const InputDecoration(labelText: 'Banner Name'),
                        ),
                        SizedBox(height: 20),
                        _buildImageSection(),
                        SizedBox(height: 20),
                        TextField(
                          controller: _priorityController,
                          decoration:
                              const InputDecoration(labelText: 'Priority'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        CustomGradientButton(
                          text: "Add Banner",
                          onPress: _AddbBannerScreenToFirebase,
                          h: 45,
                          w: 220,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _bannerImage.isEmpty
            ? const Icon(Icons.image, size: 50, color: Colors.grey)
            : Image.file(File(_bannerImage.first.path)),
      ),
    );
  }

// Inside your _AddbBannerScreenState class
  // ignore: non_constant_identifier_names
  void _AddbBannerScreenToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String bannerName = _bannerNameController.text;
    int priority = int.tryParse(_priorityController.text) ?? 0;
    try {
      final DateTime now = DateTime.now();
      final itemImageFile = File(_bannerImage.first.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('BannerImages')
          .child("admin")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String bannerImageUrl = await frontStorageRef.getDownloadURL();

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('homeSliders').add({
        'title': bannerName,
        'img': bannerImageUrl.isEmpty
            ? "https://firebasestorage.googleapis.com/v0/b/food-otg-service-app.appspot.com/o/logo.png?alt=media&token=399f53a1-0c82-422a-bd70-4ddb5904ac76"
            : bannerImageUrl,
        'priority': priority,
        "active": true,
        'created_at': DateTime.now(),
      });

      // Get the generated document ID
      String docId = docRef.id;
      await docRef.update({
        "id": docId,
      });
      setState(() {
        _isUploading = false;
      });
      // Show a success message or navigate to a new screen upon successful addition
      log('Category added successfully with ID: $docId');
      showToastMessage("Success", "Category added successfully!", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      FirebaseFirestore.instance.collection("ErrorLogs").doc().set({
        "time": DateTime.now(),
        "Error": "Error Adding Category",
        "code": e.toString(),
      });
      setState(() {
        _isUploading = false;
      });
      // Handle errors
      log('Error adding category: $e');
      showToastMessage("Error", "Error adding category!", Colors.red);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _bannerNameController.dispose();
    // _imageController.dispose();
    _priorityController.dispose();
    super.dispose();
  }
}
