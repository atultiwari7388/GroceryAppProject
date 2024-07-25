import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/common/custom_gradient_button.dart';
import 'package:driver_app/constants/constants.dart';
import 'package:driver_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/collection_refrences.dart';

class PayoutModeScreen extends StatefulWidget {
  const PayoutModeScreen({super.key});

  @override
  State<PayoutModeScreen> createState() => _PayoutModeScreenState();
}

class _PayoutModeScreenState extends State<PayoutModeScreen> {
  num totalEarnings = 0.0;
  String selectedPaymentMethod = 'UPI';
  TextEditingController upiController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController withdrawAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTotalEarnings();
  }

  Future<void> _fetchTotalEarnings() async {
    DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(currentUId)
        .get();

    setState(() {
      totalEarnings = driverSnapshot['totalEarning'] ?? 0;
      log("TotalEarnings: " + totalEarnings.toString());
    });
  }

  void _showWithdrawOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Withdraw Amount'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    title: Text('UPI'),
                    value: 'UPI',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Bank Transfer'),
                    value: 'Bank Transfer',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  if (selectedPaymentMethod == 'UPI')
                    TextField(
                      controller: upiController,
                      decoration: InputDecoration(labelText: 'UPI ID'),
                    ),
                  if (selectedPaymentMethod == 'Bank Transfer') ...[
                    TextField(
                      controller: accountNoController,
                      decoration: InputDecoration(labelText: 'Account No.'),
                    ),
                    TextField(
                      controller: bankNameController,
                      decoration: InputDecoration(labelText: 'Bank Name'),
                    ),
                    TextField(
                      controller: accountHolderNameController,
                      decoration:
                          InputDecoration(labelText: 'Account Holder Name'),
                    ),
                    TextField(
                      controller: ifscController,
                      decoration: InputDecoration(labelText: 'IFSC Code'),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  CustomGradientButton(
                    text: "Save",
                    onPress: () => _showWithdrawAmountPopup(),
                    h: 35.h,
                    w: 120.w,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawAmountPopup() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Withdraw Amount'),
          content: TextField(
            controller: withdrawAmountController,
            decoration: InputDecoration(labelText: 'Withdraw Amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: _handleWithdraw,
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleWithdraw() async {
    num withdrawAmount = num.parse(withdrawAmountController.text);
    if (withdrawAmount <= 0 || withdrawAmount > totalEarnings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid amount')),
      );
    } else {
      setState(() {
        totalEarnings -= withdrawAmount;
      });
      Navigator.pop(context);

      // Update driver details
      if (selectedPaymentMethod == 'UPI') {
        await FirebaseFirestore.instance
            .collection('Drivers')
            .doc(currentUId)
            .update({
          'upiId': upiController.text,
        });
      } else if (selectedPaymentMethod == 'Bank Transfer') {
        await FirebaseFirestore.instance
            .collection('Drivers')
            .doc(currentUId)
            .update({
          'accountNo': accountNoController.text,
          'bankName': bankNameController.text,
          'accountHolderName': accountHolderNameController.text,
          'ifscCode': ifscController.text,
        });
      }

      // Create a new payment document
      DocumentReference paymentRefre =
          await FirebaseFirestore.instance.collection('payments').add({
        'withdrawAmount': withdrawAmount,
        'driverId': currentUId,
        'status': 'pending',
        'upiId': upiController.text,
        'date': DateTime.now(),
        'accountNo': accountNoController.text,
        'bankName': bankNameController.text,
        'accountHolderName': accountHolderNameController.text,
        'ifscCode': ifscController.text,
      });

      await paymentRefre
          .update({"docId": paymentRefre.id.toString()}).then((value) async {
        // Create a new payment document
        await FirebaseFirestore.instance
            .collection('Drivers')
            .doc(currentUId)
            .update({
          "withdrawlAmount": withdrawAmount,
          "totalEarning": totalEarnings,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal successful')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payout Mode",
          style: appStyle(18, kWhite, FontWeight.normal),
        ),
        backgroundColor: kPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: kWhite, size: 28.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Earnings: \₹${totalEarnings.toStringAsFixed(2)}',
              style: appStyle(20, Colors.black, FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomSheet: CustomGradientButton(
        text: "Withdraw",
        onPress: () => _showWithdrawOptions(),
        h: 45.h,
        w: double.maxFinite,
      ),
    );
  }
}
