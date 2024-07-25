import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../services/collection_refrences.dart';
import '../../utils/app_style.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';
import '../../utils/toast_msg.dart';
import '../orderHistory/order_history_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.setTab});
  final Function? setTab;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool online = false;
  String appbarTitle = "";
  //for salaried
  num totalOrders = 0;
  num todaysOrder = 0;
  num thisMonthOrder = 0;

  //for commission
  num todayEarning = 0;
  num totalEarning = 0;
  num withdrawAmount = 0;

  num pendingOrders = 0;
  String cType = 'Salaried'; // Default value

  @override
  void initState() {
    super.initState();
    _fetchOnlineStatus();
    fetchUserCurrentLocationAndUpdateToFirebase();
  }

// Fetch initial online status and cType from Firestore
  void _fetchOnlineStatus() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(currentUId)
        .get();
    setState(() {
      online = snapshot['active'] ?? false;
      cType = snapshot['cType'] ??
          'Salaried'; // Default to 'Salary' if cType is not found
      log("Selected CType: " + cType);
    });
    _fetchOrdersData(); // Fetch orders data after getting the cType
  }

  void fetchUserCurrentLocationAndUpdateToFirebase() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      showToastMessage(
          "Location Error", "Please enable location Services", kRed);
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      showToastMessage(
          "Error", "Please grant location permission in app settings", kRed);
      // Open app settings to grant permission
      await loc.Location().requestPermission();
      permissionGranted = await location.hasPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    loc.LocationData locationData = await location.getLocation();

    // Get the address from latitude and longitude
    String address = await _getAddressFromLatLng(
        "LatLng(${locationData.latitude}, ${locationData.longitude})");
    print(address);

    // Update the app bar with the current address
    setState(() {
      appbarTitle = address;
      log(appbarTitle);
      log(locationData.latitude.toString());
      log(locationData.longitude.toString());
      // Update the Firestore document with the current location
      saveUserLocation(
          locationData.latitude!, locationData.longitude!, appbarTitle);
      saveUserStatus(online);
    });
  }

  void saveUserLocation(double latitude, double longitude, String userAddress) {
    FirebaseFirestore.instance.collection('Drivers').doc(currentUId).update({
      'address': userAddress,
      "location": {
        'latitude': latitude,
        'longitude': longitude,
      }
    });
  }

  // Toggle active status
  void _toggleActive(bool value) {
    setState(() {
      online = value;
      // Update active status in Firestore
      saveUserStatus(value);
    });
  }

  // Save active status in Firestore
  void saveUserStatus(bool active) {
    FirebaseFirestore.instance.collection('Drivers').doc(currentUId).update({
      'active': active,
    });
  }

  // Fetch total and pending orders data from Firestore
  Future _fetchOrdersData() async {
    if (cType == 'Salaried') {
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(currentUId)
          .get();

      QuerySnapshot thisMonthOrders = await FirebaseFirestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: currentUId)
          .get();

      QuerySnapshot pendingOrdersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: currentUId)
          .where('status', whereIn: [2, 3, 4]).get();

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot todaysOrdersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('driverId', isEqualTo: currentUId)
          .where('orderDate', isGreaterThanOrEqualTo: startOfDay)
          .where('orderDate', isLessThanOrEqualTo: endOfDay)
          .get();

      setState(() {
        // pendingOrders = pendingOrdersSnapshot.docs.length;
        todaysOrder = todaysOrdersSnapshot.docs.length;
        thisMonthOrder = thisMonthOrders.docs.length;
        totalOrders = driverSnapshot['totalEarning'] ?? 0;

        log("Total Orders: " + totalOrders.toString());
        log("Pending Orders: " + pendingOrdersSnapshot.docs.length.toString());
        log("Today Orders: " + todaysOrdersSnapshot.docs.length.toString());
      });
    } else if (cType == 'Commission') {
      // Fetch earnings data
      // Assuming you have fields like 'todaysEarnings' and 'totalEarnings' in the driver's document
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(currentUId)
          .get();

      setState(() {
        todaysOrder = driverSnapshot['todaysOrder'] ?? 0;
        todayEarning = driverSnapshot['todaysEarning'] ?? 0;
        totalEarning = driverSnapshot['totalEarning'] ?? 0;
        totalOrders = driverSnapshot['totalOrders'] ?? 0;
        withdrawAmount = driverSnapshot['withdrawlAmount'] ?? 0;

        log("Today's Earnings: " + todayEarning.toString());
        log("Total Earnings: " + totalEarning.toString());
        log("Withdraw Amount: " + withdrawAmount.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 1,
        title: ReusableText(
            text: "Dashboard",
            style: appStyle(17, kSecondary, FontWeight.bold)),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("OFF", style: TextStyle(fontSize: 12.sp, color: kRed)),
              Switch(
                value: online,
                onChanged: (value) {
                  _toggleActive(value);
                },
                activeColor: kSecondary,
              ),
              Text("ON", style: TextStyle(fontSize: 12.sp, color: kDark)),
              SizedBox(width: 10.w)
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 12.h),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              cType == 'Salaried'
                  ? Column(
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem(
                              "Today Orders", todaysOrder.toString(), kPrimary),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem("Thismonth Orders",
                              thisMonthOrder.toString(), kRed),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () {
                            widget.setTab?.call(1);
                          },
                          child: _compactDashboardItem("Total Orders",
                              totalOrders.toString(), Colors.green),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem("Today's Order",
                              todaysOrder.toString(), kPrimary),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem(
                              "Todays Earnings", todayEarning.toString(), kRed),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem("Withdraw Amount",
                              withdrawAmount.toString(), kTertiary),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => Get.to(() => OrderHistoryScreen()),
                          child: _compactDashboardItem("Total Earnings",
                              totalEarning.toString(), kPrimary),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactDashboardItem(String title, String value, Color color) {
    return Container(
      height: 180.h,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: appStyle(26, kWhite, FontWeight.bold)),
          SizedBox(height: 10.h),
          Text(value, style: appStyle(16, kWhite, FontWeight.bold)),
        ],
      ),
    );
  }

  //================= Convert latlang to actual address =========================
  Future<String> _getAddressFromLatLng(String latLngString) async {
    // Assuming latLngString format is 'LatLng(x.x, y.y)'
    final coords = latLngString.split(', ');
    final latitude = double.parse(coords[0].split('(').last);
    final longitude = double.parse(coords[1].split(')').first);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      final Placemark pm = placemarks.first;
      return "${pm.name}, ${pm.locality}, ${pm.administrativeArea}";
    }
    return '';
  }
}



// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:driver_app/services/collection_refrences.dart';
// import 'package:driver_app/utils/toast_msg.dart';
// import 'package:driver_app/views/orderHistory/order_history_screen.dart';
// import 'package:get/get.dart';
// import '../../common/reusable_text.dart';
// import '../../constants/constants.dart';
// import '../../utils/app_style.dart';
// import 'package:location/location.dart' as loc;
// import 'package:location/location.dart';
// import 'package:geocoding/geocoding.dart';

// class HomeDashboardScreen extends StatefulWidget {
//   const HomeDashboardScreen({super.key, required this.setTab});
//   final Function? setTab;

//   @override
//   State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
// }

// class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
//   bool online = false;
//   String appbarTitle = "";
//   int totalOrders = 0;
//   int todaysOrder = 0;
//   int pendingOrders = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrdersData();
//     fetchUserCurrentLocationAndUpdateToFirebase();
//     _fetchOnlineStatus();
//   }

// // Fetch initial online status from Firestore
//   void _fetchOnlineStatus() async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('Drivers')
//         .doc(currentUId)
//         .get();
//     setState(() {
//       online = snapshot['active'] ?? false;
//     });
//   }

//   void fetchUserCurrentLocationAndUpdateToFirebase() async {
//     loc.Location location = loc.Location();
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     // Check if location services are enabled
//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       showToastMessage(
//           "Location Error", "Please enable location Services", kRed);
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     // Check if location permissions are granted
//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == loc.PermissionStatus.denied) {
//       showToastMessage(
//           "Error", "Please grant location permission in app settings", kRed);
//       // Open app settings to grant permission
//       await loc.Location().requestPermission();
//       permissionGranted = await location.hasPermission();
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != loc.PermissionStatus.granted) {
//         return;
//       }
//     }

//     // Get the current location
//     loc.LocationData locationData = await location.getLocation();

//     // Get the address from latitude and longitude
//     String address = await _getAddressFromLatLng(
//         "LatLng(${locationData.latitude}, ${locationData.longitude})");
//     print(address);

//     // Update the app bar with the current address
//     setState(() {
//       appbarTitle = address;
//       log(appbarTitle);
//       log(locationData.latitude.toString());
//       log(locationData.longitude.toString());
//       // Update the Firestore document with the current location
//       saveUserLocation(
//           locationData.latitude!, locationData.longitude!, appbarTitle);
//       saveUserStatus(online);
//     });
//   }

//   void saveUserLocation(double latitude, double longitude, String userAddress) {
//     FirebaseFirestore.instance.collection('Drivers').doc(currentUId).update({
//       'address': userAddress,
//       "location": {
//         'latitude': latitude,
//         'longitude': longitude,
//       }
//     });
//   }

//   // Toggle active status
//   void _toggleActive(bool value) {
//     setState(() {
//       online = value;
//       // Update active status in Firestore
//       saveUserStatus(value);
//     });
//   }

//   // Save active status in Firestore
//   void saveUserStatus(bool active) {
//     FirebaseFirestore.instance.collection('Drivers').doc(currentUId).update({
//       'active': active,
//     });
//   }

//   // Fetch total and pending orders data from Firestore
//   Future _fetchOrdersData() async {
//     // Fetch total orders where managerId matches currentUId
//     QuerySnapshot totalOrdersSnapshot = await FirebaseFirestore.instance
//         .collection('orders')
//         .where('driverId', isEqualTo: currentUId)
//         // .where("status", isEqualTo: )
//         .get();

//     // Fetch pending orders where managerId matches currentUId and status is 1
//     QuerySnapshot pendingOrdersSnapshot = await FirebaseFirestore.instance
//         .collection('orders')
//         .where('driverId', isEqualTo: currentUId)
//         .where('status', whereIn: [2, 3, 4]).get();

//     // Get today's date range (start and end of the day)
//     DateTime now = DateTime.now();
//     DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
//     DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

//     // Fetch today's orders where managerId matches currentUId and orderDate is within today's range
//     QuerySnapshot todaysOrdersSnapshot = await FirebaseFirestore.instance
//         .collection('orders')
//         .where('driverId', isEqualTo: currentUId)
//         // .where("status", isEqualTo: 1)
//         .where('orderDate', isGreaterThanOrEqualTo: startOfDay)
//         .where('orderDate', isLessThanOrEqualTo: endOfDay)
//         .get();

//     setState(() {
//       totalOrders = totalOrdersSnapshot.docs.length;
//       pendingOrders = pendingOrdersSnapshot.docs.length;
//       todaysOrder = todaysOrdersSnapshot.docs.length;

//       log("Total Orders: " + totalOrdersSnapshot.docs.length.toString());
//       log("Pending Orders: " + pendingOrdersSnapshot.docs.length.toString());
//       log("Today  Orders: " + todaysOrdersSnapshot.docs.length.toString());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kWhite,
//         elevation: 1,
//         title: ReusableText(
//             text: "Dashboard", style: appStyle(17, kPrimary, FontWeight.bold)),
//         actions: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text("OFF", style: TextStyle(fontSize: 12.sp, color: kRed)),
//               Switch(
//                 value: online,
//                 onChanged: (value) {
//                   _toggleActive(value);
//                 },
//                 activeColor: kPrimary,
//               ),
//               Text("ON", style: TextStyle(fontSize: 12.sp, color: kDark)),
//               SizedBox(width: 10.w)
//             ],
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           margin: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 12.h),
//           padding: EdgeInsets.all(12),
//           child: Column(
//             children: [
//               SizedBox(height: 20.h),
//               GestureDetector(
//                 onTap: () => Get.to(() => OrderHistoryScreen()),
//                 child: _compactDashboardItem(
//                     "Today Orders", todaysOrder.toString(), kSecondary),
//               ),
//               SizedBox(height: 20.h),
//               GestureDetector(
//                 onTap: () => Get.to(() => OrderHistoryScreen()),
//                 child: _compactDashboardItem(
//                     "Total Orders", totalOrders.toString(), kRed),
//               ),
//               SizedBox(height: 20.h),
//               GestureDetector(
//                 // onTap: () => Get.to(() => OrderHistoryScreen()),
//                 onTap: () {
//                   widget.setTab?.call(1);
//                 },
//                 child: _compactDashboardItem(
//                     "Pending Orders", pendingOrders.toString(), Colors.green),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _compactDashboardItem(String title, String value, Color color) {
//     return Container(
//       height: 180.h,
//       width: double.maxFinite,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       padding: EdgeInsets.all(10.h),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(title,
//               textAlign: TextAlign.center,
//               style: appStyle(26, kWhite, FontWeight.bold)),
//           SizedBox(height: 10.h),
//           Text(value, style: appStyle(16, kWhite, FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   //================= Convert latlang to actual address =========================
//   Future<String> _getAddressFromLatLng(String latLngString) async {
//     // Assuming latLngString format is 'LatLng(x.x, y.y)'
//     final coords = latLngString.split(', ');
//     final latitude = double.parse(coords[0].split('(').last);
//     final longitude = double.parse(coords[1].split(')').first);

//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(latitude, longitude);

//     if (placemarks.isNotEmpty) {
//       final Placemark pm = placemarks.first;
//       return "${pm.name}, ${pm.locality}, ${pm.administrativeArea}";
//     }
//     return '';
//   }
// }
