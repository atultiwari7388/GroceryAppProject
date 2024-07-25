import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class ManagePaymentsScreen extends StatefulWidget {
  static const String id = "manage_payment_screen";

  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  // Function to show the edit dialog
  final TextEditingController searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _paymentStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _paymentStream = _getPaymentStream();
  }

  Stream<List<DocumentSnapshot>> _getPaymentStream() {
    Query query = FirebaseCollectionServices().allPaymentsList;

    // Apply orderBy and where clauses based on search text
    if (searchController.text.isNotEmpty) {
      query = query.orderBy("date");
    } else {
      query = query.orderBy("date", descending: true);
    }

    return query.limit(_perPage).snapshots().map((snapshot) => snapshot.docs);
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
      _paymentStream = _getPaymentStream();
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
                Text("Manage Payments",
                    style: appStyle(25, kDark, FontWeight.normal)),
                // CustomGradientButton(
                //   w: 220,
                //   h: 45,
                //   text: "Add Restaurant",
                //   onPress: () {},
                // ),
                //
              ],
            ),
            const SizedBox(height: 20),
            buildHeadingRowWidgets(
                "No.", "OrderId", "DateTime", "Amount", "Status"),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: _paymentStream,
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
                          // final serialNumber = index + 1;
                          final transId = data["transactionId"] ?? "";
                          final orderId = data["orderId"] ?? "";
                          final dateTime = data["paymentDate"] ?? "";
                          final amount = data["amount"];
                          final status = data["status"];
                          final formattedDate = _formatTimestamp(dateTime);
                          final finalStatus = getStatusString(status);
                          final docId = streamData[index].id;
                          return reusableRowWidget(
                            transId.toString(),
                            orderId.toString(),
                            formattedDate,
                            amount.toString(),
                            finalStatus,
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
        appBar: AppBar(title: Text("Manage Payments")),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Manage Payments",
                        style: appStyle(16, kDark, FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _paymentStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final streamData = snapshot.data!;
                      return Table(
                        border: TableBorder.all(color: kDark, width: 1.0),
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: kDark),
                            children: [
                              buildTableHeaderCell("Trans.Id"),
                              buildTableHeaderCell("OrderId"),
                              buildTableHeaderCell("DateTime"),
                              buildTableHeaderCell("Amount"),
                              buildTableHeaderCell("Status"),
                            ],
                          ),
                          // Display List of Banners
                          for (var data in streamData) ...[
                            TableRow(
                              children: [
                                TableCell(
                                  child: Text(data["transactionId"].toString()),
                                ),
                                TableCell(
                                  child: Text(
                                    data["orderId"],
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    _formatTimestamp(data["paymentDate"]),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    data["amount"].toString(),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    getStatusString(data["status"]),
                                    style:
                                        appStyle(12, kDark, FontWeight.normal),
                                    textAlign: TextAlign.center,
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

  Widget buildHeadingRowWidgets(srNum, driverName, phone, email, isActive) {
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
            child: Text(driverName,
                style: appStyle(20, kSecondary, FontWeight.normal)),
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
              email,
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

  Widget reusableRowWidget(srNum, orderId, dateTime, amount, status) {
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
                  child: Text(orderId,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(dateTime,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(amount,
                      style: appStyle(16, kDark, FontWeight.normal))),
              Expanded(
                  flex: 1,
                  child: Text(status,
                      style: appStyle(16, kDark, FontWeight.normal))),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime as desired
    String formattedDate = DateFormat.yMMMMd().format(dateTime);

    return formattedDate;
  }

  // Define a function to map numeric status to string status
  String getStatusString(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Completed";
      case -1:
        return "Payment Cancelled";
      // Add more cases as needed for other statuses
      default:
        return "Unknown Status";
    }
  }
}
