import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import "dart:io";
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../services/collection_refrences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  _ProfileDetailsScreenState createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedAnniversary;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool isLoading = false;
  String _selectedGender = "Male";
  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to disclose'
  ];

  File? _image;

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _selectAnniversary(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversary ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedAnniversary) {
      setState(() {
        _selectedAnniversary = picked;
      });
    }
  }

  Future<void> _uploadProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage();
      }
      await FirebaseFirestore.instance
          .collection("Drivers")
          .doc(currentUId)
          .update({
        'userName': _userNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'dob': _selectedDateOfBirth != null
            ? Timestamp.fromDate(_selectedDateOfBirth!)
            : null,
        'anniversary': _selectedAnniversary != null
            ? Timestamp.fromDate(_selectedAnniversary!)
            : null,
        'gender': _selectedGender,
        'profilePicture': imageUrl,
        "updated_at": DateTime.now(),
      }).then((value) {
        Navigator.pop(context);
      });
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    try {
      // Upload image to Firebase Storage
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(currentUId)
          .child('profile_pic.jpg');

      await ref.putFile(_image!);

      // Get download URL
      final String downloadURL = await ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  void _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore
    FirebaseFirestore.instance
        .collection("Drivers")
        .doc(currentUId)
        .get()
        .then((DocumentSnapshot snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      // Update text fields with user data
      _userNameController.text = data['userName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneNumberController.text = data['phoneNumber'] ?? '';
      // Parse date of birth and anniversary
      _selectedDateOfBirth = (data['dob'] as Timestamp?)?.toDate();
      _selectedAnniversary = (data['anniversary'] as Timestamp?)?.toDate();
      // Update gender if valid
      final gender = data['gender'];
      if (_genders.contains(gender)) {
        setState(() {
          _selectedGender = gender;
        });
      }
    }).catchError((error) {
      print("Failed to fetch user data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Drivers")
                  .doc(currentUId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final profilePictureUrl = data['profilePicture'] ?? '';
                _userNameController.text = data['userName'] ?? '';
                _emailController.text = data['email'] ?? '';
                _phoneNumberController.text = data['phoneNumber'] ?? '';
                // _selectedDateOfBirth = (data['dob'] as Timestamp?)?.toDate();
                // _selectedAnniversary = (data['anniversary'] as Timestamp?)?.toDate();

                return data.isNotEmpty
                    ? SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.0.h),
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20.0.r),
                                    ),
                                    padding: EdgeInsets.all(20.0.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // CircleAvatar(
                                        //   radius: 50.r,
                                        //   backgroundImage:
                                        //       AssetImage('assets/india.png'),
                                        // ),
                                        CircleAvatar(
                                          radius: 50.r,
                                          backgroundImage: _image != null
                                              ? FileImage(
                                                  _image!) // Show selected image
                                              : profilePictureUrl.isNotEmpty
                                                  ? NetworkImage(
                                                      profilePictureUrl) // Show Firebase image
                                                  : AssetImage(
                                                          'assets/placeholder_image.png')
                                                      as ImageProvider<Object>,
                                        ),

                                        SizedBox(height: 20.0),
                                        TextFormField(
                                          controller: _userNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Username',
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextFormField(
                                          enabled: false,
                                          controller: _phoneNumberController,
                                          decoration: InputDecoration(
                                            labelText: 'Phone Number',
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextFormField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                          ),
                                        ),
                                        SizedBox(height: 10.0.h),
                                        GestureDetector(
                                          onTap: () =>
                                              _selectDateOfBirth(context),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Date of Birth',
                                              ),
                                              controller: TextEditingController(
                                                text: _selectedDateOfBirth ==
                                                        null
                                                    ? ''
                                                    : DateFormat('dd/MM/yyyy')
                                                        .format(
                                                            _selectedDateOfBirth!),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0.h),
                                        GestureDetector(
                                          onTap: () =>
                                              _selectAnniversary(context),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Anniversary',
                                              ),
                                              controller: TextEditingController(
                                                text: _selectedAnniversary ==
                                                        null
                                                    ? ''
                                                    : DateFormat('dd/MM/yyyy')
                                                        .format(
                                                            _selectedAnniversary!),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0.h),
                                        DropdownButtonFormField<String>(
                                          value: _selectedGender,
                                          decoration: InputDecoration(
                                            labelText: 'Gender',
                                          ),
                                          items: _genders.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedGender = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(height: 20.0.h),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 80.h,
                                    right: 0,
                                    left: 0,
                                    child: CircleAvatar(
                                      backgroundColor: kPrimary,
                                      child: IconButton(
                                        onPressed: () {
                                          _getImage(ImageSource.gallery);
                                          // Implement your upload logic here
                                        },
                                        icon: Icon(Icons.upload),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 80.0.h),
                            ],
                          ),
                        ),
                      )
                    : Center(child: Text("Data Not Found"));
              },
            ),
      bottomSheet: Container(
        margin: EdgeInsets.all(12),
        height: 60.h,
        child: CustomGradientButton(
          text: "Upload Profile",
          onPress: _uploadProfile,
          h: 45.h,
          w: double.maxFinite,
        ),
      ),
    );
  }
}
