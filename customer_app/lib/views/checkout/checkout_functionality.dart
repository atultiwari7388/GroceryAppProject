import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/constants.dart';
import '../../services/collection_ref.dart';
import '../../utils/toast_msg.dart';

Future<void> placeOrder(
  String address,
  String name,
  String phoneNumber,
  String payMode,
  String restName,
  double userLatitude,
  double userLongitude,
  // List<dynamic> resId,
  num totalBillAmount,
  num subToTalAmount,
  num gstAmount,
  num discountAmount,
  num discountValue,
  String couponCode,
  String paymentId,
  num delievryCharges,
  num gstAmountPrice,
  String time,
  String venId,
) async {
  try {
    // Fetch cart items
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUId)
        .collection("cart")
        .get();

    // Generate order ID
    final orderId = await generateOrderId();

    // Create a list to store cart items
    List<Map<String, dynamic>> cartItems = [];

    // Populate cart items list
    cartSnapshot.docs.forEach((doc) {
      cartItems.add({
        'foodId': doc['foodId'],
        'selectedSize': doc['selectedSize'],
        'selectedSizePrice': doc['selectedSizePrice'] ?? 0,
        'selectedAddOns': doc['selectedAddOns'],
        'selectedAddOnsPrice': doc['selectedAddOnsPrice'],
        'selectedAllergicIngredients': doc['selectedAllergicIngredients'],
        'foodImage': doc['img'],
        'foodName': doc['foodName'],
        'foodPrice': doc['foodPrice'],
        'totalPrice': doc['totalPrice'],
        'quantity': doc['quantity'],
        'discount': doc['discountAmount'] ?? 0,
        'couponCode': doc['couponCode'] ?? "",
        'time': doc["time"] ?? "10"
      });
    });

    // Save order details to user's history subcollection
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUId)
        .collection("history")
        .doc(orderId.toString())
        .set({
      'orderId': orderId.toString(),
      'userId': currentUId,
      'userName': name,
      'userPhoneNumber': phoneNumber,
      'userDeliveryAddress': address,
      'userLat': userLatitude,
      'userLong': userLongitude,
      'restName': restName,
      'venId': venId.toString(),
      'payMode': payMode,
      'orderItems': cartItems,
      'orderDate': DateTime.now(),
      'status': 0, // Status: 0 indicates order is pending
      "totalBill": totalBillAmount,
      "subTotalBill": subToTalAmount,
      "gstAmount": gstAmount,
      "paymentId": paymentId,
      "discountAmount": discountAmount,
      "discountValue": discountValue,
      'otp': "",
      // "managerId": "",
      "vendorName": "",
      "driverId": "",
      "driverPhoneNumber": "",
      'reviewSubmitted': false,
      "deliveryCharges": delievryCharges,
      "gstAmountPrice": gstAmountPrice,
      "time": time,
      "dDeliveryTime": 10,
    });

    // Save order details to admin-accessible collection
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId.toString())
        .set({
      'orderId': orderId.toString(),
      'userId': currentUId,
      'userName': name,
      'userPhoneNumber': phoneNumber,
      'userDeliveryAddress': address,
      'userLat': userLatitude,
      'userLong': userLongitude,
      'restName': restName,
      'venId': venId.toString(),
      'payMode': payMode,
      'orderItems': cartItems,
      'orderDate': DateTime.now(),
      'status': 0, // Status: 0 indicates order is pending
      'otp': "",
      "totalBill": totalBillAmount,
      "subTotalBill": subToTalAmount,
      "paymentId": paymentId,
      "discountAmount": discountAmount,
      "discountValue": discountValue,
      "vendorName": "",
      "driverId": "",
      "driverPhoneNumber": "",
      'reviewSubmitted': false,
      "deliveryCharges": delievryCharges,
      "gstAmountPrice": gstAmountPrice,
      "gstAmount": gstAmount,
      "time": time,
      "dDeliveryTime": 10,
    });

    // Conditionally store payment information if payMode is online
    if (payMode == "online") {
      await storePaymentInformation(
        orderId: orderId.toString(),
        transactionId: paymentId,
        paymentDate: DateTime.now(),
        amount: totalBillAmount,
      );
    }

    // Delete cart data
    cartSnapshot.docs.forEach((doc) async {
      await doc.reference.delete();
    });

    // Order placed successfully
    showToastMessage("Success", "Order placed successfully!", kSuccess);
    print('Order placed successfully!');
  } catch (e) {
    // Error handling
    print('Failed to place order: $e');
    showToastMessage("Error", "Failed to place order: $e", kRed);
  }
}

Future<void> storePaymentInformation({
  required String orderId,
  required String transactionId,
  required DateTime paymentDate,
  required num amount,
}) async {
  try {
    String docId = FirebaseFirestore.instance.collection('Payments').doc().id;
    String userUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('Payments').doc(docId).set({
      'orderId': orderId,
      'docId': docId,
      'transactionId': transactionId,
      'paymentDate': paymentDate,
      'userUid': userUid,
      "amount": amount,
      "status": 1,
    });

    print("Payment information stored successfully!");
  } catch (e) {
    print("Error storing payment information: $e");
    showToastMessage("Error", "Failed to store payment information: $e", kRed);
  }
}

Future generateOrderId() async {
  // return '#FOTG' +
  //     DateTime.now().millisecondsSinceEpoch.toString().substring(6);
  int newCount = 0;

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentReference counterRef =
        FirebaseFirestore.instance.collection('metadata').doc('bookingCounter');
    DocumentSnapshot snapshot = await transaction.get(counterRef);

    if (!snapshot.exists) {
      throw Exception("Counter doesn't exist");
    }

    newCount = ((snapshot.data()! as Map<String, dynamic>)['count'] as int) + 1;

    // Increment the counter
    transaction.update(
        counterRef, {'count': newCount}); // Update the counter in Firestore
  });

  return "#GOCAPP${newCount.toString().padLeft(5, '0')}"; // Construct the booking ID
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Radius of the earth in kilometers

  // Convert degrees to radians
  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  // Convert latitude and longitude to radians
  lat1 = _degreesToRadians(lat1);
  lat2 = _degreesToRadians(lat2);

  // Haversine formula
  double a =
      pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance;
}

double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
