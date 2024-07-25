import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../common/dashed_divider.dart';
import '../../../common/reusable_text.dart';
import '../../../constants/constants.dart';
import '../../../utils/toast_msg.dart';
import '../../common/custom_gradient_button.dart';
import '../../services/app_services.dart';
import '../../services/collection_reference.dart';
import '../../utils/app_style.dart';
import '../../utils/generate_otp.dart';

class HistoryScreenItems extends StatefulWidget {
  final String orderId;
  final String location;
  final num totalPrice;
  final String userId;
  final int status;
  final double userLat;
  final double userLong;
  final dynamic orderItems;
  final Function(int) switchTab; // Add this line
  final dynamic orderDate;

  const HistoryScreenItems({
    Key? key,
    required this.orderId,
    required this.location,
    required this.totalPrice,
    required this.userId,
    required this.status,
    required this.userLat,
    required this.userLong,
    required this.orderItems,
    required this.switchTab,
    required this.orderDate,
  }) : super(key: key);

  @override
  State<HistoryScreenItems> createState() => _HistoryScreenItemsState();
}

class _HistoryScreenItemsState extends State<HistoryScreenItems> {
  late GeoPoint venLocation;
  String? venId;
  var logger = Logger();
  double dist = 0.0;
  double venLat = 0.0;
  double venLong = 0.0;
  String vendorName = "";
  String vendorAddress = "";
  String venPhoneNumber = "";

  @override
  void initState() {
    super.initState();
    fetchVendorLocationDetails();
  }

  void fetchVendorLocationDetails() async {
    try {
      venId = currentUId;
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(venId)
          .get();

      // Get the location data as a map from Firestore
      Map<String, dynamic> locationData = vendorSnapshot.get("location");

      // Retrieve latitude and longitude values from the map
      venLat = locationData["latitude"];
      venLong = locationData["longitude"];

      double distance =
          calculateDistance(widget.userLat, widget.userLong, venLat, venLong);

      setState(() {
        dist = distance;
        venLat = locationData["latitude"];
        venLong = locationData["longitude"];
        vendorName = vendorSnapshot["userName"].toString();
        vendorAddress = vendorSnapshot["address"].toString();
        venPhoneNumber = vendorSnapshot["phoneNumber"].toString();
      });
      logger.i(
          "Calculating distance and check if user is within 5 km range  $dist  km");
      logger.i("Vendor Name: $vendorName");
      logger.i("Vendor Lat Long : $venLat $venLong");

      if (dist <= 5) {
        logger.i("User is within 5 km range");
      } else {
        logger.i("User is not within 5 km range");
      }
    } catch (error) {
      if (error is PlatformException &&
          error.code == 'io.grpc.Status.DEADLINE_EXCEEDED') {
        logger.e('Timeout error: $error');
      } else {
        // Handle other types of errors
        logger.e("Error fetching restaurant location: $error");
      }
    }
  }

// Function to calculate distance between two geographical points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers

    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

// Function to check if the user is within 5 km range of the restaurant
  bool isWithin5KmRange(
      double userLat, double userLong, double restLat, double restLong) {
    double distance = calculateDistance(userLat, userLong, restLat, restLong);
    logger.d("Total distance: ${distance}km");
    return distance <= 5;
  }

