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

class EditSize extends StatefulWidget {
  const EditSize({Key? key, required this.sizeId, required this.data})
      : super(key: key);
  final String sizeId;
  final Map<String, dynamic> data;

  @override
  State<EditSize> createState() => _EditSizeState();
}

class _EditSizeState extends State<EditSize> {
  // Controller for the text fields
  final TextEditingController _sizeNameController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  String? _currentImageUrl;
  String? _newImageUrl; // Added for tracking the new image URL
  late XFile _catImage = XFile('');
  bool _isUploading = false;
  bool _isuploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _sizeNameController.text = widget.data['title'];
    _priorityController.text = widget.data['priority'].toString();
    _inchController.text = widget.data['inch'].toString();
    _currentImageUrl = widget.data['image'];
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
          "Edit Size",
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
                    _isuploadingImage
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kTertiary),
                            onPressed: _replaceImage,
                            child: Text(_catImage.path.isNotEmpty
                                ? "Image Selected"
                                : "Replace Image"),
                          ),
                    SizedBox(height: 10),
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
                    TextField(
                      controller: _priorityController,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Size",
                      onPress: _updateAddonToFirebase,
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
                        _isuploadingImage
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kTertiary),
                                onPressed: _replaceImage,
                                child: Text(_catImage.path.isNotEmpty
                                    ? "Image Selected"
                                    : "Replace Image"),
                              ),
                        SizedBox(height: 10),
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
                          text: "Update Size Data",
                          onPress: _updateAddonToFirebase,
                          h: 45,
                          w: 120,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

// Inside your _EditSizeState class
  void _updateAddonToFirebase() async {
    String sizeName = _sizeNameController.text;
    String inch = _inchController.text;
    int priority = int.tryParse(_priorityController.text) ?? 0;

    setState(() {
      _isUploading = true;
    });
    try {
      Map<String, dynamic> updateData = {
        'title': sizeName,
        'inches': inch,
        'priority': priority,
        'updated_at': DateTime.now(),
      };

      // If a new image URL is available, add it to the update data
      if (_newImageUrl != null) {
        updateData['image'] = _newImageUrl;
      }

      await FirebaseFirestore.instance
          .collection("sizes")
          .doc(widget.sizeId)
          .update(updateData)
          .then((value) {
        log('Category updated successfully with ID: ${widget.sizeId}');
        showToastMessage(
          "Success",
          "Category Updated successfully!",
          Colors.green,
        );
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      log(e.toString());
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _replaceImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isuploadingImage = true;
      });

      try {
        final DateTime now = DateTime.now();
        final itemImageFile = File(pickedFile.path);
        final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
        final Reference frontStorageRef = FirebaseStorage.instance
            .ref()
            .child('sizeImages')
            .child("img")
            .child(itemImageName);

        await frontStorageRef.putFile(itemImageFile);
        final String categoryImageUrl = await frontStorageRef.getDownloadURL();

        setState(() {
          _catImage = pickedFile; // Store the picked file
          _newImageUrl = categoryImageUrl;
        });
      } catch (e) {
        setState(() {
          _isuploadingImage = false;
        });
        log(e.toString());
        showToastMessage(
          "Error",
          "Failed to upload image. Please try again.",
          Colors.red,
        );
      } finally {
        setState(() {
          _isuploadingImage = false;
        });
      }
    }
  }
}
