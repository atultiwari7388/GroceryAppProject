import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/collection_reference.dart';
import '../../utils/app_style.dart';
import 'order_history_items.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.setTab});
  final Function? setTab;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  late Stream<QuerySnapshot> ordersStream;
  bool isVendorActive = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabsController;

  void switchTab(int index) {
    _tabsController.animateTo(index);
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _tabsController = TabController(length: 3, vsync: this);

    FirebaseFirestore.instance
        .collection("Vendors")
        .doc(currentUId)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        setState(() {
          isVendorActive = event.data()?["active"] ?? false;
        });

        if (isVendorActive) {
          ordersStream = FirebaseFirestore.instance
              .collection('orders')
              .where("venId", isEqualTo: currentUId)
              .snapshots();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kLightWhite,
          title: ReusableText(
            text: "Orders",
            style: appStyle(20, kPrimary, FontWeight.bold),
          ),
        ),
        body: isVendorActive
            ? buildOrderStreamSection()
            : buildInactiveDriverScreen(),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildOrderStreamSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: kPrimary,
                ),
                const SizedBox(height: 20),
                ReusableText(
                  text: "No orders found",
                  style: appStyle(20, kSecondary, FontWeight.bold),
                ),
              ],
            ),
          );
        }
        // Filter orders based on status
        List<Map<String, dynamic>> newOrders = [];
        List<Map<String, dynamic>> ongoingOrders = [];
        List<Map<String, dynamic>> completedOrders = [];

        // Extract orders data from the snapshot
        List<Map<String, dynamic>> orders = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Filter orders based on status
        newOrders = orders.where((order) => order['status'] == 0).toList();
        ongoingOrders = orders
            .where((order) => order['status'] >= 1 && order['status'] <= 4)
            .toList();
        completedOrders =
            orders.where((order) => order['status'] == 5).toList();

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                controller: _tabsController,
                labelColor: kSecondary,
                unselectedLabelColor: kGray,
                tabAlignment: TabAlignment.center,
                padding: EdgeInsets.zero,
                isScrollable: true,
                labelStyle: appStyle(16, kDark, FontWeight.normal),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 2.w, color: kPrimary), // Set your color here
                  insets: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                tabs: const [
                  Tab(text: "New"),
                  Tab(text: "Ongoing"),
                  Tab(text: "Complete/Cancel"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabsController,
                  children: [
                    _buildOrdersList(newOrders, 0),
                    _buildOrdersList(ongoingOrders, 1),
                    _buildOrdersList(completedOrders, 2),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildInactiveDriverScreen() {
    return Padding(
      padding: EdgeInsets.all(28.sp),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              size: 100,
              color: kPrimary,
            ),
            const SizedBox(height: 20),
            ReusableText(
              text: "Please activate the online button.",
              style: appStyle(17, kSecondary, FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, int status) {
    // Get the search query from the text controller
    final searchQuery = searchController.text.toLowerCase();

    // Filter orders based on orderId containing the search query
    final filteredOrders = orders.where((order) {
      final orderId = order["orderId"].toLowerCase();
      return orderId.contains(searchQuery);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          //filter and search bar section
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(child: buildTopSearchBar()),
                SizedBox(width: 5.w),
                FilterChip(
                    label: const Icon(Icons.calendar_month, color: kSecondary),
                    onSelected: (value) {})
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length,
            itemBuilder: (ctx, index) {
              final order = filteredOrders[index];
              final orderId = order["orderId"];
              final locationAddress = order["userDeliveryAddress"];
              final totalPrice = order["totalBill"];
              final userId = order["userId"];
              final status = order["status"];
              // final paymentMode = order["payMode"];
              // final GeoPoint geoPoint = order["restLocation"];
              final double userLat = order["userLat"];
              final double userLong = order["userLong"];
              final orderItems = order["orderItems"];
              final orderDate = DateTime.fromMillisecondsSinceEpoch(
                  order['orderDate'].millisecondsSinceEpoch);
              return HistoryScreenItems(
                orderId: orderId,
                location: locationAddress,
                totalPrice: totalPrice,
                userId: userId,
                status: status,
                userLat: userLat,
                userLong: userLong,
                orderItems: orderItems,
                switchTab: (index) => switchTab(index),
                orderDate: orderDate,
              );

              // return FutureBuilder(
              //     future: _getAddressFromLatLng(
              //         geoPoint.latitude, geoPoint.longitude),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return const Center(child: CircularProgressIndicator());
              //       }
              //       final address = snapshot.data ?? "Address not found";

              //     });
            },
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  /**-------------------------- Build Top Search Bar ----------------------------------**/
  Widget buildTopSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.h),
          border: Border.all(color: kGrayLight),
          boxShadow: const [
            BoxShadow(
              color: kLightWhite,
              spreadRadius: 0.2,
              blurRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: searchController,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search by #00001",
              prefixIcon: const Icon(Icons.search),
              prefixStyle: appStyle(14, kDark, FontWeight.w200)),
        ),
      ),
    );
  }

  //================= Convert latlang to actual address =========================
  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      final Placemark pm = placemarks.first;
      return "${pm.name}, ${pm.locality}, ${pm.administrativeArea}";
    }
    return '';
  }
}
