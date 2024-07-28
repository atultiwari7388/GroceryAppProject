import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:driver_app/utils/app_style.dart';
import 'package:driver_app/views/orders/components/status_string.dart';
import 'package:driver_app/views/orders/components/verify_otp.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../common/dashed_divider.dart';
import '../../../common/reusable_text.dart';
import '../../../constants/constants.dart';
import '../../../services/collection_refrences.dart';
import '../../../utils/toast_msg.dart';

class HistoryScreenItems extends StatefulWidget {
  final String orderId;
  final String location;
  final num totalPrice;
  final String userId;
  final int status;
  final dynamic restaurantLocation;
  final String paymentMode;
  final double userLat;
  final double userLong;
  final dynamic orderItems;
  final Function(int) switchTab;
  final dynamic orderDate;

  const HistoryScreenItems({
    Key? key,
    required this.orderId,
    required this.location,
    required this.totalPrice,
    required this.userId,
    required this.status,
    required this.restaurantLocation,
    required this.paymentMode,
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
  late GeoPoint restLocation;
  String? driverId;
  var logger = Logger();
  double dist = 0.0;
  String phoneNumber = "";
  String driverName = "";

  @override
  void initState() {
    super.initState();
    fetchDriverLocationDetails();
    getDriverCommissionCharges();
  }

  void fetchDriverLocationDetails() async {
    try {
      driverId = currentUId;
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(driverId)
          .get();

      // Get the location data as a map from Firestore
      Map<String, dynamic> locationData = driverSnapshot.get("location");

      // Retrieve latitude and longitude values from the map
      double driverLat = locationData["latitude"];
      double driverLon = locationData["longitude"];

      double distance = calculateDistance(
          widget.userLat, widget.userLong, driverLat, driverLon);

      setState(() {
        dist = distance;
        phoneNumber = driverSnapshot["phoneNumber"];
        driverName = driverSnapshot["userName"];
      });
      logger.i("Calculating distance and check if user is within 5 km range  " +
          dist.toString() +
          "  km");

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
    logger.d("Total distance: " + distance.toString() + "km");
    return distance <= 5;
  }

  Future<Map<String, dynamic>?> getDriverCommissionCharges() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('adminDriverCharges')
          .get();

      if (snapshot.exists) {
        logger.i(snapshot.data());
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      logger.e("Error fetching driver commission charges: $e");
    }
    return null;
  }

  // Function to determine the appropriate charge based on the order value
  Map<String, dynamic>? getApplicableCharge(
      Map<String, dynamic> charges, num orderValue) {
    for (var charge in charges.values) {
      if (orderValue >= charge['orderMinVal'] &&
          orderValue <= charge['orderMaxVal']) {
        return charge;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.0.w),
      child: dist <= 5
          ? Container(
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
                    ReusableText(
                      text: "${widget.orderId}",
                      style: appStyle(16, kDark, FontWeight.bold),
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: Colors.green, size: 28.sp),
                        SizedBox(width: 5.w),
                        SizedBox(
                          width: 220,
                          child: Text(
                            // ignore: unnecessary_null_comparison
                            "${widget.restaurantLocation}",
                            maxLines: 2,
                            style: appStyle(14, kDark, FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: kRed, size: 28.sp),
                        SizedBox(width: 5.w),
                        SizedBox(
                          width: 220,
                          child: Text(
                            // ignore: unnecessary_null_comparison
                            "${widget.location != null ? widget.location.split('  ').last : ''}",
                            maxLines: 2,
                            style: appStyle(14, kDark, FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    DashedDivider(),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReusableText(
                          text: "Status:",
                          style: appStyle(14, Colors.black, FontWeight.bold),
                        ),
                        ReusableText(
                          text: getStatusString(widget.status),
                          style: appStyle(
                              14,
                              widget.status == 1
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

                    DashedDivider(),
                    SizedBox(height: 20.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            DashedDivider(),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
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
                    DashedDivider(),
                    SizedBox(height: 10.h),
                    //====== First time if status is 0 then show accept button
                    if (widget.status == 1)
                      Center(
                        child: ElevatedButton(
                          onPressed: () => showDeliveryTimeDialog(),
                          child: Text(
                            "Accept",
                            style: appStyle(16, kWhite, FontWeight.normal),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: Size(220.w, 42.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                          ),
                        ),
                      ),

                    // if status is 3 then show ask otp button
                    if (widget.status == 3)
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            bool otpVerified =
                                await verifyOTP(context, widget.orderId);
                            if (otpVerified) {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(widget.userId)
                                  .collection('history')
                                  .doc(widget.orderId)
                                  .update({"status": 4});
                              // Update status to 2 in Firestore
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderId)
                                  .update({'status': 4});
                              showToastMessage("Success",
                                  "OTP verified successfully", Colors.green);
                            }
                          },
                          child: Text(
                            "Ask OTP",
                            style: appStyle(16, kWhite, FontWeight.normal),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kRed,
                            foregroundColor: Colors.white,
                            minimumSize: Size(220.w, 42.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                          ),
                        ),
                      ),

                    //if status is 4 then show and ask for payments

//============================= payment section =================================================
                    if (widget.status == 4)
                      if (widget.paymentMode == 'cash')
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(widget.userId)
                                .collection('history')
                                .doc(widget.orderId)
                                .update({
                              "status": 5,
                              "completed_at": DateTime.now(),
                            });
                            // Update status to 4 in Firestore
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(widget.orderId)
                                .update({
                              'status': 5,
                              "completed_at": DateTime.now(),
                            });

                            _updateDriverEarnings(
                              widget.totalPrice.round().toDouble(),
                              widget.paymentMode,
                            );
                            showToastMessage("Success",
                                "Fare collected successfully", Colors.green);
                            // ignore: use_build_context_synchronously
                            // Navigator.of(context).pop();
                          },
                          child: Text('Collect Cash from User',
                              style: appStyle(16, kDark, FontWeight.normal)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kSecondary),
                        ),
                    if (widget.status == 4)
                      if (widget.paymentMode == "online")
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Waiting for Customer Payment',
                              style: appStyle(16, kDark, FontWeight.normal),
                            ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    );
  }

  Future<void> showDeliveryTimeDialog() async {
    final TextEditingController _controller = TextEditingController(text: "10");
    // bool isButtonDisabled = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Delivery Time'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                // isButtonDisabled = value.isEmpty;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Delivery Time in minutes (10)',
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
                _acceptOrder(deliveryTime);
              },
              // onPressed: isButtonDisabled
              //     ? null
              //     : () {
              //         String deliveryTime = _controller.text;
              //         Navigator.of(context).pop();
              //         _acceptOrder(deliveryTime);
              //       },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _acceptOrder(deliveryTime) async {
    try {
      // Update values in the orders collection
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'dDeliveryTime': int.parse(deliveryTime),
        'driverId': currentUId,
        "driverPhoneNumber": phoneNumber.toString(),
        "dName": driverName.toString(),
        'status': 2,
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection('history')
            .doc(widget.orderId)
            .update({
          'dDeliveryTime': int.parse(deliveryTime),
          'driverId': currentUId,
          "driverPhoneNumber": phoneNumber.toString(),
          "dName": driverName.toString(),
          'status': 2,
        }).then((value) async {
          // Fetch the vendor commission charges
          Map<String, dynamic>? driverCharges =
              await getDriverCommissionCharges();
          logger.i("Fetched driverCharges: $driverCharges");

          if (driverCharges != null) {
            // Get the applicable charge based on the total order value
            Map<String, dynamic>? applicableCharge =
                getApplicableCharge(driverCharges, widget.totalPrice);
            logger.i(
                "Applicable charge for order value ${widget.totalPrice}: $applicableCharge");

            if (applicableCharge != null) {
              // Ensure the applicable charge is not null before using it
              final charge = applicableCharge['driverCharge'] ?? 0;

              // Log the commission details before saving

              // Save the commission details in adminVendorOrderComission
              await FirebaseFirestore.instance
                  .collection('adminDriverOrderComission')
                  .add({
                'orderId': widget.orderId,
                'orderDate': widget.orderDate,
                'userId': widget.userId,
                'dId': currentUId,
                'dName': driverName.toString(),
                'dPhoneNumber': phoneNumber.toString(),
                'orderValue': widget.totalPrice,
                'dCharge': charge,
                "driverCType": "Rs",
                'status': 0,
              });

              logger.i("Commission details saved successfully");
            } else {
              logger.e("No applicable charge found for the order value");
            }
          }
        });

        showToastMessage("Success", "Order accepted", Colors.green);
      });

      widget.switchTab(1);
    } catch (error) {
      logger.e("Error accepting order: $error");
    }
  }

  Future<void> _updateDriverEarnings(double fare, String paymentMode) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String driverId = currentUser.uid;

    DocumentReference driverRef =
        FirebaseFirestore.instance.collection('Drivers').doc(driverId);

    DocumentSnapshot driverDoc = await driverRef.get();
    if (!driverDoc.exists) return;

    Map<String, dynamic> data = driverDoc.data() as Map<String, dynamic>;

    // Increment rideComplete count
    num rideComplete = (data['orderCompleted'] ?? 0).toDouble();
    rideComplete += 1;

    // Increment totalRide count
    num totalRide = (data['totalOrders'] ?? 0).toDouble();
    totalRide += 1;

    // Add fare to totalEarning
    num totalEarning = (data['totalEarning'] ?? 0.0).toDouble();
    totalEarning += fare;

    // Update earnings based on payment mode
    if (paymentMode == 'cash') {
      num offlinePayments = (data['offlinePayments'] ?? 0.0).toDouble();
      offlinePayments += fare;

      await driverRef.update({
        'offlinePayments': offlinePayments,
      });
    } else if (paymentMode == 'online') {
      num onlinePayments = (data['onlinePayments'] ?? 0.0).toDouble();
      onlinePayments += fare;

      await driverRef.update({
        'onlinePayments': onlinePayments,
      });
    }

    // Increment todaysEarning by fare
    num todaysEarning = (data['todaysEarning'] ?? 0.0).toDouble();
    todaysEarning += fare;

    logger.d('Incrementing todaysEarning by $fare');

    // Update the driver's document with the new data
    await driverRef.update({
      'totalEarning': totalEarning,
      'todaysEarning': todaysEarning,
      'orderCompleted': rideComplete,
      'totalOrders': totalRide,
    });
  }
}
