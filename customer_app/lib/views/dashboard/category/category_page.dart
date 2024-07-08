import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../utils/app_style.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage(
      {super.key, required this.categoryName, required this.catId});
  final String categoryName;
  final String catId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kOffWhite,
        title: Text(categoryName,
            style: AppFontStyles.font18Style
                .copyWith(color: kGray, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
