import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:admin_app/utils/app_style.dart';
import 'package:admin_app/views/category/categories_screen.dart';
import 'package:admin_app/views/coupons/manage_coupons_screen.dart';
import 'package:admin_app/views/items/manage_items.dart';
import 'package:admin_app/views/lowestPrice/lowest_price.dart';
import 'package:admin_app/views/manageDrivers/manage_driver_details_screen.dart';
import 'package:admin_app/views/manageOrders/manage_orders.dart';
import 'package:admin_app/views/manageVendors/manage_vendors.dart';
import 'package:admin_app/views/subCategory/subcategory_screen.dart';
import 'package:admin_app/views/trendingStore/trending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common/analysis_box_widget.dart';
import '../../constants/constants.dart';

class AppSideAdminDashBoardScreen extends StatefulWidget {
  const AppSideAdminDashBoardScreen({super.key});

  @override
  State<AppSideAdminDashBoardScreen> createState() =>
      _AppSideAdminDashBoardScreenState();
}

class _AppSideAdminDashBoardScreenState
    extends State<AppSideAdminDashBoardScreen> {
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kTertiary,
          title: const Text("Welcome Back Admin"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: kWhite,
                ),
                child: Image.asset("assets/logo_rm.png", fit: BoxFit.cover),
              ),
              buildListTile(Icons.people, "Customers", () {}),
              buildListTile(Icons.people, "Drivers",
                  () => Get.to(() => ManageDriversScreen())),
              buildListTile(Icons.people, "Vendors",
                  () => Get.to(() => ManageVendorsScreen())),
              buildListTile(Icons.people, "Trending Store",
                  () => Get.to(() => TrendingStore())),
              buildListTile(Icons.people, "Lowest Price",
                  () => Get.to(() => LowestPriceScreen())),
              buildListTile(Icons.category, "Categories",
                  () => Get.to(() => CategoriesScreen())),
              buildListTile(Icons.category, "Sub-Categories",
                  () => Get.to(() => SubCategoriesScreen())),
              buildListTile(FontAwesomeIcons.list, "Items",
                  () => Get.to(() => ManageItemsScreen())),
              buildListTile(FontAwesomeIcons.cartShopping, "Orders",
                  () => Get.to(() => ManageOrdersScreen())
                  // () => Get.to(() => ManageOrdersScreen()),
                  ),
              buildListTile(Icons.bookmark_add_rounded, "Banners", () {}),
              buildListTile(Icons.airplane_ticket_outlined, "Coupons",
                  () => Get.to(() => ManageCouponsScreen())),
            ],
          ),
        ),
        body: buildBodySectionCode());
  }

  ListTile buildListTile(IconData icon, String text, void Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: kTertiary),
      title: Text(text, style: appStyle(18, kTertiary, FontWeight.w500)),
      onTap: onTap,
    );
  }

  Container buildBodySectionCode() {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 1,
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
                  // Get.to(() => const ManageOrdersScreen());
                },
                stream: FirebaseCollectionServices().ordersList,
                firstText: "Total Orders",
                icon: FontAwesomeIcons.list,
                containerColor: Colors.green,
              ),
// //================== Total Booking ===============================
              buildAnalysisBox(
                onTap: () {
                  // Get.to(() => const ManageOrdersScreen());
                },
                stream: FirebaseCollectionServices().pendingOrdersList,
                firstText: "Pending Orders",
                icon: FontAwesomeIcons.clipboardList,
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
