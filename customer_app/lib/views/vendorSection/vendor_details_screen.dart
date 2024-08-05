import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/views/dashboard/lowestPrice/lowest_price_list.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/constants/constants.dart';
import 'package:customer_app/utils/app_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../../controllers/lowest_price_controller.dart';
import '../../functions/get_cart_item_count_string.dart';
import '../../services/collection_ref.dart';
import '../checkout/checkout_screen.dart';
import '../dashboard/lowestPrice/widgets/lowest_price_widget.dart';

class VendorsDetailsScreen extends StatelessWidget {
  const VendorsDetailsScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  final String vendorId;
  final String vendorName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LowestPriceController());

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kPrimary,
        title: Text(vendorName, style: appStyle(18, kWhite, FontWeight.normal)),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, color: kWhite, size: 28.sp)),
        actions: [
          StreamBuilder<int>(
            stream: getCartItemCountStream(currentUId),
            builder: (context, snapshot) {
              int itemCount = snapshot.data ?? 0;
              if (itemCount > 0) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const CheckoutScreen());
                  },
                  child: Badge(
                    backgroundColor: kWhite,
                    textColor: kPrimary,
                    label: Text(itemCount.toString()),
                    child: const Icon(AntDesign.shoppingcart, color: kWhite),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Items')
            .where('venId', isEqualTo: vendorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          final items = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0, // Space between rows
              childAspectRatio: 0.75, // Adjust this ratio as per your design
            ),
            padding: EdgeInsets.all(10.0), // Overall padding for the grid
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final itemData = items[i].data();
              return Card(
                color: kTertiary.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LowestPriceListWidget(
                          lowestPriceController: controller,
                          lowestPrice: itemData,
                          index: i,
                        ),
                      ),
                      // const Divider(color: Colors.grey, height: 1),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
