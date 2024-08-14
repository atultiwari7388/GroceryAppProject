import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import 'widgets/history_screen_items.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key, required this.setTab});
  final Function? setTab;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  late Stream<QuerySnapshot> ordersStream;
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

    ordersStream = FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUId)
        .collection("history")
        .orderBy("orderDate", descending: true)
        .snapshots();
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
            text: "History",
            style: appStyle(20, kPrimary, FontWeight.bold),
          ),
        ),
        body: buildOrderStreamSection(),
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

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, int status) {
    final searchQuery = searchController.text.toLowerCase();

    // Filter orders based on orderId containing the search query
    final filteredOrders = orders.where((order) {
      final orderId = order["orderId"].toLowerCase();
      return orderId.contains(searchQuery);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final cartItem = filteredOrders[index];
              final cartId = cartItem["orderId"];
              return HistoryScreenItems(cartItem: cartItem, cartId: cartId);
            },
          ),
          SizedBox(height: 105.h),
        ],
      ),
    );
  }
}




// body: StreamBuilder(
//         stream: FirebaseFirestore.instance

//             .collection("Users")
//             .doc(currentUId)
//             .collection("history")
//             .orderBy("orderDate", descending: true)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           // Check if cart is empty
//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('Your history is empty'));
//           }

//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final cartItem = snapshot.data!.docs[index];
//                     final cartId = cartItem["orderId"];
//                     return HistoryScreenItems(
//                         cartItem: cartItem, cartId: cartId);
//                   },
//                 ),
//                 SizedBox(height: 105.h),
//               ],
//             ),
//           );
     
//         },
//       ),