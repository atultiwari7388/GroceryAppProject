import 'package:customer_app/constants/constants.dart';
import 'package:flutter/material.dart';

class CustomCircleIconButton extends StatelessWidget {
  const CustomCircleIconButton(
      {super.key, required this.icon, required this.onPress});

  final Icon icon;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: kPrimary,
      child: IconButton(
        icon: icon,
        onPressed: onPress,
      ),
    );
  }
}
