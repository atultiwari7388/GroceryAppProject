
    // return showModalBottomSheet(
    // context: context,
    // constraints: BoxConstraints(maxHeight: 700.h),
    // isScrollControlled: true,
    // backgroundColor: kOffWhite,
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.only(
    //     topLeft: Radius.circular(20.0.r),
    //     topRight: Radius.circular(20.0.r),
    //   ),
    // ),
    //   builder: (BuildContext context) {
    //     return StatefulBuilder(
    //       builder: (BuildContext context, StateSetter setState) {
    //         return SingleChildScrollView(
    //           child: Container(
    //             padding: EdgeInsets.all(16.0.w),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 Row(
    //                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     SizedBox(
    //                       width: 210.w,
    //                       child: Text(widget.food["title"],
    //                           overflow: TextOverflow.ellipsis,
    //                           style: appStyle(20, kDark, FontWeight.normal)),
    //                     ),
    //                     const Spacer(),
    //                     Row(
    //                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         CustomCircleIconButton(
    //                             icon: const Icon(Icons.close, color: kWhite),
    //                             onPress: () => Navigator.pop(context)),
    //                         SizedBox(width: 5.w),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 const DashedDivider(color: kHoverColor),
    //                 SizedBox(height: 10.h),
    //                 Text(
    //                   "Description",
    //                   style: appStyle(15, kDark, FontWeight.normal),
    //                 ),
    //                 SizedBox(height: 5.h),
    //                 Text(
    //                   widget.food["description"],
    //                   maxLines: 2,
    //                   style: appStyle(11, kDark, FontWeight.normal),
    //                 ),
    //                 SizedBox(height: 5.h),
    //                 SizedBox(
    //                   width: width * 0.7,
    //                   height: 15.h,
    //                   child: ListView.builder(
    //                     scrollDirection: Axis.horizontal,
    //                     itemCount: widget.food["foodCalories"].length,
    //                     itemBuilder: (ctx, i) {
    //                       final tag = widget.food["foodCalories"][i];
    //                       return Container(
    //                         margin: EdgeInsets.only(right: 5.w),
    //                         decoration: BoxDecoration(
    //                             color: kSecondaryLight,
    //                             borderRadius:
    //                                 BorderRadius.all(Radius.circular(9.r))),
    //                         child: Center(
    //                           child: Padding(
    //                             padding: EdgeInsets.all(2.h),
    //                             child: ReusableText(
    //                                 text: tag,
    //                                 style: appStyle(8, kGray, FontWeight.w400)),
    //                           ),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 ),
    //                 SizedBox(height: 20.0.h),
    //                 if (widget.food
    //                         .containsKey("isAllergicIngredientsAvailable") &&
    //                     widget.food["isAllergicIngredientsAvailable"] ==
    //                         true) ...[
    //                   _buildAllergicIngredientsCard(context, setState),
    //                   SizedBox(height: 20.h),
    //                 ],
    //                 if (widget.food.containsKey("isSizesAvailable") &&
    //                     widget.food["isSizesAvailable"] == true) ...[
    //                   _buildSizeCard(context, _selectedSizeIndex, setState),
    //                   SizedBox(height: 20.h),
    //                 ],
    //                 if (widget.food.containsKey("isAddonAvailable") &&
    //                     widget.food["isAddonAvailable"] == true) ...[
    //                   _buildAddOnCard(context, setState),
    //                   SizedBox(height: 20.h),
    //                 ],
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Container(
    //                       height: 45.h,
    //                       width: 120.w,
    //                       decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(12.r),
    //                           border: Border.all(color: kPrimary)),
    //                       child: Row(
    //                         children: [
    //                           IconButton(
    //                             icon: const Icon(Icons.remove),
    //                             onPressed: () {
    //                               setState(() {
    //                                 if (quantity > 1) {
    //                                   quantity--;
    //                                   totalPrice -= double.parse(widget
    //                                       .food["price"]
    //                                       .toStringAsFixed(1));
    //                                 }
    //                               });
    //                             },
    //                           ),
    //                           Text(quantity.toString()),
    //                           IconButton(
    //                             icon: const Icon(Icons.add),
    //                             onPressed: () {
    //                               setState(() {
    //                                 quantity++;
    //                                 totalPrice += double.parse(widget
    //                                     .food["price"]
    //                                     .toStringAsFixed(1));
    //                               });
    //                             },
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(12),
    //                         gradient: const LinearGradient(
    //                           begin: Alignment.centerLeft,
    //                           end: Alignment.centerRight,
    //                           colors: [
    //                             kPrimary,
    //                             kPrimary,
    //                             kPrimary,
    //                           ],
    //                         ),
    //                       ),
    //                       child: ElevatedButton(
    //                         onPressed: () async {
    //                           cartItems.add(
    //                             addToCart(
    //                               {
    //                                 "foodName": widget.food["title"],
    //                                 "discountAmount": 0,
    //                                 "couponCode": "",
    //                                 "foodId": widget.food["docId"],
    //                                 "quantity": quantity,
    //                                 "img": widget.food["image"],
    //                                 "totalPrice": finalPrice,
    //                                 "subTotalPrice": finalPrice,
    //                                 "baseTotalPrice": finalPrice,
    //                                 "quantityPrice": finalPrice,
    //                                 "foodPrice": widget.food["price"],
    //                                 "resId": widget.food["resId"],
    //                                 "foodCalories": widget.food["foodCalories"],
    //                                 "isVeg": widget.food["isVeg"],
    //                                 "userId": currentUId,
    //                                 "selectedSize": selectedSizeName,
    //                                 "selectedSizePrice": selectedSizePrice ?? 0,
    //                                 "selectedAddOns": selectedAddOns,
    //                                 "selectedAddOnsPrice": selectedAddOnPrices,
    //                                 "selectedAllergicIngredients":
    //                                     _selectedAllergicOns,
    //                                 "added_by": DateTime.now(),
    //                               },
    //                               widget.food["docId"],
    //                             ).then((value) {
    //                               Navigator.pop(context);
    //                               ScaffoldMessenger.of(context).showSnackBar(
    //                                 SnackBar(
    //                                   content: const Text(
    //                                       "Item added to cart... view your item"),
    //                                   duration: const Duration(seconds: 4),
    //                                   action: SnackBarAction(
    //                                     label: 'View',
    //                                     onPressed: () {
    //                                       // Get.to(() => CheckoutScreen());
    //                                     },
    //                                   ),
    //                                 ),
    //                               );
    //                             }),
    //                           );
    //                         },
    //                         style: ElevatedButton.styleFrom(
    //                           backgroundColor: Colors.transparent,
    //                           shadowColor: Colors.transparent,
    //                         ),
    //                         child: Text(
    //                             "Add to cart -₹${calculateTotalPrice(quantity, selectedAddOnPrices).toStringAsFixed(1)} ",
    //                             style: appStyle(16, kWhite, FontWeight.w500)),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         );
    //       },
    //     );

    //   },
    // );
