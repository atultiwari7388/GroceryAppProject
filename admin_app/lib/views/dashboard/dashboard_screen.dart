import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/analysis_box_widget.dart';
import '../../constants/constants.dart';
import '../manageOrders/manage_orders.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = "admin-dashboard";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String formatDateWithTimeStamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return dateFormat.format(dateTime);
  }

  Widget buildAnalysisBox({
    required Stream<QuerySnapshot> stream,
    required String firstText,
    required IconData icon,
    Color containerColor = kPrimary,
    required onTap,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          int count = documents.length;

          return InkWell(
            onTap: onTap,
            child: AnalysisBoxesWidgets(
              containerColor: containerColor,
              firstText: firstText,
              secondText: count.toString(),
              icon: icon,
            ),
          );
        } else {
          return Container(); // Placeholder widget for error or no data
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 3.5,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            shrinkWrap: true,
            padding: const EdgeInsets.all(2),
            children: [
              // Total Appointments
              buildAnalysisBox(
                onTap: () {
                  // Get.to(() => const ManageCustomersScreen());
                },
                stream: FirebaseCollectionServices().usersList,
                firstText: "Total Customers",
                icon: FontAwesomeIcons.users,
                containerColor: Colors.blue,
              ),
// //================== Total Driver =================================
              buildAnalysisBox(
                onTap: () {
                  Get.to(() => const ManageOrdersScreen());
                },
                stream: FirebaseCollectionServices().ordersList,
                firstText: "Total Orders",
                icon: FontAwesomeIcons.personBiking,
                containerColor: Colors.green,
              ),
// //================== Total Booking ===============================
              buildAnalysisBox(
                onTap: () {
                  Get.to(() => const ManageOrdersScreen());
                },
                stream: FirebaseCollectionServices().pendingOrdersList,
                firstText: "Pending Orders",
                icon: FontAwesomeIcons.baby,
                containerColor: Colors.red,
              )
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
