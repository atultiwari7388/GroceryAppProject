import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/constants.dart';
import '../../../utils/app_style.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
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
        selectedCategoryId = categories.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_sharp, color: kWhite),
        ),
        title: Text(
          "Categories",
          style: AppFontStyles.font18Style
              .copyWith(color: kWhite, fontWeight: FontWeight.bold),
        ),
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
                        .collection("Items")
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

                            return Container(
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
                                      image: itemData["image"] != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  itemData["image"]),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Title Section
                                  Text(
                                    itemData["title"].toString(),
                                    textAlign: TextAlign.center,
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                  ),
                                ],
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
