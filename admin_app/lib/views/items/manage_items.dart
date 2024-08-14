import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/custom_gradient_button.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';
import 'add_items_screen.dart';
import 'edit_items_screen.dart';

class ManageItemsScreen extends StatefulWidget {
  static const String id = "manage_items_screen";

  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
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

    if (searchController.text.isEmpty) {
      query = query.orderBy("created_at", descending: true);
    } else {
      query = query.orderBy("title");
    }

    return query.limit(_perPage).snapshots().map((snapshot) {
      // If search text is empty, return the unfiltered data
      if (searchController.text.isEmpty) {
        return snapshot.docs;
      } else {
        // Filter the results locally
        String searchText = searchController.text.toLowerCase();
        return snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          return title.contains(searchText);
        }).toList();
      }
    });
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
                    Text("Manage Items",
                        style: appStyle(25, kDark, FontWeight.normal)),
                    CustomGradientButton(
                      w: 220,
                      h: 45,
                      text: "Add Item",
                      onPress: () => Get.to(() => const AddItemsScreen(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 900)),
                    ),
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
                buildHeadingRowWidgets("Sr.No.", "Item Name", "Price",
                    "Priority", "Actions", "Active"),
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
                              final priority = data["priority"] ?? "";
                              final bool approved = data["active"];

                              return reusableRowWidget(
                                serialNumber.toString(),
                                itemName,
                                price.toString(),
                                priority.toString(),
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
                title: Text("Manage Items",
                    style: appStyle(17, kWhite, FontWeight.w500))),
            body: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Manage Items",
                            style: appStyle(16, kDark, FontWeight.normal)),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kTertiary),
                            onPressed: () => Get.to(
                                () => const AddItemsScreen(),
                                transition: Transition.cupertino,
                                duration: const Duration(milliseconds: 900)),
                            child: Text("Add Items",
                                style: appStyle(12, kWhite, FontWeight.normal)))
                      ],
                    ),
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
                                      child: Text(
                                        data["priority"].toString(),
                                        style: appStyle(
                                            16, kDark, FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    TableCell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                Get.to(() => EditItemScreen(
                                                      itemId: data["docId"],
                                                    )),
                                            child: const Icon(Icons.edit,
                                                color: Colors.green),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                _deleteItem(data["docId"]),
                                            child: const Icon(Icons.delete,
                                                color: Colors.red),
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

  Widget buildHeadingRowWidgets(
      srNum, itemName, price, priority, actions, isActive) {
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

  Widget reusableRowWidget(srNum, itemName, price, priority, isActive,
      DocumentReference docRef, itemId) {
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
                  child: Text(priority,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () =>
                              Get.to(() => EditItemScreen(itemId: itemId)),
                          icon: const Icon(Icons.edit, color: Colors.green)),
                      IconButton(
                          onPressed: () => _deleteItem(itemId),
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
                    .collection('Items')
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
