import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/common/reusable_text.dart';
import 'package:customer_app/controllers/lowest_price_controller.dart';
import 'package:customer_app/utils/app_style.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../common/custom_circle_icon_button.dart';
import '../../../../common/dashed_divider.dart';
import '../../../../constants/constants.dart';
import '../../../../functions/add_to_cart.dart';
import '../../../../services/collection_ref.dart';
import '../../../checkout/checkout_screen.dart';
import '../../../vendorSection/vendor_details_screen.dart';

class LowestPriceListWidget extends StatefulWidget {
  const LowestPriceListWidget({
    super.key,
    required this.lowestPriceController,
    required this.lowestPrice,
    required this.index,
  });

  final LowestPriceController lowestPriceController;
  final dynamic lowestPrice;
  final int index;

  @override
  State<LowestPriceListWidget> createState() => _LowestPriceListWidgetState();
}

class _LowestPriceListWidgetState extends State<LowestPriceListWidget> {
  int _selectedSizeIndex = -1;
  Set<String> _selectedAddOns = {};
  Set<String> _selectedAllergicOns = {};

  int get selectedSizeIndex => _selectedSizeIndex;

  Set<String> get selectedAddOns => _selectedAddOns;

  Set<String> get selectedAllergicOns => _selectedAllergicOns;
  String? selectedSizeName;
  double? selectedSizePrice;

  // num? selectedAddOnPrice;

  Map<String, num> selectedAddOnPrices = {};
  double totalPrice = 0.0;
  double? addOnPrice;
  double finalPrice = 0.0;

  set selectedSizeIndex(int index) {
    _selectedSizeIndex = index;
    setState(() {});
  }

  List<dynamic> cartItems = [];

  double calculateDiscountPercentage(double oldPrice, double newPrice) {
    if (oldPrice == 0) return 0.0;
    return ((oldPrice - newPrice) / oldPrice) * 100;
  }

