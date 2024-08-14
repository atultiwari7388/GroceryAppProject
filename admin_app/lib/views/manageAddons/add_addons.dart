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

class AddAddonsScreen extends StatefulWidget {
  const AddAddonsScreen({Key? key}) : super(key: key);

  @override
  State<AddAddonsScreen> createState() => _AddAddonsScreenState();
}

class _AddAddonsScreenState extends State<AddAddonsScreen> {
  // Controller for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isUploading = false;

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
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Enter Addon Name'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _priceController,
                      decoration:
                          const InputDecoration(labelText: 'Enter Addon Price'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Addon",
                      onPress: _AddAddonsScreenToFirebase,
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
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Enter Addon Name'),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                              labelText: 'Enter Addon Price'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        CustomGradientButton(
                          text: "Add Addon",
                          onPress: _AddAddonsScreenToFirebase,
                          h: 45,
                          w: 220,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  void _AddAddonsScreenToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String _addOnName = _nameController.text;
    int addOnPrice = int.tryParse(_priceController.text) ?? 0;
    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('AddOns').add({
        'name': _addOnName,
        'price': addOnPrice,
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
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
