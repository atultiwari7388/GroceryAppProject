import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../common/dashed_divider.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/app_services.dart';
import '../../services/firebase_collection_services.dart';
import '../../utils/app_style.dart';
import 'round_fare.dart';

class AllOrderHistoryScreen extends StatefulWidget {
  const AllOrderHistoryScreen({Key? key});

  @override
  State<AllOrderHistoryScreen> createState() => _AllOrderHistoryScreenState();
}

class _AllOrderHistoryScreenState extends State<AllOrderHistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _ordersStream;
  int _perPage = 10;
  int _currentPage = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _ordersStream = _getOrdersStream();
  }

  Stream<List<DocumentSnapshot>> _getOrdersStream() {
    Query query = FirebaseCollectionServices().allOrdersList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query
          .orderBy("orderId")
          .where("orderId",
              isGreaterThanOrEqualTo: "#${searchController.text.toString()}")
          .where("orderId",
              isLessThanOrEqualTo:
                  "#${searchController.text.toString()}\uf8ff");
    } else {
      query = query.orderBy("orderDate", descending: true);
    }

    // Apply date range filter if both dates are selected
    if (_startDate != null && _endDate != null) {
      query = query
          .where("orderDate", isGreaterThanOrEqualTo: _startDate)
          .where("orderDate",
              isLessThanOrEqualTo:
                  _endDate!.add(const Duration(days: 1))); // include end date
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null &&
        picked !=
            DateTimeRange(
                start: _startDate ?? DateTime.now(),
                end: _endDate ?? DateTime.now())) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _ordersStream = _getOrdersStream(); // Update the stream
      });
    }
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _ordersStream = _getOrdersStream();
      log(_currentPage.toString());
      log(_perPage.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        iconTheme: IconThemeData(color: kWhite),
        title: Text("History", style: appStyle(18, kWhite, FontWeight.normal)),
        actions: [
          IconButton(
              onPressed: () => _selectDateRange(context),
              icon: Icon(Icons.date_range)),
        ],
      ),
      body: Container(
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: _ordersStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final streamData = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: streamData.length,
                      itemBuilder: (context, index) {
                        final cartItem =
                            streamData[index].data() as Map<String, dynamic>;
                        final cartId = cartItem["orderId"];
                        return AllOrderHistoryScreenItems(
                            cartItem: cartItem, cartId: cartId);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: TextButton(
                          onPressed: _loadNextPage,
                          child: const Text("Next"),
                        ),
                      ),
                    ),
                    SizedBox(height: 105.h),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
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
    final managerId = widget.cartItem['managerId'];
    final resIdList = widget.cartItem['restId'];
    final orderTime = DateTime.fromMillisecondsSinceEpoch(
        widget.cartItem['orderDate'].millisecondsSinceEpoch);
    final location = widget.cartItem['userDeliveryAddress'].split(' ').last;
    final status = widget.cartItem['status'];
    final newStatus = AppServices().getStatusString(status);

    final totalPrice = widget.cartItem['totalBill'];
    final otp = widget.cartItem["otp"] ?? "";
    final paymentMode = widget.cartItem['payMode'];
    final driverId = widget.cartItem["driverId"];
    final bool reviewSubmitted = widget.cartItem['reviewSubmitted'] ?? false;
    final roundfareTotal = roundFare(totalPrice);

    final discountAmountPercentage = widget.cartItem['discountValue'];
    final discountAmount = widget.cartItem["discountAmount"];
    final gstAmountPercentage = widget.cartItem["gstAmount"];
    final gstAmountPrice = widget.cartItem["gstAmountPrice"];
    final deliveryCharges = widget.cartItem["deliveryCharges"];
    final subTotalBill = widget.cartItem["subTotalBill"];

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
                  reusbaleRowTextWidget("SubTotal :",
                      "₹${subTotalBill.round().toStringAsFixed(2)}"),
                  SizedBox(height: 3.h),
                  reusbaleRowTextWidget(
                      "Discounts (${discountAmountPercentage}%) :",
                      "-₹${discountAmount.round().toStringAsFixed(2)}"),
                  SizedBox(height: 3.h),
                  reusbaleRowTextWidget("Delivery Charges  :",
                      "₹${deliveryCharges.round().toStringAsFixed(2)}"),
                  SizedBox(height: 3.h),
                  reusbaleRowTextWidget("GST(${gstAmountPercentage}%)  :",
                      "₹${gstAmountPrice.round().toStringAsFixed(2)}"),
                  SizedBox(height: 5.h),
                  DashedDivider(),
                  SizedBox(height: 5.h),
                  reusbaleRowTextWidget("Total Bill  :",
                      "₹${roundfareTotal.round().toStringAsFixed(2)}"),
                ],
              ),
              SizedBox(height: 20.h),
              DashedDivider(),
              SizedBox(height: 20.h),
              if (status == 5 && reviewSubmitted == false)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // showRatingDialog(booking, context);
                        AppServices()
                            .showRatingDialog(orderId, driverId, context);
                      },
                      child: Text("Leave a Rating"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        foregroundColor: kDark,
                      ),
                    ),
                  ],
                ),
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
}
