import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class EditAddonsScreen extends StatefulWidget {
  const EditAddonsScreen({Key? key, required this.addonId, required this.data})
      : super(key: key);
  final String addonId;
  final Map<String, dynamic> data;

  @override
  State<EditAddonsScreen> createState() => _EditAddonsScreenState();
}

class _EditAddonsScreenState extends State<EditAddonsScreen> {
  // Controller for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = widget.data['name'];
    _priceController.text = widget.data['price'].toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kDark,
        title: Text(
          "Edit Addon",
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
                      text: "Update Addon",
                      onPress: _updateAddonToFirebase,
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
                          text: "Update Addon",
                          onPress: _updateAddonToFirebase,
                          h: 45,
                          w: 220,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  void _updateAddonToFirebase() async {
    setState(() {
      _isUploading = true;
    });
    // Retrieve values from controllers
    String _addOnName = _nameController.text;
    int addOnPrice = int.tryParse(_priceController.text) ?? 0;
    try {
      await FirebaseFirestore.instance
          .collection('AddOns')
          .doc(widget.addonId)
          .update({
        'name': _addOnName,
        'price': addOnPrice,
        'created_at': DateTime.now(),
      });

      setState(() {
        _isUploading = false;
      });
      // Show a success message or navigate to a new screen upon successful addition

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
