import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../models/category.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class AddSubCategory extends StatefulWidget {
  const AddSubCategory({Key? key}) : super(key: key);

  @override
  State<AddSubCategory> createState() => _AddSubCategoryState();
}

class _AddSubCategoryState extends State<AddSubCategory> {
  // Controller for the text fields
  final TextEditingController _subCategoryNameController =
      TextEditingController();
  // final TextEditingController _imageController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  String? _selectedCategoryId;
  List<CategoryItems> _categories = [];
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
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Categories').get();

      setState(() {
        _categories = snapshot.docs
            .map((doc) => CategoryItems.fromSnapshot(doc))
            .toList();
      });
    } catch (error) {
      log('Failed to load category: $error');
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _subCategoryNameController.dispose();
    // _imageController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kDark,
        title: Text(
          "Add Sub Category",
          style: appStyle(18, kSecondary, FontWeight.normal),
        ),
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: kIsWeb
                    ? EdgeInsets.only(left: 450, right: 450, top: 50)
                    : EdgeInsets.only(left: 10, right: 10, top: 10),
                decoration: BoxDecoration(
                    color: kLightWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kDark)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _subCategoryNameController,
                      decoration:
                          const InputDecoration(labelText: 'Sub Category Name'),
                    ),
                    SizedBox(height: 10),
                    _buildImageSection(),
                    const SizedBox(height: 10),
                    const Text(
                      'Categories:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      hint: const Text('Select Categories'),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value!;
                        });
                      },
                      items: _categories.map((CategoryItems category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _priorityController,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Data",
                      onPress: _addSubCategoryToFirebase,
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

// Inside your _AddSubCategoryState class
  void _addSubCategoryToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String subCategoryName = _subCategoryNameController.text;
    // String imageUrl = _imageController.text;
    int priority = int.tryParse(_priorityController.text) ?? 0;
    String categoryId = _selectedCategoryId.toString();

    try {
      final DateTime now = DateTime.now();
      final itemImageFile = File(_bannerImage.first.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('SubCategoriesImages')
          .child("img")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String subCatImageUrl = await frontStorageRef.getDownloadURL();

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('SubCategories').add({
        'subCatName': subCategoryName,
        'categoryId': categoryId,
        'imageUrl': subCatImageUrl,
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
      // ignore: use_build_context_synchronously
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
