import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final String userName;
  final String userNumber;
  final String userDeliveryAddress;
  final String resName;
  final dynamic foodName;
  final dynamic foodPrice;
  final dynamic quantity;
  final String payMode;
  final String couponCode;
  final num discount;
  final String vendorName;
  final status;
  final discountAmountPercentage;
  final discountAmount;
  final gstAmountPercentage;
  final gstAmountPrice;
  final deliveryCharges;
  final subTotalBill;
  final totalPrice;
  final orderDate;
  final otp;

  const OrderDetailsScreen({
    required this.orderId,
    required this.userName,
    required this.userNumber,
    required this.userDeliveryAddress,
    required this.resName,
    required this.foodName,
    required this.foodPrice,
    required this.quantity,
    required this.payMode,
    required this.couponCode,
    required this.discount,
    required this.vendorName,
    required this.status,
    required this.discountAmountPercentage,
    required this.discountAmount,
    required this.gstAmountPercentage,
    required this.gstAmountPrice,
    required this.deliveryCharges,
    required this.subTotalBill,
    required this.totalPrice,
    required this.orderDate,
    required this.otp,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // DateTime parsedOrderDate = DateTime.parse(orderDate);
  // String formattedOrderDate = DateFormat.yMMMd().format(parsedOrderDate);
// Function to calculate subtotal based on food prices and quantities
  num calculateSubtotal(List<num> prices, List<num> quantities) {
    num subtotal = 0;
    for (int i = 0; i < prices.length; i++) {
      subtotal += prices[i] * quantities[i];
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    // Convert foodPrice and quantity to lists if they are not already
    List<num> foodPrices = widget.foodPrice is List
        ? List<num>.from(widget.foodPrice)
        : [widget.foodPrice];
    List<num> quantities = widget.quantity is List
        ? List<num>.from(widget.quantity)
        : [widget.quantity];
    // Calculate subtotal
    num subtotal = calculateSubtotal(foodPrices, quantities);
    final roundfareTotal = roundFare(widget.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Invoice'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.orderId}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'OTP: ${widget.otp.toString()}',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            ReusableText(
              text:
                  "Order Date: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.orderDate)}",
              style: appStyle(13, kGrayLight, FontWeight.normal),
            ),

            SizedBox(height: 10),
            Text('Customer Name: ${widget.userName}'),
            Text('Customer Number: ${widget.userNumber}'),
            Text('Delivery Address: ${widget.userDeliveryAddress}'),
            SizedBox(height: 20),
            Text(
              'Order Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Food: ${widget.foodName.join(", ")}'),
            Text('Price per Item: ${foodPrices.join(", ").toString()}'),
            Text('Quantity: ${quantities.join(", ").toString()}'),
            Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text(
              'Payment Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Payment Mode: ${widget.payMode}'),
            Text('Coupon Code: ${widget.couponCode}'),
            Text('Discount: ₹${widget.discount.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text(
              'Vendor details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Vendor Name: ${widget.vendorName}'),

            // Text('Order Date: ${widget.orderDate}'),
            SizedBox(height: 20),
            Text(
              'Order Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Status : ${getStatusString(widget.status)}"),
            // DashedDivider(),
            Divider(),
            SizedBox(height: 20),
            Column(
              children: [
                reusbaleRowTextWidget("SubTotal :",
                    "₹${widget.subTotalBill.round().toStringAsFixed(2)}"),
                SizedBox(height: 3),
                reusbaleRowTextWidget(
                    "Discounts (${widget.discountAmountPercentage}%) :",
                    "-₹${widget.discountAmount.round().toStringAsFixed(2)}"),
                SizedBox(height: 3),
                reusbaleRowTextWidget("Delivery Charges  :",
                    "₹${widget.deliveryCharges.round().toStringAsFixed(2)}"),
                SizedBox(height: 3),
                reusbaleRowTextWidget("GST(${widget.gstAmountPercentage}%)  :",
                    "₹${widget.gstAmountPrice.round().toStringAsFixed(2)}"),
                SizedBox(height: 5),
                Divider(),
                SizedBox(height: 5),
                reusbaleRowTextWidget("Total Bill  :",
                    "₹${roundfareTotal.round().toStringAsFixed(2)}"),
              ],
            ),

            SizedBox(height: 20),
            Divider(),
            // Add more details as needed
          ],
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
        return "Assigned to Delivery Partner";
      case 3:
        return "Ongoing";
      case 4:
        return "Share Otp";
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
