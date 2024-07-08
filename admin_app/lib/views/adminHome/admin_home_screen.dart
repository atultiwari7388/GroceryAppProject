import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String id = "admin-menu";

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Widget _selectedScreen = const DashboardScreen();

  // screenSelector(item) {
  //   switch (item.route) {
  //     case DashboardScreen.id:
  //       setState(() {
  //         _selectedScreen = const DashboardScreen();
  //       });
  //       break;
  //
  //     case ManageRestaurantScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageRestaurantScreen();
  //       });
  //       break;
  //
  //     case ManageManagerScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageManagerScreen();
  //       });
  //       break;
  //
  //     case CategoriesScreen.id:
  //       setState(() {
  //         _selectedScreen = const CategoriesScreen();
  //       });
  //       break;
  //
  //     case SubCategoriesScreen.id:
  //       setState(() {
  //         _selectedScreen = const SubCategoriesScreen();
  //       });
  //       break;
  //
  //     case ManageItemsScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageItemsScreen();
  //       });
  //       break;
  //
  //     case ManageOrdersScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageOrdersScreen();
  //       });
  //       break;
  //
  //     case ManageCouponsScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageCouponsScreen();
  //       });
  //       break;
  //
  //     case ManageDriversScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageDriversScreen();
  //       });
  //       break;
  //
  //     case ManageDriversSecondScreenTesting.id:
  //       setState(() {
  //         _selectedScreen = const ManageDriversSecondScreenTesting();
  //       });
  //       break;
  //
  //     case ManageCustomersScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManageCustomersScreen();
  //       });
  //       break;
  //
  //     case ManageBanners.id:
  //       setState(() {
  //         _selectedScreen = const ManageBanners();
  //       });
  //       break;
  //
  //     case ManagePaymentsScreen.id:
  //       setState(() {
  //         _selectedScreen = const ManagePaymentsScreen();
  //       });
  //       break;
  //
  //     case BirthdayAnniversaryScreen.id:
  //       setState(() {
  //         _selectedScreen = const BirthdayAnniversaryScreen();
  //       });
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: kDarkGray,
        elevation: 0,
        title: Row(
          children: [
            if (kIsWeb)
              Image.asset("assets/new-logo-admin.png", height: 100, width: 100),
            // const Visibility(
            //   child: CustomTextWidget(
            //     text: "Admin Panel",
            //     size: 20,
            //     color: kSecondary,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // Expanded(child: Container()),
            // Container(
            //   width: 1,
            //   height: 22,
            //   color: kWhite,
            // ),
            // const SizedBox(width: 24),
            // InkWell(
            //   onTap: () {
            //     showDialog(
            //       context: context,
            //       builder: (ctx) => AlertDialog(
            //         title: const Text("Logout"),
            //         content: const Text("Are you sure you want to Logout."),
            //         actions: <Widget>[
            //           TextButton(
            //             onPressed: () => Navigator.pop(context),
            //             child: Text("No",
            //                 style: appStyle(16, kRed, FontWeight.normal)),
            //           ),
            //           TextButton(
            //             onPressed: () => FirebaseServices().signOut(context),
            //             child: Text("Yes",
            //                 style:
            //                 appStyle(16, Colors.green, FontWeight.normal)),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            //   child: const Row(
            //     children: [
            //       CustomTextWidget(
            //         text: "LogOut",
            //         color: kSecondary,
            //       ),
            //       SizedBox(width: 10),
            //       FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: kWhite),
            //     ],
            //   ),
            // )
            //
          ],
        ),
        iconTheme: const IconThemeData(color: kSecondary),
      ),
      sideBar: SideBar(
        textStyle: appStyle(16, kSecondary, FontWeight.normal),
        iconColor: kSecondary,
        backgroundColor: kDarkGray,
        activeBackgroundColor: kWhite,
        activeIconColor: kWhite,
        // items: const [
        //   AdminMenuItem(
        //     title: 'Dashboard',
        //     route: DashboardScreen.id,
        //     icon: FontAwesomeIcons.arrowTrendUp,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Restaurants',
        //     route: ManageRestaurantScreen.id,
        //     icon: FontAwesomeIcons.hotel,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Managers',
        //     route: ManageManagerScreen.id,
        //     icon: FontAwesomeIcons.person,
        //   ),
        //   AdminMenuItem(
        //     title: 'Categories',
        //     route: CategoriesScreen.id,
        //     icon: Icons.category,
        //   ),
        //   AdminMenuItem(
        //     title: 'Sub Categories',
        //     route: SubCategoriesScreen.id,
        //     icon: Icons.category,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Items',
        //     route: ManageItemsScreen.id,
        //     icon: Icons.list,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Orders',
        //     route: ManageOrdersScreen.id,
        //     icon: Icons.shopping_cart,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Coupons',
        //     route: ManageCouponsScreen.id,
        //     icon: Icons.airplane_ticket_outlined,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Drivers',
        //     route: ManageDriversScreen.id,
        //     icon: Icons.directions_bike,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Drivers Second',
        //     route: ManageDriversSecondScreenTesting.id,
        //     icon: Icons.directions_bike,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Customers',
        //     route: ManageCustomersScreen.id,
        //     icon: Icons.people,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Banners',
        //     route: ManageBanners.id,
        //     icon: Icons.bookmark_add_rounded,
        //   ),
        //   AdminMenuItem(
        //     title: 'Manage Payments',
        //     route: ManagePaymentsScreen.id,
        //     icon: FontAwesomeIcons.indianRupeeSign,
        //   ),
        //   AdminMenuItem(
        //     title: 'Anniversary And Birthdays',
        //     route: BirthdayAnniversaryScreen.id,
        //     icon: FontAwesomeIcons.birthdayCake,
        //   ),
        // ],
        //
        selectedRoute: AdminHomeScreen.id,
        onSelected: (item) {
          // screenSelector(item);
        },
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: Center(
            child: Text(
              DateTimeFormat.format(DateTime.now(),
                  format: AmericanDateFormats.dayOfWeek),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ), items: [],
      ), body: Scaffold(),
      // body: SingleChildScrollView(child: _selectedScreen),
    );
  }
}
