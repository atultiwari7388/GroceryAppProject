import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';
import '../items/edit_items_screen.dart';

class LowestPriceScreen extends StatefulWidget {
  static const String id = "lowest_price_items";

  const LowestPriceScreen({super.key});

  @override
  State<LowestPriceScreen> createState() => _LowestPriceScreenState();
}

class _LowestPriceScreenState extends State<LowestPriceScreen> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _itemsStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _itemsStream = _getItemsStream();
  }

  Stream<List<DocumentSnapshot>> _getItemsStream() {
    Query query = FirebaseCollectionServices().allItemsList;

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
      _itemsStream = _getItemsStream();
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
    return kIsWeb
        ? Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items",
                        style: appStyle(25, kDark, FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by item name',
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
                          _itemsStream = _getItemsStream(); // Update the stream
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _itemsStream = _getItemsStream(); // Update the stream
                    });
                  },
                ),
                SizedBox(height: 30),
                buildHeadingRowWidgets(
                    "Sr.No.", "Item Name", "Price", "Lowest"),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _itemsStream,
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
                              final data = streamData[index].data()
                                  as Map<String, dynamic>;
                              final serialNumber = index + 1;
                              final itemName = data["title"] ?? "";
                              final price = data["price"] ?? "";
                              final bool approved = data["isLowestPrice"];

                              return reusableRowWidget(
                                serialNumber.toString(),
                                itemName,
                                price.toString(),
                                approved,
                                streamData[index].reference,
                                streamData[index].id,
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
          )
        : Scaffold(
            appBar: AppBar(
                backgroundColor: kTertiary,
                title: Text("Items",
                    style: appStyle(17, kWhite, FontWeight.w500))),
            body: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by item name',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Make it circular
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Keep the same value
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
                              _itemsStream =
                                  _getItemsStream(); // Update the stream
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _itemsStream = _getItemsStream(); // Update the stream
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<List<DocumentSnapshot>>(
                      stream: _itemsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final streamData = snapshot.data!;
                          return Table(
                            border: TableBorder.all(color: kDark, width: 1.0),
                            children: [
                              TableRow(
                                decoration:
                                    const BoxDecoration(color: kTertiary),
                                children: [
                                  buildTableHeaderCell("Sr.no."),
                                  buildTableHeaderCell("Item Name"),
                                  buildTableHeaderCell("Price"),
                                  buildTableHeaderCell("Lowest"),
                                ],
                              ),
                              // Display List of Restaurants
                              for (var data in streamData) ...[
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text(
                                        (streamData.indexOf(data) + 1)
                                            .toString(),
                                        style: appStyle(
                                            12, kDark, FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        data["title"] ?? "",
                                        style: appStyle(
                                            16, kDark, FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        data["price"].toString(),
                                        style: appStyle(
                                            16, kDark, FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TableCell(
                                      child: Switch(
                                        value: data["isLowestPrice"],
                                        onChanged: (value) {
                                          setState(() {
                                            // data["active"] = value;
                                          });
                                          data.reference.update({
                                            'isLowestPrice': value
                                          }).then((value) {
                                            showToastMessage("Success",
                                                "Value updated", Colors.green);
                                          }).catchError((error) {
                                            showToastMessage(
                                                "Error",
                                                "Failed to update value",
                                                Colors.red);
                                            print(
                                                "Failed to update value: $error");
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
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.normal, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildHeadingRowWidgets(srNum, itemName, price, isActive) {
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
            child: Text(itemName,
                style: appStyle(20, kSecondary, FontWeight.normal)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              price,
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
      srNum, itemName, price, isActive, DocumentReference docRef, itemId) {
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
                  child: Text(itemName,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(price,
                      style: appStyle(16, kDark, FontWeight.normal))),
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

                      docRef.update({'isLowestPrice': value}).then((value) {
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
