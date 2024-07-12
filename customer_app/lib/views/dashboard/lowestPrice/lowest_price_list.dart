import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/common/reusable_text.dart';
import 'package:customer_app/controllers/lowest_price_controller.dart';
import 'package:customer_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';

class LowestPriceList extends StatefulWidget {
  const LowestPriceList({super.key});

  @override
  State<LowestPriceList> createState() => _LowestPriceListState();
}

class _LowestPriceListState extends State<LowestPriceList> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LowestPriceController());
    return Container(
      height: 221.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.only(left: 0.w, top: 5.h),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Items")
            .orderBy("priority", descending: false)
            .where("active", isEqualTo: true)
            .where("isLowestPrice", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            final catG = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: catG.length,
              itemBuilder: (ctx, i) {
                final catData = catG[i].data();
                return LowestPriceListWidget(
                  lowestPriceController: controller,
                  lowestPrice: catData,
                  index: i,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class LowestPriceListWidget extends StatelessWidget {
  const LowestPriceListWidget({
    super.key,
    required this.lowestPriceController,
    required this.lowestPrice,
    required this.index,
  });

  final LowestPriceController lowestPriceController;
  final dynamic lowestPrice;
  final int index;

  double calculateDiscountPercentage(double oldPrice, double newPrice) {
    if (oldPrice == 0) return 0.0;
    return ((oldPrice - newPrice) / oldPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    num oldPrice = lowestPrice["oldPrice"];
    num price = lowestPrice["price"];
    double discountPercentage =
        calculateDiscountPercentage(oldPrice.toDouble(), price.toDouble());
    return GestureDetector(
      onTap: () {
        lowestPriceController.updateLowestItem = lowestPrice["docId"];
        lowestPriceController.updateLowestTitle = lowestPrice["title"];
        // Navigate to next screen
        // Get.to(
        //   () => CategoryPage(
        //     categoryName: category["categoryName"],
        //     catId: category["docId"],
        //   ),
        //   transition: Transition.fadeIn,
        //   duration: const Duration(milliseconds: 900),
        // );
      },
      child: Container(
        margin: EdgeInsets.only(right: 5.w, left: 8.w),
        padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 5.h),
        width: MediaQuery.of(context).size.width * 0.30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Container(
                //   padding: EdgeInsets.all(5.h),
                //   decoration: BoxDecoration(
                //       border: Border.all(color: kGrayLight),
                //       borderRadius: BorderRadius.circular(12.r)),
                //   height: 110.h,
                //   width: 160.w,
                //   child: Image.network(
                //     lowestPrice["image"],
                //     fit: BoxFit.cover,
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.all(5.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: kGrayLight),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  height: 110.h,
                  width: 160.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      lowestPrice["image"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  top: 0.h,
                  right: 1.w,
                  child: Stack(
                    children: [
                      Container(
                        width: 50.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      Positioned(
                        right: -15.w,
                        bottom: -15.h,
                        child: Transform.rotate(
                          angle: -0.7854, // 45 degrees in radians
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            color: kPrimary,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.w,
                        top: 4.h,
                        child: Text(
                          "${discountPercentage.toStringAsFixed(0)}% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      lowestPrice["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.actor(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "${lowestPrice["productQuantity"]}",
                      style: appStyle(10, kDark, FontWeight.normal)),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Old Price and New Price
                      Column(
                        children: [
                          ReusableText(
                              text: "₹${price.toString()}",
                              style: appStyle(10, kGray, FontWeight.bold)),
                          ReusableText(
                            text: "₹${oldPrice.toString()}",
                            style: appStyle(10, kGray, FontWeight.bold)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                      //Outline add Button
                      Container(
                        height: 29.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: kPrimary),
                        ),
                        child: Center(
                          child: Text("ADD",
                              style: appStyle(14, kPrimary, FontWeight.normal)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
