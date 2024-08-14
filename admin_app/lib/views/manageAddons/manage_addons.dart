import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:admin_app/views/manageAddons/add_addons.dart';
import 'package:admin_app/views/manageAddons/edit_addons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class ManageAddons extends StatefulWidget {
  static const String id = "manage_addons_screen";

  const ManageAddons({super.key});

  @override
  State<ManageAddons> createState() => _ManageAddonsState();
}

class _ManageAddonsState extends State<ManageAddons> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _bannersStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bannersStream = _bannersStreamData();
  }

  Stream<List<DocumentSnapshot>> _bannersStreamData() {
    Query query = FirebaseCollectionServices().allAddonsList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query
          .where("title", isGreaterThanOrEqualTo: searchController.text)
          .orderBy("created_at");
    } else {
      query = query.orderBy("created_at", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _bannersStream = _bannersStreamData();
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
                Text("Manage Addons",
                    style: appStyle(25, kDark, FontWeight.normal)),
                CustomGradientButton(
                  w: 220,
                  h: 45,
                  text: "Add Addons",
                  onPress: () => Get.to(() => AddAddonsScreen(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 900)),
                ),
              ],
            ),
            const SizedBox(height: 70),
            buildHeadingRowWidgets("Sr.no.", "Name", "Price", "Actions"),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: _bannersStream,
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
                          // final docId = data["docId"] ?? "";
                          final name = data["name"] ?? "";
                          final price = data["price"] ?? 0;
                          final String bannerId = data["id"] ?? "";

                          return reusableRowWidget(
                              serialNumber.toString(),
                              name,
                              price.toString(),
                              streamData[index].reference,
                              bannerId.toString(),
                              data);
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
          title: const Text("Manage Addons"),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Manage Addons",
                      style: appStyle(16, kDark, FontWeight.normal)),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: kSecondary),
                      onPressed: () => Get.to(() => const AddAddonsScreen(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 900)),
                      child: Text("Add Addons",
                          style: appStyle(12, kWhite, FontWeight.normal)))
                ],
              ),
              const SizedBox(height: 10),
              // buildHeadingRowWidgets(
              StreamBuilder<List<DocumentSnapshot>>(
                stream: _bannersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final streamData = snapshot.data!;
                    return Table(
                      border: TableBorder.all(color: kSecondary, width: 1.0),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: kSecondary),
                          children: [
                            buildTableHeaderCell("Sr.No."),
                            buildTableHeaderCell("Name"),
                            buildTableHeaderCell("Price"),
                            buildTableHeaderCell("Actions"),
                          ],
                        ),
                        // Display List of Banners
                        for (var data in streamData) ...[
                          TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "${streamData.indexOf(data).toString()}",
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  data["name"].toString(),
                                  style: appStyle(12, kDark, FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  data["price"].toString(),
                                  style: appStyle(12, kDark, FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => Get.to(() =>
                                          EditAddonsScreen(
                                              addonId: data["id"],
                                              data: data.data()
                                                  as Map<String, dynamic>)),
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
                            ],
                          ),
                        ],
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
              fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildHeadingRowWidgets(srNum, priority, actions, isActive) {
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
            child: Text(
              priority,
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
              isActive,
              textAlign: TextAlign.center,
              style: appStyle(20, kSecondary, FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget reusableRowWidget(
      srNum, categoryName, price, DocumentReference docRef, bannerId, data) {
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
                  child: Text(categoryName,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(price,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Get.to(() =>
                              EditAddonsScreen(addonId: bannerId, data: data)),
                          icon: const Icon(Icons.edit, color: Colors.green)),
                      IconButton(
                          onPressed: () => _deleteItem(bannerId),
                          icon: const Icon(Icons.delete, color: Colors.red)),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }

  void _deleteItem(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this item?"),
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
                    .collection('homeSliders')
                    .doc(itemId)
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