  double calculateTotalPrice(
      int quantity, Map<String, num> selectedAddOnPrices) {
    double basePrice =
        double.parse(widget.lowestPrice["price"].toStringAsFixed(1));
    double sizePrice = selectedSizePrice ?? 0.0;
    double addOnsTotalPrice =
        selectedAddOnPrices.values.fold(0.0, (sum, price) => sum + price);

    // Calculate the total price
    double totalPrice = (basePrice + sizePrice + addOnsTotalPrice) * quantity;
    finalPrice = totalPrice;

    log("Base price: $basePrice");
    log("Selected size price: $sizePrice");
    log("Selected addons total price: $addOnsTotalPrice");
    log("Quantity: $quantity");
    log("Total price: $totalPrice");
    log("Final Price: $finalPrice");
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    num oldPrice = widget.lowestPrice["oldPrice"];
    num price = widget.lowestPrice["price"];
    totalPrice = double.parse(widget.lowestPrice["price"].toStringAsFixed(1));
    double discountPercentage =
        calculateDiscountPercentage(oldPrice.toDouble(), price.toDouble());

    return GestureDetector(
      onTap: () {
        widget.lowestPriceController.updateLowestItem =
            widget.lowestPrice["docId"];
        widget.lowestPriceController.updateLowestTitle =
            widget.lowestPrice["title"];

        buildShowModalBottomSheet(context);
      },
      child: Container(
        margin: EdgeInsets.only(right: 5.w, left: 8.w),
        padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 5.h),
        width: MediaQuery.of(context).size.width * 0.30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(5.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: kGrayLight),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  height: 110.h,
                  width: 160.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      widget.lowestPrice["image"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.h,
                  right: 1.w,
                  child: Stack(
                    children: [
                      Container(
                        width: 50.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      Positioned(
                        right: -15.w,
                        bottom: -15.h,
                        child: Transform.rotate(
                          angle: -0.7854, // 45 degrees in radians
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            color: kPrimary,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.w,
                        top: 4.h,
                        child: Text(
                          "${discountPercentage.toStringAsFixed(0)}% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      widget.lowestPrice["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.actor(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "${widget.lowestPrice["productQuantity"]}",
                      style: appStyle(10, kDark, FontWeight.normal)),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Old Price and New Price
                      Column(
                        children: [
                          ReusableText(
                              text: "₹${price.toString()}",
                              style: appStyle(10, kGray, FontWeight.bold)),
                          ReusableText(
                            text: "₹${oldPrice.toString()}",
                            style: appStyle(10, kGray, FontWeight.bold)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                      //Outline add Button
                      Container(
                        height: 29.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: kPrimary),
                        ),
                        child: Center(
                          child: Text("ADD",
                              style: appStyle(14, kPrimary, FontWeight.normal)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) async {
    int quantity = 1; // Initial quantity
    totalPrice = double.parse(widget.lowestPrice["price"].toStringAsFixed(1));
    num oldPrice = widget.lowestPrice["oldPrice"];
    num price = widget.lowestPrice["price"];
    double discountPercentage =
        calculateDiscountPercentage(oldPrice.toDouble(), price.toDouble());

    // Fetch Vendor Details
    final vendorDoc = await FirebaseFirestore.instance
        .collection('Vendors')
        .doc(widget.lowestPrice["venId"])
        .get();
    final vendorData = vendorDoc.data()!;

    return showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: 700.h),
      isScrollControlled: true,
      backgroundColor: kOffWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            int _currentPageIndex = 0;
            int _imageCount = 5;
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 210.w,
                          child: Text(widget.lowestPrice["title"],
                              overflow: TextOverflow.ellipsis,
                              style: appStyle(20, kDark, FontWeight.normal)),
                        ),
                        const Spacer(),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomCircleIconButton(
                                icon: const Icon(Icons.share, color: kWhite),
                                onPress: () => Navigator.pop(context)),
                            SizedBox(width: 5.w),
                            CustomCircleIconButton(
                                icon: const Icon(Icons.close, color: kWhite),
                                onPress: () => Navigator.pop(context)),
                            SizedBox(width: 2.w),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    const DashedDivider(color: kHoverColor),
                    SizedBox(height: 10.h),

                    //-------------------------- Image Section --------------------
                    SizedBox(
                      height: 140.h,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: _imageCount,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(
                                  widget.lowestPrice["image"],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                          ),
                          Positioned(
                            bottom: 10.h,
                            left: 0,
                            right: 0,
                            child: DotsIndicator(
                              dotsCount: _imageCount,
                              position: _currentPageIndex,
                              decorator: DotsDecorator(
                                activeColor: kPrimary, // Active dot color
                                size: const Size.square(8.0), // Dot size
                                activeSize:
                                    const Size.square(8.0), // Active dot size
                                activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    //===================== Vendor Details ========================
                    //vendor Details
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => VendorsDetailsScreen(
                              vendorId: vendorData["uid"],
                              vendorName: vendorData["userName"]),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25.r,
                            backgroundColor: kTertiary.withOpacity(0.1),
                            backgroundImage: NetworkImage(
                              vendorData["profilePicture"].isEmpty
                                  ? 'https://firebasestorage.googleapis.com/v0/b/groceryapp-july.appspot.com/o/new_logo_f.png?alt=media&token=a501618a-8e24-4956-9afa-3de0027dcb4c' // Replace with your default image URL
                                  : vendorData["profilePicture"],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(vendorData["userName"],
                                  style:
                                      appStyle(17, kDark, FontWeight.normal)),
                              Text("Explore All Products",
                                  style: appStyle(
                                      12, kTertiary, FontWeight.normal))
                            ],
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    //=================== Selling price and Mrp Price and Unit/quantity================
                    ReusableText(
                        text: "${widget.lowestPrice["productQuantity"]}",
                        style: appStyle(14, kDark, FontWeight.w500)),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        ReusableText(
                            text: "₹${price.toString()}",
                            style: appStyle(15, kDark, FontWeight.bold)),
                        SizedBox(width: 10.w),
                        ReusableText(
                          text: "₹${oldPrice.toString()}",
                          style: appStyle(13, kGray, FontWeight.bold)
                              .copyWith(decoration: TextDecoration.lineThrough),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 65.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            border:
                                Border.all(color: kTertiary.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Center(
                            child: Text(
                              "${discountPercentage.toStringAsFixed(0)}% OFF",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    const DashedDivider(color: kHoverColor),
                    SizedBox(height: 15.h),
                    Text(
                      "Product Details",
                      style: appStyle(18, kDark, FontWeight.normal),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "Description",
                      style: appStyle(15, kDark, FontWeight.normal),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      widget.lowestPrice["description"],
                      maxLines: 2,
                      style: appStyle(11, kDark, FontWeight.normal),
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: width * 0.7,
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.lowestPrice["foodCalories"].length,
                        itemBuilder: (ctx, i) {
                          final tag = widget.lowestPrice["foodCalories"][i];
                          return Container(
                            margin: EdgeInsets.only(right: 5.w),
                            decoration: BoxDecoration(
                                color: kSecondaryLight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.r))),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(2.h),
                                child: ReusableText(
                                    text: tag,
                                    style: appStyle(8, kGray, FontWeight.w400)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.0.h),
                    if (widget.lowestPrice
                            .containsKey("isAllergicIngredientsAvailable") &&
                        widget.lowestPrice["isAllergicIngredientsAvailable"] ==
                            true) ...[
                      _buildAllergicIngredientsCard(context, setState),
                      SizedBox(height: 20.h),
                    ],
                    if (widget.lowestPrice.containsKey("isSizesAvailable") &&
                        widget.lowestPrice["isSizesAvailable"] == true) ...[
                      _buildSizeCard(context, _selectedSizeIndex, setState),
                      SizedBox(height: 20.h),
                    ],
                    if (widget.lowestPrice.containsKey("isAddonAvailable") &&
                        widget.lowestPrice["isAddonAvailable"] == true) ...[
                      _buildAddOnCard(context, setState),
                      SizedBox(height: 20.h),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 45.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: kPrimary)),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 1) {
                                      quantity--;
                                      totalPrice -= double.parse(widget
                                          .lowestPrice["price"]
                                          .toStringAsFixed(1));
                                    }
                                  });
                                },
                              ),
                              Text(quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                    totalPrice += double.parse(widget
                                        .lowestPrice["price"]
                                        .toStringAsFixed(1));
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
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
                            onPressed: () async {
                              cartItems.add(
                                addToCart(
                                  {
                                    "foodName": widget.lowestPrice["title"],
                                    "discountAmount": 0,
                                    "couponCode": "",
                                    "foodId": widget.lowestPrice["docId"],
                                    "quantity": quantity,
                                    "img": widget.lowestPrice["image"],
                                    "time":
                                        widget.lowestPrice["time"].toString(),
                                    "totalPrice": finalPrice,
                                    "subTotalPrice": finalPrice,
                                    "baseTotalPrice": finalPrice,
                                    "quantityPrice": finalPrice,
                                    "foodPrice": widget.lowestPrice["price"],
                                    "venId": widget.lowestPrice["venId"],
                                    "foodCalories":
                                        widget.lowestPrice["foodCalories"],
                                    "isVeg": widget.lowestPrice["isVeg"],
                                    "userId": currentUId,
                                    "selectedSize": selectedSizeName,
                                    "selectedSizePrice": selectedSizePrice ?? 0,
                                    "selectedAddOns": selectedAddOns,
                                    "selectedAddOnsPrice": selectedAddOnPrices,
                                    "selectedAllergicIngredients":
                                        _selectedAllergicOns,
                                    "added_by": DateTime.now(),
                                  },
                                  widget.lowestPrice["docId"],
                                ).then((value) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Item added to cart... view your item"),
                                      duration: const Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: 'View',
                                        onPressed: () {
                                          Get.to(() => const CheckoutScreen());
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                                "Add to cart -₹${calculateTotalPrice(quantity, selectedAddOnPrices).toStringAsFixed(1)} ",
                                style: appStyle(16, kWhite, FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllergicIngredientsCard(BuildContext context, setState) {
    if (widget.lowestPrice.containsKey("allergic")) {
      List<dynamic> allergicIngredients = widget.lowestPrice["allergic"];
      return Card(
        color: kWhite,
        child: Padding(
          padding: EdgeInsets.all(8.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Allergic Ingredients",
                  style: appStyle(16, kDark, FontWeight.normal)),
              SizedBox(height: 5.h),
              Column(
                children: allergicIngredients.map<Widget>((ingredient) {
                  final ingredientName = ingredient.toString();
                  final isChecked =
                      _selectedAllergicOns.contains(ingredientName);
                  return _buildAllergicIngredient(
                      ingredientName, isChecked, setState);
                }).toList(),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(); // Placeholder for when there are no allergic ingredients
    }
  }

  Widget _buildSizeCard(BuildContext context, int selectedIndex, setState) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Items")
          .doc(widget.lowestPrice["docId"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          var sizes = data["sizes"] as List<dynamic>;
          // Set default size if no size is selected
          if (selectedSizeName == null && sizes.isNotEmpty) {
            selectedSizeName = sizes[0]["title"];
            selectedSizePrice = double.parse(sizes[0]["price"].toString());
          }
          return Card(
            color: kWhite,
            child: Padding(
              padding: EdgeInsets.all(8.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Size",
                        style: appStyle(18, kDark, FontWeight.normal),
                      ),
                      // Text(
                      //     "₹${double.parse(widget.food["price"].toStringAsFixed(1))}",
                      //     style: appStyle(14, kSecondary, FontWeight.bold))
                    ],
                  ),
                  ReusableText(
                    text: "Select any 1 option",
                    style: appStyle(13, kGray, FontWeight.w500),
                  ),
                  SizedBox(height: 10.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(sizes.length, (index) {
                        var sizeData = sizes.reversed.toList()[index];
                        var sizeId = sizeData["sizeId"];
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("sizes")
                              .doc(sizeId)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              var sizeDocument =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              var title = sizeDocument["title"];
                              var images = sizeDocument["image"];
                              var price = sizeData["price"];
                              var isSelected = selectedIndex == index;
                              double foodPrice = double.parse(
                                  widget.lowestPrice["price"].toString());
                              double sizePrice = double.parse(price.toString());

                              return GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   selectedSizeIndex = index;
                                  // });
                                  if (mounted) {
                                    setState(() {
                                      selectedSizeIndex = index;
                                      selectedSizeName = title;
                                      selectedSizePrice =
                                          double.parse(price.toString());
                                    });
                                  }
                                },
                                child: Container(
                                  width: 158.w,
                                  height: 120.h,
                                  margin: EdgeInsets.only(right: 8.w),
                                  padding: EdgeInsets.only(
                                      left: 8.w, right: 8.w, top: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: isSelected ? kOffWhite : kWhite,
                                    border: Border.all(color: kGray),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isSelected)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: kWhite,
                                            size: 20.0.sp,
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Text(
                                            title,
                                            style: appStyle(
                                                14,
                                                isSelected ? kDark : kDark,
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "₹${(foodPrice + sizePrice).toStringAsFixed(1)}",
                                        style: appStyle(
                                          12,
                                          isSelected ? kDark : kDark,
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Image.network(
                                          images,
                                          color: isSelected ? kDark : kDark,
                                          height: 38.h,
                                          width: 40.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAddOnCard(BuildContext context, setState) {
    if (widget.lowestPrice.containsKey("addOns")) {
      List<dynamic> addOnIds = widget.lowestPrice["addOns"];

      return FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchAddOnsData(addOnIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> addOnDocuments = snapshot.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add On",
                        style: appStyle(16, kDark, FontWeight.normal)),
                    ReusableText(
                        text: "Select any 1 option",
                        style: appStyle(13, kGray, FontWeight.w500)),
                    Column(
                      children: addOnDocuments.map<Widget>((document) {
                        final addOnData =
                            document.data() as Map<String, dynamic>;
                        final title = addOnData["name"];
                        // addOnPrice = addOnData["price"];
                        final price = addOnData["price"];
                        double foodPrice = double.parse(
                            widget.lowestPrice["price"].toString());
                        final isSelected = selectedAddOns.contains(title);
                        log("Add On Price : $price");
                        return _buildAddonTile(
                            title, price!, foodPrice, isSelected, setState);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    } else {
      return const SizedBox(); // Placeholder for when there are no addons
    }
  }

  Future<List<DocumentSnapshot>> _fetchAddOnsData(
      List<dynamic> addOnIds) async {
    List<DocumentSnapshot> addOnDocuments = [];
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("AddOns")
          .where(FieldPath.documentId, whereIn: addOnIds)
          .get();
      addOnDocuments = snapshot.docs;
    } catch (error) {
      log("Error fetching add-ons: $error");
    }
    return addOnDocuments;
  }

  Widget _buildAddonTile(
      String title, num price, double foodPrice, bool isSelected, setState) {
    return ListTile(
      title: Text(
        title,
        style: appStyle(14, kDark, FontWeight.normal),
      ),
      subtitle: Text(
        "₹${price.toString()}",
        // "₹${(foodPrice + price).toStringAsFixed(1)}",
        style: appStyle(12, kGray, FontWeight.normal),
      ),
      trailing: Checkbox(
        value: isSelected,
        activeColor: kSecondary,
        onChanged: (bool? value) {
          setState(() {
            if (value != null) {
              toggleAddOn(title, price, setState);
            }
          });
        },
      ),
    );
  }

  Widget _buildAllergicIngredient(
      String ingredientName, bool isChecked, setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(ingredientName),
        Checkbox(
          value: isChecked,
          activeColor: kRed,
          onChanged: (bool? value) {
            setState(() {
              if (value != null) {
                toggleAllergicIngredient(ingredientName, setState);
              }
            });
          },
        ),
      ],
    );
  }

  void toggleAllergicIngredient(String title, setState) {
    if (_selectedAllergicOns.contains(title)) {
      _selectedAllergicOns.remove(title);
    } else {
      _selectedAllergicOns.add(title);
    }
    setState(() {});
  }

  void toggleAddOn(String title, num price, setState) {
    if (_selectedAddOns.contains(title)) {
      _selectedAddOns.remove(title);
      selectedAddOnPrices.remove(title);
    } else {
      _selectedAddOns.add(title);
      selectedAddOnPrices[title] = price;
    }
    setState(() {});
  }
}
