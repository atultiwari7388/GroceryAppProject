// // Method to accept the order and update the status in Firestore
// void _acceptOrder(int status, String foodPreparingTime) async {
//   try {
//     int otp = generateOTP();
//     logger.i("Generated OTP: $otp");

//     // Log the values being used to update Firestore
//     logger.i(
//         "Order update details: venId: $currentUId, vendorName: $vendorName, venLocation: $vendorAddress, venPhoneNumber: $venPhoneNumber, venLat: $venLat, venLong: $venLong, status: 1, time: $foodPreparingTime");

//     await FirebaseFirestore.instance
//         .collection('orders')
//         .doc(widget.orderId)
//         .update({
//       'vendorName': vendorName.toString(),
//       "venLocation": vendorAddress,
//       "venPhoneNumber": venPhoneNumber.toString(),
//       "venLat": venLat,
//       "venLong": venLong,
//       "otp": otp,
//       'status': 1,
//       'time': foodPreparingTime.toString(),
//     }).then((value) async {
//       logger.i("Updating user history for userId: ${widget.userId}");
//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(widget.userId)
//           .collection('history')
//           .doc(widget.orderId)
//           .update({
//         'vendorName': vendorName.toString(),
//         "venLocation": vendorAddress,
//         "venPhoneNumber": venPhoneNumber.toString(),
//         "venLat": venLat,
//         "venLong": venLong,
//         "otp": otp,
//         'status': 1,
//         'time': foodPreparingTime.toString(),
//       }).then((value) async {
//         // Fetch the vendor commission charges
//         Map<String, dynamic>? vendorCharges =
//             await getVendorCommissionCharges();
//         logger.i("Fetched vendorCharges: $vendorCharges");

//         if (vendorCharges != null) {
//           // Get the applicable charge based on the total order value
//           Map<String, dynamic>? applicableCharge =
//               getApplicableCharge(vendorCharges, widget.totalPrice);
//           logger.i(
//               "Applicable charge for order value ${widget.totalPrice}: $applicableCharge");

//           if (applicableCharge != null) {
//             // Ensure the applicable charge is not null before using it
//             final charge = applicableCharge['vendorCharge'] ?? 0;
//             final cTypeCharge = applicableCharge['cType'] ?? 0;
//             // Log the commission details before saving
//             logger.i(
//                 "Saving commission details: orderId: ${widget.orderId}, orderDate: ${widget.orderDate}, userId: ${widget.userId}, venId: $currentUId, venName: $vendorName, venPhoneNumber: $venPhoneNumber, orderValue: ${widget.totalPrice}, charge: $charge");

//             // Save the commission details in adminVendorOrderComission
//             await FirebaseFirestore.instance
//                 .collection('adminVendorOrderComission')
//                 .add({
//               'orderId': widget.orderId,
//               'orderDate': widget.orderDate,
//               'userId': widget.userId,
//               'venId': currentUId,
//               'venName': vendorName,
//               'venPhoneNumber': venPhoneNumber,
//               'orderValue': widget.totalPrice,
//               'vCharge': charge,
//               "vendorCType": cTypeCharge.toString(),
//               'status': 0,
//             });

//             logger.i("Commission details saved successfully");
//           } else {
//             logger.e("No applicable charge found for the order value");
//           }
//         }
//       });
//     });

//     widget.switchTab(1);

//     final StreamSubscription<DocumentSnapshot> subscription = FirebaseFirestore
//         .instance
//         .collection('orders')
//         .doc(widget.orderId)
//         .snapshots()
//         .listen((DocumentSnapshot orderSnapshot) {
//       if (orderSnapshot.exists) {
//         logger.i("Order snapshot updated: ${orderSnapshot.data()}");
//         setState(() {
//           status = orderSnapshot['status'];
//         });
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       subscription.cancel();
//     });

//     showToastMessage("Success", "Order accepted", Colors.green);
//   } catch (error) {
//     logger.e("Error accepting order: $error");
//   }
// }
