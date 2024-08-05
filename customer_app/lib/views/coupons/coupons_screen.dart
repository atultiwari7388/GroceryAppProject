import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/dashed_divider.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class CouponScreen extends StatelessWidget {
  final Function(String) onCouponSelected;

  CouponScreen({required this.onCouponSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Coupons"),
      ),
      body: Container(
        padding: EdgeInsets.all(12.h),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var couponData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(couponData['couponName'],
                      style: appStyle(17, kDark, FontWeight.normal)),
                  subtitle: Text(
                      "${couponData['discountValue'].toString()} % OFF on minimum purchase ${couponData["minPurchaseAmount"].toString()}",
                      style: appStyle(10, kSecondary, FontWeight.normal)),
                  onTap: () {
                    onCouponSelected(couponData['couponName']);
                    Navigator.of(context).pop();
                  },
                  trailing: Container(
                    height: 35.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          kPrimary,
                          kPrimary,
                          kPrimary,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        onCouponSelected(couponData['couponName']);
                        Navigator.of(context).pop();
                      },
                      child: Text("Apply",
                          style: appStyle(16, kWhite, FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return DashedDivider();
              },
            );
          },
        ),
      ),
    );
  }
}
