import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vendor_app/services/collection_reference.dart';
import 'package:vendor_app/views/items/add_items_screen.dart';
import 'package:vendor_app/views/items/edit_screen_items.dart';
import '../../common/custom_gradient_button.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import 'package:get/get.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String vendorId = currentUId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: kLightWhite,
        title: ReusableText(
          text: "Items",
          style: appStyle(20, kPrimary, FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kPrimary,
                    kPrimary,
                    kPrimary,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => Get.to(() => const AddItemsScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(120.w, 45.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Add Items",
                    style: appStyle(16, kWhite, FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Items")
                .where("venId", isEqualTo: vendorId)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                final itemsData = snapshot.data!.docs;
                if (itemsData.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Items Found",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemsData.length,
                  itemBuilder: (ctx, index) {
                    final items = itemsData[index];
                    bool active = items["active"];
                    return ItemListTileWidget(
                      food: items,
                      onSwitchChanged: (value) {
                        setState(() {
                          // Update the active state of the item in the list
                          active = value;
                          // Also update the active state in the Firestore document
                          items.reference.update({"active": value});
                        });
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ItemListTileWidget extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const ItemListTileWidget({
    Key? key,
    required this.food,
    required this.onSwitchChanged,
  });

  final dynamic food;
  final ValueChanged<bool> onSwitchChanged;

  @override
  State<ItemListTileWidget> createState() => _ItemListTileWidgetState();
}

class _ItemListTileWidgetState extends State<ItemListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      // clipBehavior: Clip.hardEdge,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          height: 85.h,
          width: width,
          decoration: BoxDecoration(
            color: kTertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Container(
            padding: EdgeInsets.all(4.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 70.h,
                        width: 70.w,
                        child: Image.network(widget.food["image"],
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.only(left: 6.w, bottom: 2.h),
                          color: kGray.withOpacity(0.6),
                          height: 16.h,
                          width: width,
                          child: RatingBarIndicator(
                            rating: widget.food["rating"].toDouble(),
                            itemCount: 5,
                            itemSize: 15.h,
                            itemBuilder: (ctx, i) =>
                                const Icon(Icons.star, color: Colors.amber),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ReusableText(
                        text: widget.food["title"],
                        style: appStyle(11, kDark, FontWeight.w400)),
                    ReusableText(
                        text: "Delivery Time ${widget.food["time"]}",
                        style: appStyle(11, kGray, FontWeight.w400)),
                    SizedBox(
                      width: width * 0.7,
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.food["foodCalories"].length,
                        itemBuilder: (ctx, i) {
                          final tag = widget.food["foodCalories"][i];
                          return Container(
                            margin: EdgeInsets.only(right: 5.w),
                            decoration: BoxDecoration(
                                color: kSecondaryLight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.r))),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(2.h),
                                child: ReusableText(
                                    text: tag,
                                    style: appStyle(8, kGray, FontWeight.w400)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        //Available price
        Positioned(
          right: 70.w,
          top: 10.h,
          child: GestureDetector(
            onTap: () =>
                Get.to(() => EditItemScreen(itemId: widget.food["docId"])),
            child: const CircleAvatar(
              backgroundColor: kLightWhite,
              child: Center(
                child: Icon(Icons.edit, color: kPrimary),
              ),
            ),
          ),
        ),

        Positioned(
          right: 2.w,
          top: 10.h,
          child: Switch(
            value: widget.food["active"],
            onChanged: (value) {
              widget.onSwitchChanged(value);
            },
            activeColor: kPrimary,
            // inactiveThumbColor: kGray,
          ),
        ),
      ],
    );
  }
}
