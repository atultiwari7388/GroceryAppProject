import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../utils/app_style.dart';

class AnalysisBoxesWidgets extends StatelessWidget {
  const AnalysisBoxesWidgets(
      {Key? key,
        required this.containerColor,
        required this.firstText,
        required this.secondText,
        required this.icon})
      : super(key: key);

  final Color containerColor;
  final String firstText, secondText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 120,
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          firstText,
                          style: appStyle(16, kLightWhite, FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          secondText,
                          style: appStyle(16, kLightWhite, FontWeight.normal),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 120,
              width: 120,
              child: Center(child: FaIcon(icon, size: 40, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
