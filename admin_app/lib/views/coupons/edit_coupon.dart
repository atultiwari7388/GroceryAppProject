import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';

class EditCouponScreen extends StatefulWidget {
  const EditCouponScreen({Key? key, required this.couponId, required this.data})
      : super(key: key);
  final String couponId;
  final Map<String, dynamic> data;

  @override
  State<EditCouponScreen> createState() => _EditCouponScreenState();
}

class _EditCouponScreenState extends State<EditCouponScreen> {
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _discountTypeController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  final TextEditingController _minPurchaseAmountController =
      TextEditingController();
  // final TextEditingController _usageCountController = TextEditingController();
  final TextEditingController _usageLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _couponNameController.text = widget.data["couponName"].toString();
    // _discountTypeController.text = widget.data["discountType"].toString();
    _discountValueController.text = widget.data["discountValue"].toString();
    _minPurchaseAmountController.text =
        widget.data["minPurchaseAmount"].toString();
    _usageLimitController.text = widget.data["usageLimit"].toString();
  }

  void _saveCoupon() async {
    try {
      await FirebaseFirestore.instance
          .collection('coupons')
          .doc(_couponNameController.text)
          .update({
        'couponName': _couponNameController.text,
        // ignore: unrelated_type_equality_checks
        'discountType': "percentage",
        'discountValue': int.parse(_discountValueController.text),
        "enabled": true,
        'minPurchaseAmount': int.parse(_minPurchaseAmountController.text),
        'oneTimeUsePerOrder': true,
        'oneTimeUsePerUser': true,

        'usageLimit': int.parse(_usageLimitController.text),
        "updated_at": DateTime.now(),
      });
      // Success message or navigation to previous screen
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add coupon: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text("Add Coupon")),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(left: 450, right: 450, top: 50),
          decoration: BoxDecoration(
              color: kLightWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDark)),
          child: ListView(
            children: [
              TextFormField(
                controller: _couponNameController,
                decoration: const InputDecoration(labelText: 'Coupon Name'),
              ),

              TextFormField(
                controller: _discountValueController,
                decoration: const InputDecoration(labelText: 'Discount Value'),
              ),
              TextFormField(
                controller: _minPurchaseAmountController,
                decoration:
                    const InputDecoration(labelText: 'Min Purchase Amount'),
              ),
              TextFormField(
                controller: _usageLimitController,
                decoration: const InputDecoration(labelText: 'Usage Limit'),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _saveCoupon,
              //   child: const Text('Save Coupon'),
              // ),
              CustomGradientButton(
                  text: "Update", onPress: () => _saveCoupon(), h: 50, w: 220),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Coupon")),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          decoration: BoxDecoration(
              color: kLightWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDark)),
          child: ListView(
            children: [
              TextFormField(
                controller: _couponNameController,
                decoration: const InputDecoration(labelText: 'Coupon Name'),
              ),

              TextFormField(
                controller: _discountValueController,
                decoration: const InputDecoration(labelText: 'Discount Value'),
              ),
              TextFormField(
                controller: _minPurchaseAmountController,
                decoration:
                    const InputDecoration(labelText: 'Min Purchase Amount'),
              ),
              TextFormField(
                controller: _usageLimitController,
                decoration: const InputDecoration(labelText: 'Usage Limit'),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _saveCoupon,
              //   child: const Text('Save Coupon'),
              // ),
              CustomGradientButton(
                  text: "Update", onPress: () => _saveCoupon(), h: 50, w: 220),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _couponNameController.dispose();
    // _discountTypeController.dispose();
    _discountValueController.dispose();
    _minPurchaseAmountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }
}
