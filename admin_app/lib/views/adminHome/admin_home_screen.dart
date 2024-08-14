import 'package:admin_app/common/reusable_text.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/constants.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_style.dart';
import '../allergicIngredients/manage_allergicIngredients.dart';
import '../category/categories_screen.dart';
import '../coupons/manage_coupons_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../items/manage_items.dart';
import '../manageAddons/manage_addons.dart';
import '../manageBanners/manage_banners.dart';
import '../manageDrivers/manage_driver_details_screen.dart';
import '../manageOrders/manage_orders.dart';
import '../sizes/manage_sizes.dart';
import '../subCategory/subcategory_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String id = "admin-menu";

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Widget _selectedScreen = const DashboardScreen();

  screenSelector(item) {
    switch (item.route) {
      case DashboardScreen.id:
        setState(() {
          _selectedScreen = const DashboardScreen();
        });
        break;

      case CategoriesScreen.id:
        setState(() {
          _selectedScreen = const CategoriesScreen();
        });
        break;

      case SubCategoriesScreen.id:
        setState(() {
          _selectedScreen = const SubCategoriesScreen();
        });
        break;

      case ManageItemsScreen.id:
        setState(() {
          _selectedScreen = const ManageItemsScreen();
        });
        break;

      case ManageOrdersScreen.id:
        setState(() {
          _selectedScreen = const ManageOrdersScreen();
        });
        break;

      case ManageCouponsScreen.id:
        setState(() {
          _selectedScreen = const ManageCouponsScreen();
        });
        break;

      case ManageDriversScreen.id:
        setState(() {
          _selectedScreen = const ManageDriversScreen();
        });
        break;

      case ManageBanners.id:
        setState(() {
          _selectedScreen = const ManageBanners();
        });
        break;

      case ManageAddons.id:
        setState(() {
          _selectedScreen = const ManageAddons();
        });
        break;

      case ManageSizesScreen.id:
        setState(() {
          _selectedScreen = const ManageSizesScreen();
        });
        break;

      case ManageAllergicIngredients.id:
        setState(() {
          _selectedScreen = const ManageAllergicIngredients();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: kSecondary,
        elevation: 0,
        title: Row(
          children: [
            if (kIsWeb)
              Image.asset("assets/logo-no-background.png",
                  height: 100, width: 100),
            Visibility(
              child: ReusableText(
                  text: "Admin Panel",
                  style: appStyle(20, kWhite, FontWeight.normal)),
            ),
            Expanded(child: Container()),
            Container(
              width: 1,
              height: 22,
              color: kWhite,
            ),
            const SizedBox(width: 24),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to Logout."),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("No",
                            style: appStyle(16, kRed, FontWeight.normal)),
                      ),
                      TextButton(
                        onPressed: () => FirebaseServices().signOut(context),
                        child: Text("Yes",
                            style:
                                appStyle(16, Colors.green, FontWeight.normal)),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  ReusableText(
                      text: "LogOut",
                      style: appStyle(18, kWhite, FontWeight.normal)),
                  SizedBox(width: 10),
                  FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: kWhite),
                ],
              ),
            )
          ],
        ),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      sideBar: SideBar(
        textStyle: appStyle(16, kWhite, FontWeight.normal),
        iconColor: kWhite,
        backgroundColor: kSecondary,
        activeBackgroundColor: kWhite,
        activeIconColor: kWhite,
        items: const [
          AdminMenuItem(
            title: 'Dashboard',
            route: DashboardScreen.id,
            icon: FontAwesomeIcons.arrowTrendUp,
          ),
          AdminMenuItem(
            title: 'Categories',
            route: CategoriesScreen.id,
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: 'Sub Categories',
            route: SubCategoriesScreen.id,
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: 'Manage Items',
            route: ManageItemsScreen.id,
            icon: Icons.list,
          ),
          AdminMenuItem(
            title: 'Manage Orders',
            route: ManageOrdersScreen.id,
            icon: Icons.shopping_cart,
          ),
          AdminMenuItem(
            title: 'Manage Coupons',
            route: ManageCouponsScreen.id,
            icon: Icons.airplane_ticket_outlined,
          ),
          AdminMenuItem(
            title: 'Manage Drivers',
            route: ManageDriversScreen.id,
            icon: Icons.directions_bike,
          ),
          AdminMenuItem(
            title: 'Manage Banners',
            route: ManageBanners.id,
            icon: Icons.airplane_ticket,
          ),
          AdminMenuItem(
            title: 'Manage Addons',
            route: ManageAddons.id,
            icon: Icons.directions_bike,
          ),
          AdminMenuItem(
            title: 'Manage Sizes',
            route: ManageSizesScreen.id,
            icon: Icons.directions_bike,
          ),
          AdminMenuItem(
            title: 'Manage Ingredients',
            route: ManageAllergicIngredients.id,
            icon: Icons.directions_bike,
          ),
        ],
        selectedRoute: AdminHomeScreen.id,
        onSelected: (item) {
          screenSelector(item);
        },
        footer: Container(
          height: 50,
          width: double.infinity,
          // color: const Color(0xff444444),
          color: kSecondary,
          child: Center(
            child: Text(
              DateTimeFormat.format(DateTime.now(),
                  format: AmericanDateFormats.dayOfWeek),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(child: _selectedScreen),
    );
  }
}
