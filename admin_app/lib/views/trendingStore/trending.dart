import 'dart:developer';
import 'package:admin_app/views/manageVendors/vendor_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../services/firebase_collection_services.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class TrendingStore extends StatefulWidget {
  static const String id = "manage_vendors_screen";

  const TrendingStore({super.key});

  @override
  State<TrendingStore> createState() => _TrendingStoreState();
}

class _TrendingStoreState extends State<TrendingStore> {
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _driverStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _driverStream = _driverStreamData();
  }

  Stream<List<DocumentSnapshot>> _driverStreamData() {
    Query query = FirebaseCollectionServices().allVendorsList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query
          .orderBy("phoneNumber")
          .where("phoneNumber",
              isGreaterThanOrEqualTo: "+91${searchController.text}")
          .where("phoneNumber",
              isLessThanOrEqualTo: "+91${searchController.text}\uf8ff");
    } else {
      query = query.orderBy("created_at", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _driverStream = _driverStreamData();
      log(_currentPage.toString());
      log(_perPage.toString());
    });
  }

  Future<Map<String, dynamic>?> fetchVendorComCharges() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('vendorCharges')
          .get();

      if (snapshot.exists) {
        log(snapshot.data().toString());
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
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
                Text("Manage Vendors ",
                    style: appStyle(25, kDark, FontWeight.normal)),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by number',
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
                      _driverStream = _driverStreamData(); // Update the stream
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _driverStream = _driverStreamData(); // Update the stream
                });
              },
            ),
            SizedBox(height: 30),
            buildHeadingRowWidgets(
                "Sr.no.", "V'Name", "Phone", "Total Orders", "Trending"),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: _driverStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final streamData = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: streamData.length,
                        itemBuilder: (context, index) {
                          final data =
                              streamData[index].data() as Map<String, dynamic>;
                          final serialNumber = index + 1;
                          final driverName = data["userName"] ?? "";
                          final driverPhone = data["phoneNumber"] ?? "";
                          final driverEmail = data["totalOrders"] ?? 0;
                          final bool approved = data["isTrending"];
                          final docId = streamData[index].id;
                          return InkWell(
                            onTap: () => Get.to(() => VendorDetailsScreen(
                                riderData: streamData[index])),
                            child: reusableRowWidget(
                              serialNumber.toString(),
                              driverName,
                              driverPhone.toString(),
                              driverEmail.toString(),
                              approved,
                              streamData[index].reference,
                            ),
                          );
                        },
                      ),
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
          title: Text("Trending Store"),
          backgroundColor: kSecondary,
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
                    Text("Trending Vendor Store",
                        style: appStyle(16, kDark, FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by number',
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
                          _driverStream =
                              _driverStreamData(); // Update the stream
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _driverStream = _driverStreamData(); // Update the stream
                    });
                  },
                ),
                SizedBox(height: 10),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _driverStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final streamData = snapshot.data!;
                      return Table(
                        border: TableBorder.all(color: kDark, width: 1.0),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: kSecondary),
                            children: [
                              buildTableHeaderCell("Sr.no."),
                              buildTableHeaderCell("V'Name"),
                              buildTableHeaderCell("Phone"),
                              buildTableHeaderCell("Total Orders"),
                              buildTableHeaderCell("Trending"),
                            ],
                          ),
                          for (var data in streamData)
                            buildDriverTableRow(data, streamData.indexOf(data)),
                          TableRow(
                            children: [
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

  Padding buildHeadingRowWidgets(
      String s, String t, String u, String v, String w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(color: kSecondary),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildHeadingCell(s),
            buildHeadingCell(t),
            buildHeadingCell(u),
            buildHeadingCell(v),
            buildHeadingCell(w),
          ],
        ),
      ),
    );
  }

  TableRow buildDriverTableRow(DocumentSnapshot data, int index) {
    final driverData = data.data() as Map<String, dynamic>;
    final serialNumber = index + 1;
    final driverName = driverData["userName"] ?? "";
    final driverPhone = driverData["phoneNumber"] ?? "";
    final driverEmail = driverData["totalOrders"] ?? 0;
    final bool approved = driverData["isTrending"];
    final docId = data.id;

    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(serialNumber.toString()),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(driverName),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(driverPhone.toString()),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(driverEmail.toString()),
          ),
        ),
        TableCell(
          child: Switch(
            value: approved,
            onChanged: (value) {
              if (value) {
                data.reference.update({
                  'isTrending': value,
                }).then((value) {
                  showToastMessage("Success", "Value updated", Colors.green);
                }).catchError((error) {
                  showToastMessage(
                      "Error", "Failed to update value", Colors.red);
                });
                setState(() {});
                // _showVendorTypeDialog(docId, driverName);
              } else {
                // Update Firestore document when switch is turned off
                data.reference.update({
                  'isTrending': value,
                }).then((value) {
                  showToastMessage("Success", "Value updated", Colors.green);
                }).catchError((error) {
                  showToastMessage(
                      "Error", "Failed to update value", Colors.red);
                });
                setState(() {}); // Trigger a state update
              }
            },
          ),
        ),
      ],
    );
  }

  Widget reusableRowWidget(String s, String t, String u, String v, bool w,
      DocumentReference reference) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
            color: kGray.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: kWhite.withOpacity(0.3),
              ),
            )),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildDataCell(s),
            buildDataCell(t),
            buildDataCell(u),
            buildDataCell(v),
            Switch(
              value: w,
              onChanged: (value) {
                if (value) {
                  reference.update({
                    'isTrending': value,
                  }).then((value) {
                    showToastMessage("Success", "Value updated", Colors.green);
                  }).catchError((error) {
                    showToastMessage(
                        "Error", "Failed to update value", Colors.red);
                  });
                  setState(() {});
                  // _showVendorTypeDialog(docId, driverName);
                } else {
                  // Update Firestore document when switch is turned off
                  reference.update({
                    'isTrending': value,
                  }).then((value) {
                    showToastMessage("Success", "Value updated", Colors.green);
                  }).catchError((error) {
                    showToastMessage(
                        "Error", "Failed to update value", Colors.red);
                  });
                  setState(() {}); // Trigger a state update
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeadingCell(String text) {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Text(
        text,
        style: appStyle(15, kWhite, FontWeight.bold),
      ),
    );
  }

  Widget buildDataCell(String text) {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Text(
        text,
        style: appStyle(15, kDark, FontWeight.w500),
      ),
    );
  }

  Widget buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: appStyle(16, kWhite, FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
