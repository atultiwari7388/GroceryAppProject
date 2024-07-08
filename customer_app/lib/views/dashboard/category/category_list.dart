import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';
import '../../../controllers/category_controller.dart';
import 'category_page.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    return Container(
      height: 123.h,
      padding: EdgeInsets.only(left: 5.w, top: 10.h),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Categories")
            .orderBy("priority", descending: false)
            .where("active", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            final catG = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: catG.length,
              itemBuilder: (ctx, i) {
                final catData = catG[i].data();
                return CategoryListWidget(
                  categoryController: controller,
                  category: catData,
                  index: i,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({
    super.key,
    required this.categoryController,
    required this.category,
    required this.index,
  });

  final CategoryController categoryController;
  final dynamic category;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        categoryController.updateCategory = category["docId"];
        categoryController.updateCategoryTitle = category["categoryName"];
        // Navigate to next screen
        Get.to(
          () => CategoryPage(
            categoryName: category["categoryName"],
            catId: category["docId"],
          ),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 900),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 5.w, left: 2.w),
        // padding: EdgeInsets.only(top: 4.h),
        width: MediaQuery.of(context).size.width * 0.19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.h),
              decoration: BoxDecoration(
                  border: Border.all(color: kPrimary),
                  borderRadius: BorderRadius.circular(12.r)),
              height: 70.h,
              width: MediaQuery.of(context).size.width * 0.19,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  category["imageUrl"],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              category["categoryName"],
              textAlign: TextAlign.center,
              style: GoogleFonts.actor(
                fontWeight: FontWeight.w100,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
