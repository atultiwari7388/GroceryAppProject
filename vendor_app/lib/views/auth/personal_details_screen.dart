import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../controllers/profile_controller.dart';
import '../../services/app_services.dart';
import '../../utils/app_style.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        iconTheme: const IconThemeData(color: kPrimary),
        title: Text('Personal Details',
            style: appStyle(20, kDark, FontWeight.w500)),
        elevation: 3,
        centerTitle: true,
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (!controller.isLoading) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    const Text(
                      "What's your name?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: controller.nameController,
                      onChanged: (value) {
                        setState(() {
                          controller.isButtonEnabled = value.isNotEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    const Text(
                      "Enter your Email?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: controller.emailAddressController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          controller.isButtonEnabled = value.isNotEmpty;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () => controller.selectDateOfBirthDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                          ),
                          controller: TextEditingController(
                            text: controller.selectedDateOfBirth == null
                                ? ''
                                : DateFormat('dd/MM/yyyy')
                                    .format(controller.selectedDateOfBirth!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0.h),

                    SizedBox(height: 10.0.h),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                      ),
                      items: [
                        'Male',
                        'Female',
                        'Other',
                        'Prefer not to disclose'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Handle dropdown value change
                      },
                    ),
                    SizedBox(height: 20.0.h),
                    //==================== Rc Image and License Image =======================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildImagePickerSection(
                            hint: "GST Image",
                            onImageSelected: (imageUrl) {
                              controller.gstImage = imageUrl;
                              log("GST Image ${imageUrl.toString()}");
                            },
                            selectedFile: controller.rcFile,
                            onFileChanged: (selectFile) {
                              setState(() {
                                controller.rcFile = selectFile;
                              });
                            },
                            folderName: "Vendors"),
                        buildImagePickerSection(
                            hint: "FSSAI Image",
                            onImageSelected: (imageUrl) {
                              controller.fssaiImage = imageUrl;
                              log("FSSAI Image ${imageUrl.toString()}");
                            },
                            selectedFile: controller.licenseFile,
                            onFileChanged: (selectFile) {
                              setState(() {
                                controller.licenseFile = selectFile;
                              });
                            },
                            folderName: "Vendors"),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // _buildImagePickerSection("License ", _licenseImage),
                    SizedBox(height: 40.h),
                    Container(
                      // color: Colors.white,
                      padding: EdgeInsets.all(8.w),
                      child: controller.isButtonEnabled
                          ? CustomGradientButton(
                              h: 45.h,
                              onPress: () => controller.updateUserProfile(),
                              text: "Done")
                          : Container(
                              height: 45.h,
                              width: 320.w,
                              decoration: BoxDecoration(
                                color: kGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Done",
                                  style: appStyle(16, kDark, FontWeight.w500),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  //===================== upload Image to firebase Storage ==============================

  Widget buildImagePickerSection({
    required String hint,
    required Function(String) onImageSelected,
    File? selectedFile,
    required Function(File) onFileChanged,
    required String folderName,
  }) {
    bool uploading = false;

    return Column(
      children: [
        Text(hint),
        SizedBox(height: 10.h),
        selectedFile == null
            ? Icon(Icons.image, size: 90.h)
            : uploading == true
                ? const CircularProgressIndicator()
                : Image.file(selectedFile, height: 75.h, width: 80.w),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: kSecondary, foregroundColor: kWhite),
          onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? image =
                await _picker.pickImage(source: ImageSource.gallery);

            if (image != null) {
              File selectedImage = File(image.path);
              onFileChanged(selectedImage);

              setState(() {
                uploading = true;
              });

              String imageUrl =
                  await uploadImageToFirebase(selectedImage, folderName);

              setState(() {
                uploading =
                    false; // Set uploading to false when image is uploaded
              });

              onImageSelected(imageUrl); // Save the image URL
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (uploading)
                // ignore: dead_code
                const Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircularProgressIndicator(),
                ),
              Text("Select $hint"),
            ],
          ),
        ),
      ],
    );
  }
}
