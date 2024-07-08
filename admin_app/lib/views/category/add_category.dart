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

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  // Controller for the text fields
  final TextEditingController _categoryNameController = TextEditingController();
  // final TextEditingController _imageController = TextEditingController();
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
  void dispose() {
    // Clean up the controller when the widget is disposed
    _categoryNameController.dispose();
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
          "Add Category",
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
                controller: _categoryNameController,
                decoration:
                const InputDecoration(labelText: 'Category Name'),
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
                text: "Add Category",
                onPress: _addCategoryToFirebase,
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
                controller: _categoryNameController,
                decoration:
                const InputDecoration(labelText: 'Category Name'),
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
                text: "Add Category",
                onPress: _addCategoryToFirebase,
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
        child: _bannerImage.isEmpty
            ? const Icon(Icons.image, size: 50, color: Colors.grey)
            : Image.file(File(_bannerImage.first.path)),
      ),
    );
  }

// Inside your _AddCategoryState class
  void _addCategoryToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String categoryName = _categoryNameController.text;
    // String imageUrl = "";
    int priority = int.tryParse(_priorityController.text) ?? 0;

    try {
      final DateTime now = DateTime.now();
      final itemImageFile = File(_bannerImage.first.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('CategoriesImages')
          .child("img")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String categoryImageUrl = await frontStorageRef.getDownloadURL();

      DocumentReference docRef =
      await FirebaseFirestore.instance.collection('Categories').add({
        'categoryName': categoryName,
        'imageUrl': categoryImageUrl,
        'priority': priority,
        "active": true,
        'created_at': DateTime.now(),
      });

      // Get the generated document ID
      String docId = docRef.id;
      await docRef.update({
        "docId": docId,
      });
      setState(() {
        _isUploading = false;
      });

      // Show a success message or navigate to a new screen upon successful addition
      log('Category added successfully with ID: $docId');
      showToastMessage("Success", "Category added successfully!", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      // Handle errors
      log('Error adding category: $e');
      showToastMessage("Error", "Error adding category!", Colors.red);
    }
  }
}
