import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/common/reusable_text.dart';
import 'package:customer_app/controllers/lowest_price_controller.dart';
import 'package:customer_app/controllers/trending_store.dart';
import 'package:customer_app/utils/app_style.dart';
import 'package:customer_app/views/vendorSection/vendor_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';
import '../../../functions/add_to_cart.dart';
import '../../../services/collection_ref.dart';
import '../../checkout/checkout_screen.dart';

class TrendingStoreScreenList extends StatefulWidget {
  const TrendingStoreScreenList({super.key});

  @override
  State<TrendingStoreScreenList> createState() =>
      _TrendingStoreScreenListState();
}

class _TrendingStoreScreenListState extends State<TrendingStoreScreenList> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrendingStoreController());
    return Container(
      height: 221.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.only(left: 0.w, top: 5.h),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Vendors")
            .orderBy("priority", descending: false)
            .where("active", isEqualTo: true)
            .where("isTrending", isEqualTo: true)
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
                return TrendingStoreScreenListWidget(
                  trendingStoreController: controller,
                  trendingStore: catData,
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

class TrendingStoreScreenListWidget extends StatefulWidget {
  const TrendingStoreScreenListWidget({
    super.key,
    required this.trendingStoreController,
    required this.trendingStore,
    required this.index,
  });

  final TrendingStoreController trendingStoreController;
  final dynamic trendingStore;
  final int index;

  @override
  State<TrendingStoreScreenListWidget> createState() =>
      _TrendingStoreScreenListWidgetState();
}

class _TrendingStoreScreenListWidgetState
    extends State<TrendingStoreScreenListWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.trendingStoreController.updateLowestItem =
            widget.trendingStore["uid"];
        widget.trendingStoreController.updateLowestTitle =
            widget.trendingStore["userName"];

        // Navigate to next screen
        Get.to(
          () => VendorsDetailsScreen(
            vendorId: widget.trendingStore["uid"],
            vendorName: widget.trendingStore["userName"],
          ),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 900),
        );
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
                      widget.trendingStore["profilePicture"].isEmpty
                          ? "https://firebasestorage.googleapis.com/v0/b/groceryapp-july.appspot.com/o/new_logo_f.png?alt=media&token=a501618a-8e24-4956-9afa-3de0027dcb4c"
                          : widget.trendingStore["profilePicture"],
                      fit: BoxFit.cover,
                    ),
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
                      widget.trendingStore["userName"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.actor(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
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
