import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:admin_app/views/coupons/add_coupon.dart';
import 'package:admin_app/views/coupons/edit_coupon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class ManageCouponsScreen extends StatefulWidget {
  static const String id = "manage_coupons_screen";

  const ManageCouponsScreen({super.key});

  @override
  State<ManageCouponsScreen> createState() => _ManageCouponsScreenState();
}

class _ManageCouponsScreenState extends State<ManageCouponsScreen> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _couponStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _couponStream = _couponStreamData();
  }

  Stream<List<DocumentSnapshot>> _couponStreamData() {
    Query query = FirebaseCollectionServices().allCouponsList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query.orderBy("created_at");
    } else {
      query = query.orderBy("created_at", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _couponStream = _couponStreamData();
      log(_currentPage.toString());
      log(_perPage.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Manage Coupons",
                    style: appStyle(25, kDark, FontWeight.normal)),
                CustomGradientButton(
                  w: 220,
                  h: 45,
                  text: "Add Coupons",
                  onPress: () => Get.to(() => const AddCouponScreen(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 900)),
                ),
              ],
            ),
            const SizedBox(height: 70),
            buildHeadingRowWidgets("Sr.No.", "C'Name", "MinP'Amount", "D-Type",
                "Actions", "D-Value", "Active"),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: _couponStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final streamData = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display List of Drivers
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: streamData.length,
                        itemBuilder: (context, index) {
                          final data =
                              streamData[index].data() as Map<String, dynamic>;
                          final serialNumber = index + 1;
                          final name = data["couponName"] ?? "";
                          final minPurchaseAmount =
                              data["minPurchaseAmount"] ?? "";
                          final discountType = data["discountType"] ?? "";
                          final discountValue = data["discountValue"] ?? "";
                          final bool approved = data["enabled"];
                          final couponNameId = data["couponName"] ?? "";

                          // final restaurantId = item.id;

                          return reusableRowWidget(
                            serialNumber.toString(),
                            name,
                            minPurchaseAmount.toString(),
                            discountType,
                            discountValue.toString(),
                            approved,
                            streamData[index].reference,
                            couponNameId,
                            data,
                          );
                        },
                      ),
                      // Pagination Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: TextButton(
                            onPressed: _loadNextPage,
                            child: const Text("Next"),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kSecondary,
          iconTheme: IconThemeData(color: kWhite),
          title: Text("Manage Coupons"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Manage Coupons",
                        style: appStyle(16, kDark, FontWeight.normal)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondary),
                        onPressed: () => Get.to(() => const AddCouponScreen(),
                            transition: Transition.cupertino,
                            duration: const Duration(milliseconds: 900)),
                        child: Text("Add Coupons",
                            style: appStyle(12, kWhite, FontWeight.normal)))
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _couponStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final streamData = snapshot.data!;
                      return Table(
                        border: TableBorder.all(color: kSecondary, width: 1.0),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: kSecondary),
                            children: [
                              buildTableHeaderCell("C'name"),
                              buildTableHeaderCell("Min-P'Amount"),
                              buildTableHeaderCell("D-Type"),
                              buildTableHeaderCell("D-value"),
                              buildTableHeaderCell("Actions"),
                              buildTableHeaderCell("Active"),
                            ],
                          ),
                          // Display List of Restaurants
                          for (var data in streamData) ...[
                            TableRow(
                              children: [
                                TableCell(
                                  child: Text(
                                    data["couponName"] ?? "",
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["minPurchaseAmount"].toString(),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["discountType"] ?? "",
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["discountValue"].toString(),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            Get.to(() => EditCouponScreen(
                                                  couponId: data["couponName"],
                                                  data: data.data()
                                                      as Map<String, dynamic>,
                                                )),
                                        child: const Icon(Icons.edit,
                                            color: Colors.green),
                                      ),
                                      InkWell(
                                        onTap: () => _deleteItem(data["id"]),
                                        child: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                TableCell(
                                  child: Switch(
                                    value: data["enabled"],
                                    onChanged: (value) {
                                      setState(() {
                                        // data["active"] = value;
                                      });
                                      data.reference.update(
                                          {'enabled': value}).then((value) {
                                        showToastMessage("Success",
                                            "Value updated", Colors.green);
                                      }).catchError((error) {
                                        showToastMessage(
                                            "Error",
                                            "Failed to update value",
                                            Colors.red);
                                        print("Failed to update value: $error");
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Pagination Button
                          TableRow(
                            children: [
                              TableCell(
                                child:
                                    SizedBox(), // This cell is for the pagination button
                              ),
                              TableCell(
                                child: SizedBox(),
                              ),
                              TableCell(
                                child: SizedBox(),
                              ),
                              TableCell(
                                child: SizedBox(),
                              ),
                              TableCell(
                                child: SizedBox(),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: TextButton(
                                      onPressed: _loadNextPage,
                                      child: const Text("Next"),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildHeadingRowWidgets(
      srNum, name, email, phone, restaurant, actions, isActive) {
    return Container(
      padding:
          const EdgeInsets.only(top: 18.0, left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child:
                Text(srNum, style: appStyle(20, kSecondary, FontWeight.normal)),
          ),
          Expanded(
            flex: 1,
            child:
                Text(name, style: appStyle(20, kSecondary, FontWeight.normal)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              email,
              style: appStyle(20, kSecondary, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              phone,
              style: appStyle(20, kSecondary, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              actions,
              style: appStyle(20, kSecondary, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              restaurant,
              style: appStyle(20, kSecondary, FontWeight.normal),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              isActive,
              textAlign: TextAlign.center,
              style: appStyle(20, kSecondary, FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget reusableRowWidget(srNum, name, email, phone, restaurant, isActive,
      DocumentReference docRef, couponNameId, data) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text(srNum,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(name,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(email,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(phone,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(restaurant,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Get.to(() => EditCouponScreen(
                              couponId: couponNameId, data: data)),
                          icon: const Icon(Icons.edit, color: Colors.green)),
                      IconButton(
                          onPressed: () => _deleteItem(couponNameId),
                          icon: const Icon(Icons.delete, color: kRed)),
                    ],
                  )),
              Expanded(
                flex: 1,
                child: Builder(builder: (context) {
                  return Switch(
                    key: UniqueKey(),
                    value: isActive,
                    onChanged: (bool value) {
                      setState(() {
                        isActive = value;
                      });

                      docRef.update({'active': value}).then((value) {
                        showToastMessage(
                            "Success", "Value updated", Colors.green);
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }

  void _deleteItem(String couponNameId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this coupon?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel",
                  style: appStyle(16, Colors.green, FontWeight.w500)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('coupons')
                    .doc(couponNameId)
                    .delete();

                Navigator.of(context).pop();
                showToastMessage(
                    "Success", "Item deleted successfully!", Colors.green);
              },
              child: Text("Delete",
                  style: appStyle(16, Colors.red, FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }
}
