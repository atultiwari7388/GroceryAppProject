// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:food_otg_driver/services/collection_refrences.dart';
// import 'package:food_otg_driver/utils/toast_msg.dart';
// import '../../common/dashed_divider.dart';
// import '../../common/reusable_text.dart';
// import '../../constants/constants.dart';
// import '../../utils/app_style.dart';

// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   late GeoPoint restaurantLocation;
//   late List<Map<String, dynamic>> newOrders = [];
//   late List<Map<String, dynamic>> ongoingOrders = [];
//   late List<Map<String, dynamic>> completedOrders = [];
//   late TextEditingController searchController;

//   Future<void> filterOrders() async {
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         QuerySnapshot ordersSnapshot =
//             await FirebaseFirestore.instance.collection('orders').get();
//         List<Map<String, dynamic>> orders = ordersSnapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList();

//         newOrders = orders.where((order) => order['status'] == 1).toList();
//         ongoingOrders = orders
//             .where((order) => order['status'] >= 2 && order['status'] <= 4)
//             .toList();
//         completedOrders =
//             orders.where((order) => order['status'] == 5).toList();
//         // cancelledOrders =
//         //     orders.where((order) => order['status'] == -1).toList();

//         setState(() {});
//       }
//     } catch (error) {
//       print("Error filtering orders: $error");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     filterOrders();
//     searchController = TextEditingController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: kLightWhite,
//           title: ReusableText(
//             text: "Orders",
//             style: appStyle(20, kSecondary, FontWeight.bold),
//           ),
//           bottom: TabBar(
//             labelColor: kSecondary,
//             unselectedLabelColor: kGray,
//             tabAlignment: TabAlignment.center,
//             isScrollable: true,
//             labelStyle: appStyle(16, kDark, FontWeight.normal),
//             indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(
//                   width: 2.w, color: kSecondary), // Set your color here
//               insets: EdgeInsets.symmetric(horizontal: 20.w),
//             ),
//             tabs: const [
//               Tab(text: "New"),
//               Tab(text: "Ongoing"),
//               Tab(text: "Complete/Cancel"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildOrdersList(newOrders),
//             _buildOrdersList(ongoingOrders),
//             _buildOrdersList(completedOrders),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
//     // Get the search query from the text controller
//     final searchQuery = searchController.text.toLowerCase();

//     // Filter orders based on orderId containing the search query
//     final filteredOrders = orders.where((order) {
//       final orderId = order["orderId"].toLowerCase();
//       return orderId.contains(searchQuery);
//     }).toList();

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           //filter and search bar section
//           Container(
//             margin: EdgeInsets.only(left: 10, right: 10),
//             child: Row(
//               children: [
//                 Expanded(child: buildTopSearchBar()),
//                 SizedBox(width: 5.w),
//                 FilterChip(
//                     label: Icon(Icons.calendar_month, color: kSecondary),
//                     onSelected: (value) {})
//               ],
//             ),
//           ),

//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: filteredOrders.length,
//             itemBuilder: (ctx, index) {
//               final order = filteredOrders[index];
//               final orderId = order["orderId"];
//               final location = order["userDeliveryAddress"];
//               final imageUrl = order["foodImage"];
//               final productTitle = order["foodName"];
//               final quantity = order["quantity"];
//               final foodPrice = order["foodPrice"];
//               final totalPrice = order["price"];
//               final userId = order["userId"];
//               final status = order["status"];
//               return HistoryScreenItems(
//                 orderId: orderId,
//                 location: location,
//                 imageUrl: imageUrl,
//                 productTitle: productTitle,
//                 quantity: quantity,
//                 totalPrice: totalPrice,
//                 foodPrice: foodPrice,
//                 userId: userId,
//                 status: status,
//               );
//             },
//           ),
//           SizedBox(height: 100.h),
//         ],
//       ),
//     );
//   }

//   /**-------------------------- Build Top Search Bar ----------------------------------**/
//   Widget buildTopSearchBar() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 10.h),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18.h),
//           border: Border.all(color: kGrayLight),
//           boxShadow: [
//             BoxShadow(
//               color: kLightWhite,
//               spreadRadius: 0.2,
//               blurRadius: 1,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: TextFormField(
//           controller: searchController,
//           onChanged: (value) {
//             filterOrders();
//           },
//           decoration: InputDecoration(
//               border: InputBorder.none,
//               hintText: "Search by #FOTG00001",
//               prefixIcon: Icon(Icons.search),
//               prefixStyle: appStyle(14, kDark, FontWeight.w200)),
//         ),
//       ),
//     );
//   }
// }

// class HistoryScreenItems extends StatefulWidget {
//   final String orderId;
//   final String location;
//   final String imageUrl;
//   final String productTitle;
//   final num quantity;
//   final num totalPrice;
//   final num foodPrice;
//   final String userId;
//   final int status;

//   const HistoryScreenItems({
//     Key? key,
//     required this.orderId,
//     required this.location,
//     required this.imageUrl,
//     required this.productTitle,
//     required this.quantity,
//     required this.totalPrice,
//     required this.foodPrice,
//     required this.userId,
//     required this.status,
//   }) : super(key: key);

//   @override
//   State<HistoryScreenItems> createState() => _HistoryScreenItemsState();
// }

