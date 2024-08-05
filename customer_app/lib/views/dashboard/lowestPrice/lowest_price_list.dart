import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/controllers/lowest_price_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'widgets/lowest_price_widget.dart';

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
