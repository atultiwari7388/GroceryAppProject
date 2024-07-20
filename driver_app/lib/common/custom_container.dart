import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key, required this.containerContent});

  final Widget containerContent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.95,
      child: ClipRRect(
        // borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(30.r),
        //     bottomRight: Radius.circular(30.r)),
        child: Container(
          width: width,
          color: Colors.transparent,
          child: containerContent,
        ),
      ),
    );
  }
}