// class _HistoryScreenItemsState extends State<HistoryScreenItems> {
//   @override
//   Widget build(BuildContext context) {
//     // final roundedTotalPrice = totalPrice.round() * quantity;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.0.w),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 1.0,
//               blurRadius: .3,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(20.0.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ReusableText(
//                 text: "${widget.orderId}",
//                 style: appStyle(16, kDark, FontWeight.bold),
//               ),
//               SizedBox(height: 3.h),
//               //============== status ===============
//               //  Row(
//               //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //    children: [
//               //      ReusableText(
//               //        text: "Status:",
//               //        style: appStyle(14, Colors.green, FontWeight.bold),
//               //      ),
//               //      DropdownButton<String>(
//               //        value: _selectedStatus,
//               //        onChanged: (newValue) {
//               //          setState(() {
//               //            _selectedStatus = newValue!;
//               //          });
//               //        },
//               //        items: <String>[
//               //          'Accept',
//               //          'Out of Delivery',
//               //          'Delivered',
//               //          'Cancelled'
//               //        ].map<DropdownMenuItem<String>>((String value) {
//               //          return DropdownMenuItem<String>(
//               //            value: value,
//               //            child: Text(value),
//               //          );
//               //        }).toList(),
//               //      ),
//               //    ],
//               //  ),
//               //

//               SizedBox(height: 3.h),
//               Row(
//                 children: [
//                   // Icon(Icons.location_on_outlined,
//                   //     color: Colors.green, size: 28.sp),
//                   // SizedBox(width: 5.w),
//                   // ReusableText(
//                   //   text: "$pikLocation",
//                   //   style: appStyle(14, kDark, FontWeight.normal),
//                   // ),
//                 ],
//               ),
//               SizedBox(height: 3.h),
//               Row(
//                 children: [
//                   Icon(Icons.location_on_outlined, color: kRed, size: 28.sp),
//                   SizedBox(width: 5.w),
//                   SizedBox(
//                     width: 220,
//                     child: Text(
//                       // ignore: unnecessary_null_comparison
//                       "${widget.location != null ? widget.location.split('  ').last : ''}",
//                       maxLines: 2,
//                       style: appStyle(14, kDark, FontWeight.normal),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20.h),
//               DashedDivider(),
//               SizedBox(height: 20.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ReusableText(
//                     text: "Status:",
//                     style: appStyle(14, Colors.green, FontWeight.bold),
//                   ),
//                   ReusableText(
//                     text: getStatusString(widget.status),
//                     style: appStyle(14, Colors.red, FontWeight.bold),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20.h),
//               DashedDivider(),
//               SizedBox(height: 20.h),

//               Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15.0),
//                     child: Image.network(
//                       "${widget.imageUrl}", // Assuming imageUrl is a list
//                       width: 70.w,
//                       height: 70.h,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   SizedBox(width: 20.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${widget.productTitle}",
//                             // Assuming title is a property of the product
//                             style: appStyle(18, kDark, FontWeight.normal)),
//                         SizedBox(height: 5.h),
//                         Row(
//                           children: [
//                             Icon(Icons.shopping_cart,
//                                 color: kGray, size: 20.sp),
//                             SizedBox(width: 5.w),
//                             Text(
//                               "Qty: ${widget.quantity} * ₹${widget.foodPrice.round()}",
//                               style: appStyle(14, kGray, FontWeight.normal),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20.h),
//               DashedDivider(),
//               SizedBox(height: 20.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ReusableText(
//                     text: "Total ",
//                     style: appStyle(14, kRed, FontWeight.bold),
//                   ),
//                   ReusableText(
//                       text: "₹${widget.totalPrice.round()}",
//                       style: appStyle(14, kRed, FontWeight.bold))
//                 ],
//               ),
//               SizedBox(height: 20.h),
//               DashedDivider(),
//               SizedBox(height: 10.h),
//               if (widget.status == 1)
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () => _acceptOrder(),
//                     child: Text(
//                       "Accept",
//                       style: appStyle(16, kWhite, FontWeight.normal),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       minimumSize: Size(220.w, 42.h),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0.r),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Define a function to map numeric status to string status
//   String getStatusString(int status) {
//     switch (status) {
//       case 0:
//         return "Pending";
//       case 1:
//         return "Order Confirmed";
//       case 2:
//         return "Pick up the item";
//       case 3:
//         return "Ongoing";
//       case 4:
//         return "Ask for OTP";
//       case 5:
//         return "Order Delivered";
//       case -1:
//         return "Order Cancelled";
//       // Add more cases as needed for other statuses
//       default:
//         return "Unknown Status";
//     }
//   }

//   void _acceptOrder() async {
//     try {
//       // Update values in the orders collection
//       await FirebaseFirestore.instance
//           .collection('orders')
//           .doc(widget.orderId)
//           .update({
//         'driverId': currentUId,
//         'status': 2,
//       });

//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(widget.userId)
//           .collection('history')
//           .doc(widget.orderId)
//           .update({
//         'driverId': currentUId,
//         'status': 2,
//       });
//       showToastMessage("Success", "Order accepted", Colors.green);
//     } catch (error) {
//       log("Error accepting order: $error");
//     }
//   }
// }
