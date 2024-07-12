import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:vendor_app/views/home/home_screen.dart';
import 'package:vendor_app/views/items/items_screen.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int tab = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // PushNotification().init();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        loading = false;
      });
    } // Optionally handle the else case where the user is null
  }

  void setTab(int index) {
    setState(() {
      tab = index;
    });
  }

  final GlobalKey<ScaffoldState> _myGlobe = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(setTab: setTab),
      OrdersScreen(setTab: setTab),
      const ItemsScreen()
    ];

    return Scaffold(
      key: _myGlobe,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: tab,
              children: screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(AntDesign.home), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(AntDesign.shoppingcart), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(AntDesign.book), label: "Items"),
        ],
        currentIndex: tab,
        selectedItemColor: kSecondary,
        selectedLabelStyle: appStyle(12, kSecondary, FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            tab = index;
          });
        },
      ),
    );
  }
}
