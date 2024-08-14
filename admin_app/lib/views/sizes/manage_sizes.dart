import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:admin_app/views/sizes/add_size.dart';
import 'package:admin_app/views/sizes/edit_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class ManageSizesScreen extends StatefulWidget {
  static const String id = "sizes_screen";

  const ManageSizesScreen({super.key});

  @override
  State<ManageSizesScreen> createState() => _ManageSizesScreenState();
}

class _ManageSizesScreenState extends State<ManageSizesScreen> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _categoryStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _categoryStream = _categoryStreamData();
  }

  Stream<List<DocumentSnapshot>> _categoryStreamData() {
    Query query = FirebaseCollectionServices().allSizesList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query
          .orderBy("title")
          .where("title", isGreaterThanOrEqualTo: "${searchController.text}")
          .where("title",
              isLessThanOrEqualTo: "${searchController.text}\uf8ff");
    } else {
      query = query.orderBy("created_at", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _categoryStream = _categoryStreamData();
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
                Text("Sizes", style: appStyle(25, kDark, FontWeight.normal)),
                CustomGradientButton(
                  w: 220,
                  h: 45,
                  text: "Add Size",
                  onPress: () => Get.to(() => const AddSize(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 900)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by sizes name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Make it circular
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30.0), // Keep the same value
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      _categoryStream =
                          _categoryStreamData(); // Update the stream
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _categoryStream = _categoryStreamData(); // Update the stream
                });
              },
            ),
            SizedBox(height: 30),
            buildHeadingRowWidgets(
                "Sr.no.", "Size Name", "Priority", "Actions", "Active"),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: _categoryStream,
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
                          final categoryName = data["title"] ?? "";
                          final priority = data["priority"].toString();
                          final bool approved = data["active"];
                          final String categoryId = data["id"] ?? "";

                          return reusableRowWidget(
                              serialNumber.toString(),
                              categoryName,
                              priority.toString(),
                              approved,
                              streamData[index].reference,
                              categoryId,
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
          backgroundColor: kTertiary,
          title: Text(
            "Sizes",
            style: appStyle(18, kWhite, FontWeight.normal),
          ),
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
                    Text("Sizes",
                        style: appStyle(16, kDark, FontWeight.normal)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kTertiary),
                        onPressed: () => Get.to(() => const AddSize(),
                            transition: Transition.cupertino,
                            duration: const Duration(milliseconds: 900)),
                        child: Text("Add Size",
                            style: appStyle(12, kWhite, FontWeight.normal)))
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by size name',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Make it circular
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Keep the same value
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          _categoryStream =
                              _categoryStreamData(); // Update the stream
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _categoryStream =
                          _categoryStreamData(); // Update the stream
                    });
                  },
                ),
                SizedBox(height: 30),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _categoryStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final streamData = snapshot.data!;
                      return Table(
                        border: TableBorder.all(color: kDark, width: 1.0),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: kTertiary),
                            children: [
                              buildTableHeaderCell("Sr.No"),
                              buildTableHeaderCell("S'name"),
                              buildTableHeaderCell("Priority"),
                              buildTableHeaderCell("Actions"),
                              buildTableHeaderCell("Active"),
                            ],
                          ),
                          // Display List of Restaurants
                          for (var data in streamData) ...[
                            TableRow(
                              children: [
                                TableCell(
                                  child: Image.network(
                                    data["image"].toString(),
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["title"].toString(),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["priority"].toString(),
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
                                        onTap: () => Get.to(() => EditSize(
                                              sizeId: data["id"],
                                              data: data.data()
                                                  as Map<String, dynamic>,
                                            )),
                                        child: const Icon(Icons.edit,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                                TableCell(
                                  child: Switch(
                                    value: data["active"],
                                    onChanged: (value) {
                                      setState(() {
                                        // data["active"] = value;
                                      });
                                      data.reference.update(
                                          {'active': value}).then((value) {
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
      srNum, categoryName, priority, actions, isActive) {
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
            child: Text(categoryName,
                style: appStyle(20, kSecondary, FontWeight.normal)),
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

  Widget reusableRowWidget(srNum, categoryName, priority, isActive,
      DocumentReference docRef, categoryId, data) {
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
                  child: Text(priority,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Get.to(
                              () => EditSize(sizeId: categoryId, data: data)),
                          icon: const Icon(Icons.edit, color: Colors.green)),
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
}