  @override
  Widget build(BuildContext context) {
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
                  offset: const Offset(0, 3),
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
                        text: widget.orderId,
                        style: appStyle(16, kDark, FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: kDark, size: 28.sp),
                      SizedBox(width: 5.w),
                      SizedBox(
                        width: 220,
                        child: Text(
                          // ignore: unnecessary_null_comparison
                          widget.location != null
                              ? widget.location.split('  ').last
                              : '',
                          maxLines: 2,
                          style: appStyle(14, kDark, FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                        text: "Status:",
                        style: appStyle(14, Colors.green, FontWeight.bold),
                      ),
                      ReusableText(
                        text: getStatusString(widget.status),
                        style: appStyle(
                            14,
                            widget.status == 0
                                ? Colors.orange
                                : widget.status == 1
                                    ? Colors.green
                                    : widget.status == 2
                                        ? Colors.blue
                                        : widget.status == 3
                                            ? Colors.yellow
                                            : widget.status == 4
                                                ? Colors.blue
                                                : widget.status == 5
                                                    ? Colors.green
                                                    : widget.status == -1
                                                        ? Colors.red
                                                        : Colors.black,
                            FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ReusableText(
                    text:
                        "Order Date: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.orderDate)}",
                    style: appStyle(13, kGrayLight, FontWeight.normal),
                  ),
                  SizedBox(height: 20.h),
                  const DashedDivider(),
                  SizedBox(height: 20.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.orderItems.length,
                    itemBuilder: (context, index) {
                      final orderItem = widget.orderItems[index];
                      return Column(
                        children: [
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  orderItem["foodImage"],
                                  width: 40.w,
                                  height: 40.h,
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
                                      style: appStyle(
                                          14, kDark, FontWeight.normal),
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
                                              12, kGray, FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          const DashedDivider(),
                        ],
                      );
                    },
                  ),
                  const DashedDivider(),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                        text: "Total ",
                        style: appStyle(14, kRed, FontWeight.bold),
                      ),
                      ReusableText(
                          text: "₹${widget.totalPrice.round()}",
                          style: appStyle(14, kRed, FontWeight.bold))
                    ],
                  ),
                  SizedBox(height: 20.h),
                  const DashedDivider(),
                  SizedBox(height: 20.h),
                  //======================== when status is 0 For first time to accept the order
                  if (widget.status == 0)
                    Center(
                      child: CustomGradientButton(
                        text: "Confirm",
                        onPress: () => showDeliveryTimeDialog(),
                        h: 35.h,
                        // w: 120.w,
                      ),
                    ),

                  //======================== when status is 1, Waiting for delivery partner to accept the order
                  if (widget.status == 1)
                    Row(
                      children: [
                        const CircularProgressIndicator(color: kSecondary),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 240.w,
                          child: Text("Food is preparing ",
                              maxLines: 2,
                              style: appStyle(15, kSecondary, FontWeight.bold)),
                        )
                      ],
                    ),

                  //======================== when status is 2, Preparing food
                  if (widget.status == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 240.w,
                          child: Text(
                              "* When your Item is ready then tap on the Item is Prepared Button",
                              maxLines: 2,
                              style: appStyle(11, kGray, FontWeight.normal)),
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: CustomGradientButton(
                            text: "Item is Prepared",
                            onPress: () async {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderId)
                                  .update({
                                'status': 3,
                                "time": "0",
                              });

                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(widget.userId)
                                  .collection('history')
                                  .doc(widget.orderId)
                                  .update({
                                "status": 3,
                                "time": "0",
                              });
                            },
                            h: 40.h,
                            // w: 80.w,
                          ),
                        )
                      ],
                    ),
                ],
              ),
            )));
  }

  Future<void> showDeliveryTimeDialog() async {
    final TextEditingController _controller = TextEditingController();
    // bool isButtonDisabled = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Food Preparing Time'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                // isButtonDisabled = value.isEmpty;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Food preparing time in minutes (10)',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(120.w, 42.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                ),
              ),
              onPressed: () {
                String deliveryTime = _controller.text;
                Navigator.of(context).pop();
                _acceptOrder(widget.status, deliveryTime);
              },
              // onPressed: isButtonDisabled
              //     ? null
              //     : () {
              //         String deliveryTime = _controller.text;
              //         Navigator.of(context).pop();
              //         _acceptOrder(widget.status, deliveryTime);
              //       },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _acceptOrder(int status, foodPreparingTime) async {
    try {
      // Update values in the orders collection
      int otp = generateOTP();
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'venId': currentUId.toString(),
        'vendorName': vendorName.toString(),
        "venLocation": vendorAddress,
        "venPhoneNumber": venPhoneNumber.toString(),
        "venLat": venLat,
        "venLong": venLong,
        "otp": otp,
        'status': 1,
        'time': foodPreparingTime.toString(),
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('history')
          .doc(widget.orderId)
          .update({
        'venId': currentUId.toString(),
        'vendorName': vendorName.toString(),
        "venLocation": vendorAddress,
        "venPhoneNumber": venPhoneNumber.toString(),
        "venLat": venLat,
        "venLong": venLong,
        "otp": otp,
        'status': 1,
        'time': foodPreparingTime.toString(),
      });
      widget.switchTab(1);

      // Listen to the stream of the order document to get real-time updates
      final StreamSubscription<DocumentSnapshot> subscription =
          FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId)
              .snapshots()
              .listen((DocumentSnapshot orderSnapshot) {
        if (orderSnapshot.exists) {
          // Update the UI with the new status
          setState(() {
            status = orderSnapshot['status'];
          });
        }
      });

      // Dispose the subscription when the widget is disposed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        subscription.cancel();
      });

      showToastMessage("Success", "Order accepted", Colors.green);
    } catch (error) {
      logger.e("Error accepting order: $error");
    }
  }

  // Future<void> _updateDriverEarnings(double fare, String paymentMode) async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) return;

  //   String driverId = currentUser.uid;

  //   DocumentReference driverRef =
  //       FirebaseFirestore.instance.collection('Drivers').doc(driverId);

  //   DocumentSnapshot driverDoc = await driverRef.get();
  //   if (!driverDoc.exists) return;

  //   Map<String, dynamic> data = driverDoc.data() as Map<String, dynamic>;

  //   // Increment rideComplete count
  //   num rideComplete = (data['orderCompleted'] ?? 0).toDouble();
  //   rideComplete += 1;

  //   // Increment totalRide count
  //   num totalRide = (data['totalOrders'] ?? 0).toDouble();
  //   totalRide += 1;

  //   // Add fare to totalEarning
  //   num totalEarning = (data['totalEarning'] ?? 0.0).toDouble();
  //   totalEarning += fare;

  //   // Update earnings based on payment mode
  //   if (paymentMode == 'cash') {
  //     num offlinePayments = (data['offlinePayments'] ?? 0.0).toDouble();
  //     offlinePayments += fare;

  //     await driverRef.update({
  //       'offlinePayments': offlinePayments,
  //     });
  //   } else if (paymentMode == 'online') {
  //     num onlinePayments = (data['onlinePayments'] ?? 0.0).toDouble();
  //     onlinePayments += fare;

  //     await driverRef.update({
  //       'onlinePayments': onlinePayments,
  //     });
  //   }

  //   // Increment todaysEarning by fare
  //   num todaysEarning = (data['todaysEarning'] ?? 0.0).toDouble();
  //   todaysEarning += fare;

  //   logger.d('Incrementing todaysEarning by $fare');

  //   // Update the driver's document with the new data
  //   await driverRef.update({
  //     'totalEarning': totalEarning,
  //     'todaysEarning': todaysEarning,
  //     'orderCompleted': rideComplete,
  //     'totalOrders': totalRide,
  //   });
  // }
}
