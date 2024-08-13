import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';
import '../../../utils/app_style.dart';
import '../subCategory/all_sub_category_screen.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage(
      {super.key, required this.categoryName, required this.catId});
  final String categoryName;
  final String catId;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _setInitialCategory();
  }

  Future<void> _setInitialCategory() async {
    var categories = await FirebaseFirestore.instance
        .collection("Categories")
        .orderBy("priority", descending: false)
        .where("active", isEqualTo: true)
        .limit(1)
        .get();

    if (categories.docs.isNotEmpty) {
      setState(() {
        // selectedCategoryId = categories.docs.first.id;
        selectedCategoryId = widget.catId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kOffWhite,
        title: Text(widget.categoryName,
            style: AppFontStyles.font18Style
                .copyWith(color: kGray, fontWeight: FontWeight.bold)),
      ),
      body: Row(
        children: [
          Container(
            width: 130.w,
            decoration: BoxDecoration(color: kWhite, boxShadow: [
              BoxShadow(
                color: kTertiary.withOpacity(0.1),
                blurRadius: 1,
                spreadRadius: 0.5,
              ),
            ]),
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
                    itemCount: catG.length,
                    itemBuilder: (context, index) {
                      final catData = catG[index].data();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = catData["docId"];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r)),
                            color: selectedCategoryId == catData["docId"]
                                ? kTertiary.withOpacity(0.1)
                                : Colors.white,
                          ),
                          margin: EdgeInsets.only(
                              left: 12.w, right: 0.w, top: 12.h, bottom: 12.h),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: kGrayLight,
                                child: Image.network(catData["imageUrl"],
                                    fit: BoxFit.contain),
                              ),
                              SizedBox(width: 5.w),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  catData["categoryName"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyles.font14Style.copyWith(
                                    fontWeight:
                                        selectedCategoryId == catData["docId"]
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
            child: selectedCategoryId == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("SubCategories")
                        .where("categoryId", isEqualTo: selectedCategoryId)
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
                        final items = snapshot.data!.docs;

                        return GridView.builder(
                          padding: EdgeInsets.all(8.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                            childAspectRatio: 0.76,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final itemData = items[index].data();

                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => AllSubCategoriesScreen(
                                    subCategoryId: itemData["docId"],
                                  ),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 900),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0.r),
                                  color: kTertiary.withOpacity(0.1),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: kLightWhite,
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.all(8.h),
                                padding: EdgeInsets.all(5.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Section
                                    Container(
                                      height: 100.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0.r),
                                        color: kGrayLight,
                                        image: itemData["imageUrl"] != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    itemData["imageUrl"]),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 7.h),
                                    // Title Section
                                    Text(
                                      itemData["subCatName"].toString(),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: appStyle(
                                          12, kDark, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
