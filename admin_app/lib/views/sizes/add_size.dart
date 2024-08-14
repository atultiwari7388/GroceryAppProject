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

class AddSize extends StatefulWidget {
  const AddSize({Key? key}) : super(key: key);

  @override
  State<AddSize> createState() => _AddSizeState();
}

class _AddSizeState extends State<AddSize> {
  // Controller for the text fields
  final TextEditingController _sizeNameController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _sizeImage = [];
  bool _isUploading = false;

  //========================= Select Image ====================
  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _sizeImage = [pickedFile];
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _sizeNameController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kTertiary,
        title: Text(
          "Add Size",
          style: appStyle(18, kWhite, FontWeight.normal),
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
                      controller: _sizeNameController,
                      decoration: const InputDecoration(labelText: 'Size Name'),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _inchController,
                      decoration: const InputDecoration(
                          labelText: 'Enter Size Inch(13 inch, 14 inch)'),
                    ),
                    SizedBox(height: 10),
                    _buildImageSection(),
                    SizedBox(height: 10),
                    TextField(
                      controller: _priorityController,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Size",
                      onPress: _AddSizeToFirebase,
                      h: 45,
                      w: 220,
                    )
                  ],
                ),
              ),
            )
          : _isUploading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    decoration: BoxDecoration(
                        color: kLightWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kDark)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _sizeNameController,
                          decoration:
                              const InputDecoration(labelText: 'Size Name'),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _inchController,
                          decoration: const InputDecoration(
                              labelText: 'Enter Size Inch (13,14 inch)'),
                        ),
                        SizedBox(height: 10),
                        _buildImageSection(),
                        SizedBox(height: 10),
                        // TextField(
                        //   controller: _imageController,
                        //   decoration: const InputDecoration(labelText: 'Image URL'),
                        // ),
                        TextField(
                          controller: _priorityController,
                          decoration:
                              const InputDecoration(labelText: 'Priority'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        CustomGradientButton(
                          text: "Add Size Data",
                          onPress: _AddSizeToFirebase,
                          h: 45,
                          w: 120,
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
        child: _sizeImage.isEmpty
            ? const Icon(Icons.image, size: 50, color: Colors.grey)
            : Image.file(File(_sizeImage.first.path)),
      ),
    );
  }

// Inside your _AddSizeState class
  void _AddSizeToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String sizeName = _sizeNameController.text;
    String inch = _inchController.text;
    // String imageUrl = "";
    int priority = int.tryParse(_priorityController.text) ?? 0;

    try {
      final DateTime now = DateTime.now();
      final itemImageFile = File(_sizeImage.first.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('sizeImages')
          .child("img")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String categoryImageUrl = await frontStorageRef.getDownloadURL();

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('sizes').add({
        'title': sizeName,
        'image': categoryImageUrl,
        "inch": inch,
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
      log('Size added successfully with ID: $docId');
      showToastMessage("Success", "Size added successfully!", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      // Handle errors
      log('Error adding size: $e');
      showToastMessage("Error", "Error adding size!", Colors.red);
    }
  }
}
