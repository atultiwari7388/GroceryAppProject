import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/constants.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer(
      {super.key, required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.r),
          topRight: Radius.circular(0.r),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/restaurant_bk.png"),
          fit: BoxFit.cover,
          opacity: .7,
        ),
      ),
      child: child,
    );
  }
}
