import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/views/dashboard/foodTile/food_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/constants.dart';
import '../../../functions/get_cart_item_count_string.dart';
import '../../../services/collection_ref.dart';
import '../../../utils/app_style.dart';
import '../searchScreen/search_screen.dart';

class AllSubCategoriesScreen extends StatefulWidget {
  const AllSubCategoriesScreen({super.key, required this.subCategoryId});
  final String subCategoryId;

  @override
  _AllSubCategoriesScreenState createState() => _AllSubCategoriesScreenState();
}

class _AllSubCategoriesScreenState extends State<AllSubCategoriesScreen> {
  String? selectedSubCategoryId;
  String? selectedSubCategoryName;

  @override
  void initState() {
    super.initState();
    _setInitialCategory();
  }

  Future<void> _setInitialCategory() async {
    var categories = await FirebaseFirestore.instance
        .collection("SubCategories")
        .orderBy("priority", descending: false)
        .where("active", isEqualTo: true)
        .limit(1)
        .get();

    if (categories.docs.isNotEmpty) {
      setState(() {
        selectedSubCategoryId = widget.subCategoryId;
        selectedSubCategoryName =
            categories.docs.first["subCatName"]; // Set the initial name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: kWhite,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_sharp, color: kDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                      subCategoryName: selectedSubCategoryName ?? '',
                      subCategoryId: selectedSubCategoryId.toString()),
                ),
              );
            },
          ),
          StreamBuilder<int>(
            stream: getCartItemCountStream(currentUId),
            builder: (context, snapshot) {
              int itemCount = snapshot.data ?? 0;
              if (itemCount > 0) {
                return GestureDetector(
                  onTap: () {
                    // Get.to(() => CheckoutScreen());
                  },
                  child: Badge(
                    backgroundColor: kPrimary,
                    textColor: kWhite,
                    label: Text(itemCount.toString()),
                    child: const Icon(AntDesign.shoppingcart, color: kPrimary),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          SizedBox(width: 20.w),
        ],
        title: Text(
          selectedSubCategoryName ?? "Sub-Categories",
          style: AppFontStyles.font18Style
              .copyWith(color: kDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  .collection("SubCategories")
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
                            selectedSubCategoryId = catData["docId"];
                            selectedSubCategoryName = catData["subCatName"];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r)),
                            color: selectedSubCategoryId == catData["docId"]
                                ? kTertiary.withOpacity(0.1)
                                : kWhite,
                          ),
                          margin: EdgeInsets.only(
                              left: 12.w, right: 0.w, top: 12.h, bottom: 12.h),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: kTertiary.withOpacity(0.1),
                                child: Image.network(catData["imageUrl"],
                                    fit: BoxFit.contain),
                              ),
                              SizedBox(width: 5.w),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  catData["subCatName"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyles.font14Style.copyWith(
                                    fontWeight: selectedSubCategoryId ==
                                            catData["docId"]
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
            child: selectedSubCategoryId == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Items")
                        .where("subCategoryId",
                            isEqualTo: selectedSubCategoryId)
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
                        if (items.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 1.7,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Lottie.asset("assets/no-data-found.json",
                                  repeat: true, height: 320.h),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (ctx, index) {
                            final itemDoc = items[index].data();
                            return FoodTileWidget(food: itemDoc);
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

  double calculateDiscountPercentage(double oldPrice, double newPrice) {
    if (oldPrice == 0) return 0.0;
    return ((oldPrice - newPrice) / oldPrice) * 100;
  }
}
