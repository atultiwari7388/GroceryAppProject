import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../functions/inc_dec.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  dynamic selectedFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.h),
        child: Center(
          child: ReusableText(
              text: "Cart", style: appStyle(20, kPrimary, FontWeight.bold)),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUId)
            .collection("cart")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if cart is empty
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    final food = snapshot.data!.docs[index];
                    final foodId = food.id;
                    // final foodName = food["name"];
                    return buildProductCard(food, foodId);
                  },
                ),
                SizedBox(height: 30.h),
                CustomGradientButton(
                  text: "Proceed to checkout",
                  onPress: () {
                    Get.to(() => const CheckoutScreen());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //================================== Product Card ===================================
  Container buildProductCard(dynamic food, foodId) {
    return Container(
      height: 124.h,
      width: double.maxFinite,
      margin: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 5.h),
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r), color: kWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title , increment and price section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //title and price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                      text: food["foodName"],
                      style: appStyle(16, kDark, FontWeight.normal)),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "₹${food["foodPrice"].toString()}",
                      style: appStyle(13, kDark, FontWeight.bold)),
                ],
              ),
              //increment and decrement button and price as well.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 35.h,
                    // width: 120.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: kPrimary)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 18.sp),
                          onPressed: () {
                            setState(() {
                              if (food["quantity"] > 1) {
                                int newQuantity = food["quantity"] - 1;
                                updateQuantity(
                                    foodId, newQuantity, food["foodPrice"]);
                              } else {
                                showDeleteConfirmationDialog(context, food);
                              }
                            });
                          },
                        ),
                        Text(food["quantity"].toString(),
                            style: appStyle(12, kDark, FontWeight.normal)),
                        IconButton(
                          icon: Icon(Icons.add, size: 18.sp),
                          onPressed: () {
                            setState(() {
                              int newQuantity = food["quantity"] + 1;
                              // updateQuantity(foodId, newQuantity);
                              updateQuantity(
                                  foodId, newQuantity, food["foodPrice"]);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "₹${food["subTotalPrice"].toString()}",
                      style: appStyle(13, kDark, FontWeight.bold)),
                ],
              ),
            ],
          ),
          //food tag section
          SizedBox(
            width: width * 0.7,
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: food["foodCalories"].length,
              itemBuilder: (ctx, i) {
                final tag = food["foodCalories"][i];
                return Container(
                  margin: EdgeInsets.only(right: 5.w),
                  decoration: BoxDecoration(
                      color: kSecondaryLight,
                      borderRadius: BorderRadius.all(Radius.circular(9.r))),
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
          //veg and nonveg section
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
