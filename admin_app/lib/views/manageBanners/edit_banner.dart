import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/toast_msg.dart';

class EditBannerScreen extends StatefulWidget {
  const EditBannerScreen({
    super.key,
    required this.categoryId,
    required this.data,
  });

  final String categoryId;
  final Map<String, dynamic> data;

  @override
  State<EditBannerScreen> createState() => _EditBannerScreenState();
}

class _EditBannerScreenState extends State<EditBannerScreen> {
  final TextEditingController _bannerNameController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  String? _currentImageUrl;
  String? _newImageUrl; // Added for tracking the new image URL
  late XFile _catImage = XFile('');
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bannerNameController.text = widget.data['title'];
    _priorityController.text = widget.data['priority'].toString();
    _currentImageUrl = widget.data['img'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Banner Screen"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: kIsWeb
              ? const EdgeInsets.only(left: 450, right: 450, top: 50)
              : const EdgeInsets.only(left: 10, right: 10, top: 10),
          decoration: BoxDecoration(
              color: kLightWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDark)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _catImage.path.isNotEmpty
                  ? Image.file(
                      File(_catImage.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      _currentImageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kSecondary),
                onPressed: _replaceImage,
                child: Text(_catImage.path.isNotEmpty
                    ? "Image Selected"
                    : "Replace Image"),
              ),
              TextField(
                controller: _bannerNameController,
                decoration: const InputDecoration(labelText: 'Banner Name'),
              ),
              TextField(
                controller: _priorityController,
                decoration: const InputDecoration(labelText: 'Priority'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              CustomGradientButton(
                text: "Update Banner",
                onPress: _updateCategoryToFirebase,
                h: 45,
                w: 220,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateCategoryToFirebase() async {
    String subCatName = _bannerNameController.text;
    int priority = int.tryParse(_priorityController.text) ?? 0;

    try {
      Map<String, dynamic> updateData = {
        'title': subCatName,
        'priority': priority,
        'updated_at': DateTime.now(),
      };

      // If a new image URL is available, add it to the update data
      if (_newImageUrl != null) {
        updateData['img'] = _newImageUrl;
      }

      await FirebaseFirestore.instance
          .collection("homeSliders")
          .doc(widget.categoryId)
          .update(updateData)
          .then((value) {
        log('Category updated successfully with ID: ${widget.categoryId}');
        showToastMessage(
          "Success",
          "Category Updated successfully!",
          Colors.green,
        );
        Navigator.pop(context);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  // void _updateCategoryToFirebase() async {
  //   String categoryName = _bannerNameController.text;
  //   int priority = int.tryParse(_priorityController.text) ?? 0;
  //
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("homeSliders")
  //         .doc(widget.categoryId)
  //         .update({
  //       'title': categoryName,
  //       'priority': priority,
  //       'updated_at': DateTime.now(),
  //     }).then((value) {
  //       log('Banner added successfully with ID: ${widget.categoryId}');
  //       showToastMessage(
  //           "Success", "Banner Updated successfully!", Colors.green);
  //       Navigator.pop(context);
  //     });
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  void _replaceImage() async {
    final DateTime now = DateTime.now();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final itemImageFile = File(pickedFile.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('BannerImages')
          .child("admin")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String categoryImageUrl = await frontStorageRef.getDownloadURL();

      setState(() {
        _catImage = pickedFile; // Store the picked file
        _newImageUrl = categoryImageUrl;
      });
    }
  }
}
