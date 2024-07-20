import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:driver_app/common/custom_container.dart';
import 'package:driver_app/common/dashed_divider.dart';
import 'package:driver_app/common/reusable_text.dart';
import 'package:driver_app/services/collection_refrences.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Order History",
            style: appStyle(17, kDark, FontWeight.normal)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: CustomContainer(
        containerContent: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("driverId", isEqualTo: currentUId)
              .where("status", whereIn: [2, 3, 4, 5]).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Check if cart is empty
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Your history is empty'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final cartItem = snapshot.data!.docs[index];
                      final cartId = cartItem["orderId"];
                      return AllOrderHistoryScreenItems(
                          cartItem: cartItem, cartId: cartId);
                    },
                  ),
                  SizedBox(height: 105.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AllOrderHistoryScreenItems extends StatefulWidget {
  final dynamic cartItem;
  final String cartId;

  const AllOrderHistoryScreenItems(
      {Key? key, required this.cartItem, required this.cartId})
      : super(key: key);

  @override
  State<AllOrderHistoryScreenItems> createState() =>
      _AllOrderHistoryScreenItemsState();
}

class _AllOrderHistoryScreenItemsState
    extends State<AllOrderHistoryScreenItems> {
  @override
  Widget build(BuildContext context) {
    final orderId = widget.cartItem['orderId'];
    final orderTime = DateTime.fromMillisecondsSinceEpoch(
        widget.cartItem['orderDate'].millisecondsSinceEpoch);
    final location = widget.cartItem['userDeliveryAddress'].split(' ').last;
    final status = widget.cartItem['status'];
    final newStatus = getStatusString(status);

    final totalPrice = widget.cartItem['totalBill'];
    // final otp = widget.cartItem["otp"] ?? "";
    // final paymentMode = widget.cartItem['payMode'];
    // final driverId = widget.cartItem["driverId"];
    // final bool reviewSubmitted = widget.cartItem['reviewSubmitted'] ?? false;
    final roundfareTotal = roundFare(totalPrice);

    // final discountAmountPercentage = widget.cartItem['discountValue'];
    // final discountAmount = widget.cartItem["discountAmount"];
    // final gstAmountPercentage = widget.cartItem["gstAmount"];
    // final gstAmountPrice = widget.cartItem["gstAmountPrice"];
    // final deliveryCharges = widget.cartItem["deliveryCharges"];
    // final subTotalBill = widget.cartItem["subTotalBill"];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.0.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1.0,
              blurRadius: .3,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(
                    text: "$orderId",
                    style: appStyle(16, kDark, FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: kDark, size: 28.sp),
                      SizedBox(width: 5.w),
                      ReusableText(
                        text: "$location",
                        style: appStyle(14, kRed, FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              ReusableText(
                text: "Status: $newStatus",
                style: appStyle(14, Colors.green, FontWeight.bold),
              ),
              SizedBox(height: 3.h),
              ReusableText(
                text:
                    "Order Time: ${DateFormat('yyyy-MM-dd HH:mm').format(orderTime)}",
                style: appStyle(13, kGrayLight, FontWeight.normal),
              ),
              SizedBox(height: 20.h),
              DashedDivider(),
              SizedBox(height: 20.h),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.cartItem['orderItems'].length,
                itemBuilder: (context, index) {
                  final orderItem = widget.cartItem['orderItems'][index];
                  return Column(
                    children: [
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              orderItem["foodImage"],
                              width: 70.w,
                              height: 70.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderItem['foodName'].toString(),
                                  style: appStyle(18, kDark, FontWeight.normal),
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Icon(Icons.shopping_cart,
                                        color: kGray, size: 20.sp),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "Qty: ${orderItem['quantity']} * ₹${orderItem['foodPrice'].round()} ",
                                      style: appStyle(
                                          14, kGray, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      DashedDivider(),
                    ],
                  );
                },
              ),
              DashedDivider(),
              SizedBox(height: 20.h),
              Column(
                children: [
                  // reusbaleRowTextWidget("SubTotal :",
                  //     "₹${subTotalBill.round().toStringAsFixed(2)}"),
                  SizedBox(height: 3.h),
                  // reusbaleRowTextWidget(
                  //     "Discounts (${discountAmountPercentage}%) :",
                  //     "-₹${discountAmount.round().toStringAsFixed(2)}"),
                  // SizedBox(height: 3.h),
                  // reusbaleRowTextWidget("Delivery Charges  :",
                  //     "₹${deliveryCharges.round().toStringAsFixed(2)}"),
                  // SizedBox(height: 3.h),
                  // reusbaleRowTextWidget("GST(${gstAmountPercentage}%)  :",
                  //     "₹${gstAmountPrice.round().toStringAsFixed(2)}"),
                  // SizedBox(height: 5.h),
                  // DashedDivider(),
                  SizedBox(height: 5.h),
                  reusbaleRowTextWidget("Total Bill  :",
                      "₹${roundfareTotal.round().toStringAsFixed(2)}"),
                ],
              ),
              SizedBox(height: 20.h),
              DashedDivider(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Row reusbaleRowTextWidget(String firstTitle, String secondTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(firstTitle, style: appStyle(14, kDark, FontWeight.normal)),
        Text(secondTitle, style: appStyle(11, kGray, FontWeight.normal)),
      ],
    );
  }

//====================== round fare==============
  double roundFare(double fare) {
    if (fare - fare.floor() >= 0.5) {
      return fare.ceilToDouble();
    } else {
      return fare.floorToDouble();
    }
  }

  // Define a function to map numeric status to string status
  String getStatusString(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Order Confirmed";
      case 2:
        return "Driver Assigned";
      case 3:
        return "Out of delivery";
      case 4:
        return "Collect payment";
      case 5:
        return "Order Delivered";
      case -1:
        return "Order Cancelled";
      // Add more cases as needed for other statuses
      default:
        return "Unknown Status";
    }
  }
}
