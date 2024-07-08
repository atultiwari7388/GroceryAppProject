import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/custom_gradient_button.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../models/category.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class AddItemsScreen extends StatefulWidget {
  const AddItemsScreen({Key? key}) : super(key: key);

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _foodCaloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  String? newDownloadUrl;
  bool _isLowestPrice = false;
  bool _isUploading = false;
  bool _isVeg = false;
  String? _selectedCategoryId;
  List<CategoryItems> _categories = [];

  List<XFile> _itemImage = [];
  final ImagePicker _picker = ImagePicker();

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
        child: _itemImage.isEmpty
            ? const Icon(Icons.image, size: 50, color: Colors.grey)
            : Image.file(File(_itemImage.first.path)),
      ),
    );
  }

//========================= Select Image ====================
  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _itemImage = [pickedFile];
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

  Widget _buildCheckboxSection() {
    return CheckboxListTile(
      title: const Text("Is Veg"),
      value: _isVeg,
      onChanged: (value) {
        setState(() {
          _isVeg = value!;
        });
      },
    );
  }

  Widget _buildIsLowestPriceSection() {
    return CheckboxListTile(
      title: const Text("Is Lowest Price"),
      value: _isLowestPrice,
      onChanged: (value) {
        setState(() {
          _isLowestPrice = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kTertiary,
        title: Text(
          "Add Items",
          style: appStyle(18, kWhite, FontWeight.normal),
        ),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: kIsWeb
                    ? const EdgeInsets.only(left: 450, right: 450, top: 50)
                    : const EdgeInsets.only(left: 10, right: 10, top: 10),
                decoration: BoxDecoration(
                  color: kLightWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                        child: ReusableText(
                            text: "Add Item",
                            style: appStyle(20, kDark, FontWeight.bold))),
                    const SizedBox(height: 20),
                    const Text(
                      'Item Name:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _titleController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Image:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    const Text(
                      'Food Calories: (Add comma separated)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _foodCaloriesController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Product Quantity (gm,kg,ml):',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _productQuantityController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sale Price:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _priceController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MRP:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _oldPriceController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Time:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _timeController,
                    ),
                    const SizedBox(height: 20),
                    _buildCheckboxSection(),
                    const SizedBox(height: 20),
                    _buildIsLowestPriceSection(),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    CustomGradientButton(
                      text: "Add Item",
                      onPress: _addItemsToFirebase,
                      h: 45,
                      w: 250,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _addItemsToFirebase() async {
    setState(() {
      _isUploading = true;
    });

    bool isVeg = _isVeg;
    bool isLowestPrice = _isLowestPrice;
    String categoryId = _selectedCategoryId.toString();
    String title = _titleController.text;
    List<String> foodCalories = _foodCaloriesController.text.split(',');
    String description = _descriptionController.text;
    String productQuantity = _productQuantityController.text;
    num price = num.tryParse(_priceController.text) ?? 0;
    num oldPrice = num.tryParse(_oldPriceController.text) ?? 0;
    String time = _timeController.text;
    foodCalories = foodCalories.map((calorie) => calorie.trim()).toList();

    try {
      final DateTime now = DateTime.now();
      final itemImageFile = File(_itemImage.first.path);
      final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
      final Reference frontStorageRef = FirebaseStorage.instance
          .ref()
          .child('item_images')
          .child("images")
          .child(itemImageName);
      await frontStorageRef.putFile(itemImageFile);
      final String itemImageUrl = await frontStorageRef.getDownloadURL();
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('Items').add({
        "title": title,
        "image": itemImageUrl,
        "foodCalories": foodCalories,
        "description": description,
        "price": price,
        "oldPrice": oldPrice,
        "time": time,
        "categoryId": categoryId,
        "productQuantity": productQuantity.toString(),
        "active": true,
        "rating": 4.9,
        "ratingCount": 1,
        'created_at': DateTime.now(),
        "priority": 0,
        "isVeg": isVeg,
        "isLowestPrice": isLowestPrice,
      });

      String docId = docRef.id;
      await docRef.update({
        "docId": docId,
      });
      setState(() {
        _isUploading = false;
      });
      log('Item Added Successfully with ID: $docId');
      showToastMessage("Success", "Item added successfully!", Colors.green);

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      log('Error adding items: ${e.toString()}');
      showToastMessage("Error", "Error adding items! $e", Colors.red);
    }
  }
}
