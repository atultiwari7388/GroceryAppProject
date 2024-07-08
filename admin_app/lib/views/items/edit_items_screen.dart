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

class EditItemScreen extends StatefulWidget {
  final String itemId;

  const EditItemScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _foodCaloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  String? newDownloadUrl;
  bool _isVeg = false;
  bool _isLowestPrice = false;
  List<XFile> _itemImage = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategoryId;
  late List<CategoryItems> _categories;
  bool _isUploading = false;
  bool _isItemLoading = false;
  bool _isLoadingCategory = false;

  @override
  void initState() {
    super.initState();
    _loadItemData();
    _loadCategory();
  }

  Future<void> _loadItemData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Items')
          .doc(widget.itemId)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          newDownloadUrl = data['image'];
          _titleController.text = data['title'] ?? '';
          _foodCaloriesController.text =
              (data['foodCalories'] as List<dynamic>).join(', ');
          _descriptionController.text = data['description'] ?? '';
          _priceController.text = data['price'].toString();
          _oldPriceController.text = data['oldPrice'].toString();
          _timeController.text = data['time'] ?? '';
          _isVeg = data['isVeg'] ?? false;
          _isLowestPrice = data['isLowestPrice'] ?? false;
          _selectedCategoryId = data['categoryId'];
        });
      }
    } catch (error) {
      log('Failed to load item data: $error');
    }
  }

  Future<void> _loadCategory() async {
    setState(() {
      _isLoadingCategory = true;
    });
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Categories').get();

      setState(() {
        _categories = snapshot.docs
            .map((doc) => CategoryItems.fromSnapshot(doc))
            .toList();
        _isLoadingCategory = false;
        log("Loading Categories $_categories");
      });
    } catch (error) {
      log('Failed to load category: $error');
      setState(() {
        _isLoadingCategory = false;
      });
    }
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
        child: _itemImage.isEmpty
            ? newDownloadUrl != null
            ? Image.network(newDownloadUrl!)
            : const Icon(Icons.image, size: 50, color: Colors.grey)
            : Image.file(File(_itemImage.first.path)),
      ),
    );
  }

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
        backgroundColor: kDark,
        title: Text(
          "Edit Item",
          style: appStyle(18, kSecondary, FontWeight.normal),
        ),
      ),
      body: _isLoadingCategory
          ? const Center(child: CircularProgressIndicator())
          : _isUploading
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
                      text: "Edit Item",
                      style: appStyle(20, kDark, FontWeight.bold))),
              const SizedBox(height: 20),
              const Text(
                'Item Name:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Image:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildImageSection(),
              const SizedBox(height: 20),
              const Text(
                'Food Calories: (Add comma separated)',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _foodCaloriesController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Description:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Sale Price:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _priceController,
              ),
              const SizedBox(height: 20),
              const Text(
                'MRP:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _oldPriceController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Time:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
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
                text: "Edit Item",
                onPress: _updateItem,
                h: 45,
                w: 250,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateItem() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Extract data from form fields and variables
      String title = _titleController.text;
      List<String> foodCalories = _foodCaloriesController.text.split(',');
      String description = _descriptionController.text;
      num price = num.tryParse(_priceController.text) ?? 0;
      num oldPrice = num.tryParse(_oldPriceController.text) ?? 0;
      String time = _timeController.text;
      bool isVeg = _isVeg;
      bool isLowestPrice = _isLowestPrice;

      // Initialize variables for image handling
      String? itemImageUrl = newDownloadUrl ??
          "https://firebasestorage.googleapis.com/v0/b/food-otg-service-app.appspot.com/o/logo.png?alt=media&token=399f53a1-0c82-422a-bd70-4ddb5904ac76";

      // Check if a new image is selected
      if (_itemImage.isNotEmpty) {
        // Upload the new image to Firebase Storage
        final DateTime now = DateTime.now();
        final itemImageFile = File(_itemImage.first.path);
        final itemImageName = 'front_${now.microsecondsSinceEpoch}.jpg';
        final Reference frontStorageRef = FirebaseStorage.instance
            .ref()
            .child('item_images')
            .child("images")
            .child(itemImageName);
        await frontStorageRef.putFile(itemImageFile);
        itemImageUrl = await frontStorageRef.getDownloadURL();
      }

      // Update item data in Firestore
      DocumentReference itemRef =
      FirebaseFirestore.instance.collection('Items').doc(widget.itemId);

      // Update basic item details
      await itemRef.update({
        'title': title,
        'foodCalories': foodCalories.map((calorie) => calorie.trim()).toList(),
        'description': description,
        'price': price,
        'oldPrice': oldPrice,
        'time': time,
        'image': itemImageUrl, // Update image URL if available
        "isVeg": isVeg,
        "isLowestPrice": isLowestPrice,
      });


      setState(() {
        _isUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Close the screen
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

