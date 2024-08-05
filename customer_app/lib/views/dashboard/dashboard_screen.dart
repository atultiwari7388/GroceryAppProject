import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/common/reusable_row_widget.dart';
import 'package:customer_app/views/dashboard/category/category_list.dart';
import 'package:customer_app/views/dashboard/lowestPrice/lowest_price_list.dart';
import 'package:customer_app/views/dashboard/trendingStore/trending_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shimmer/shimmer.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';
import '../address/address_management_screen.dart';
import '../profile/profile_screen.dart';
import 'category/all_category_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final TextEditingController searchController = TextEditingController();

  // bool _showMenu = false;
  String searchText = '';
  String appbarTitle = "";
  bool firstTimeAppLaunch = true; // Boolean flag to track first app launch
  bool isLocationSet = false;
  double userLat = 0.0;
  double userLong = 0.0;
  LocationData? currentLocation;

  @override
  void initState() {
    super.initState();
    checkIfLocationIsSet();
    // fetchNearByRestaurantsLocation();
  }

  Future<void> checkIfLocationIsSet() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('isLocationSet') &&
            data['isLocationSet'] == true) {
          // Location is already set, fetch the current address
          fetchCurrentAddress();
        } else {
          // Location is not set, fetch and update current location
          fetchUserCurrentLocationAndUpdateToFirebase();
        }
      } else {
        // Document doesn't exist, fetch and update current location
        fetchUserCurrentLocationAndUpdateToFirebase();
      }
    } catch (e) {
      log("Error checking location set status: $e");
    }
  }

  Future<void> fetchCurrentAddress() async {
    try {
      QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUId)
          .collection("Addresses")
          .where('isAddressSelected', isEqualTo: true)
          .get();

      if (addressSnapshot.docs.isNotEmpty) {
        var addressData =
            addressSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          appbarTitle = addressData['address'];
        });
      }
    } catch (e) {
      log("Error fetching current address: $e");
    }
  }

  //====================== Fetching user current location =====================
  void fetchUserCurrentLocationAndUpdateToFirebase() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      showToastMessage(
        "Location Error",
        "Please enable location Services",
        kRed,
      );
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      showToastMessage(
        "Error",
        "Please grant location permission in app settings",
        kRed,
      );
      // Open app settings to grant permission
      await loc.Location().requestPermission();
      permissionGranted = await location.hasPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    currentLocation = await location.getLocation();

    // Get the address from latitude and longitude
    String address = await _getAddressFromLatLng(
      "LatLng(${currentLocation!.latitude}, ${currentLocation!.longitude})",
    );
    log(address.toString());

    // Update the app bar with the current address
    setState(() {
      appbarTitle = address;
      log(appbarTitle);
      log(currentLocation!.latitude.toString());
      log(currentLocation!.longitude.toString());
      // Update the Firestore document with the current location
      saveUserLocation(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        appbarTitle,
      );
    });
  }

  void saveUserLocation(double latitude, double longitude, String userAddress) {
    FirebaseFirestore.instance.collection('Users').doc(currentUId).set({
      'isLocationSet': true,
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUId)
        .collection("Addresses")
        .add({
      'address': userAddress,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'addressType': "Current",
      "isAddressSelected": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kPrimary,
      appBar: buildCustomAppBar(context),
      body: Stack(
        children: [
          Stack(
            children: [
              //our body section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTopSearchBar(),
                      SizedBox(height: 10.h),
                      buildImageSlider(),
                      SizedBox(height: 10.h),
                      ReusableRowWidget(
                          headingName: "Categories",
                          onTap: () {
                            Get.to(
                              () => const AllCategoriesScreen(),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 900),
                            );
                          }),
                      SizedBox(height: 10.h),
                      const CategoryList(),
                      ReusableRowWidget(
                          headingName: "Lowest Price", onTap: () {}),
                      SizedBox(height: 5.h),
                      const LowestPriceList(),
                      // SizedBox(height: 10.h),
                      ReusableRowWidget(
                          headingName: "Trending Store", onTap: () {}),
                      SizedBox(height: 5.h),
                      const TrendingStoreScreenList(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 75.h,
                right: 12.w,
                child: buildCustomFloatingButton(),
              ),
            ],
          ),
        ],
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.left,
    );
  }

// ----------------------------------- Custom App bar ------------------------------
  PreferredSize buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(130.h),
      child: GestureDetector(
        onTap: () async {
          var selectedAddress = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressManagementScreen(
                userLat: userLat,
                userLng: userLong,
              ),
            ),
          );

          if (selectedAddress != null) {
            setState(() {
              appbarTitle = selectedAddress['address'];
            });
// Update the selected address in Firestore
            // Update the selected address in Firestore
            FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUId)
                .collection('Addresses')
                .get()
                .then((querySnapshot) {
              WriteBatch batch = FirebaseFirestore.instance.batch();

              for (var doc in querySnapshot.docs) {
                log("Selected Address Id : ${selectedAddress["id"]}");
                // Update all addresses to set isAddressSelected to false
                batch.update(doc.reference, {'isAddressSelected': false});
              }

              // Update the selected address to set isAddressSelected to true
              batch.update(
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(currentUId)
                    .collection('Addresses')
                    .doc(selectedAddress["id"]),
                {'isAddressSelected': true},
              );

              // Commit the batch write
              batch.commit().then((value) {
                // _onAddressChanged();
              });
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
          height: 90.h,
          width: MediaQuery.of(context).size.width,
          color: kOffWhite,
          child: Container(
            margin: EdgeInsets.only(top: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: 4.h, left: 5.w, top: 7.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReusableText(
                              text: "Delivery in",
                              style: appStyle(13, kDark, FontWeight.bold)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: Text(
                              appbarTitle.isEmpty
                                  ? "Fetching Addresses....."
                                  : appbarTitle,
                              overflow: TextOverflow.ellipsis,
                              style: appStyle(12, kDarkGray, FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icon(Icons.location_on, color: kSecondary, size: 35.sp),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const ProfileScreen(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 900)),
                  child: CircleAvatar(
                    radius: 19.r,
                    backgroundColor: kPrimary,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(currentUId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final profileImageUrl = data['profilePicture'] ?? '';
                        final userName = data['userName'] ?? '';

                        if (profileImageUrl.isEmpty) {
                          return Text(
                            userName.isNotEmpty ? userName[0] : '',
                            style: appStyle(20, kWhite, FontWeight.bold),
                          );
                        } else {
                          return ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              width: 38.r, // Set appropriate size for the image
                              height: 35.r,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------- Floating Action Button ------------------------------
  Widget buildCustomFloatingButton() {
    return SizedBox(
      width: 82.w,
      height: 82.h,
      child: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => const AllCategoriesScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 900),
          );
        },
        backgroundColor: kDark, // Customize button background color
        shape: const CircleBorder(), // Circular shape
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                'assets/category_packet_white.png',
                height: 35.h,
                width: 35.w,
                color: kWhite,
              ),
            ),
            SizedBox(height: 2.h), // Space between image and text
            Text('Categories', // Replace with your text
                style: appStyle(10, kWhite, FontWeight.normal)),
            SizedBox(height: 2.h), // Space between image and text
          ],
        ),
      ),
    );
  }

  /// -------------------------- Build Top Search Bar ----------------------------------*
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
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search by item name",
              prefixIcon: const Icon(Icons.search),
              prefixStyle: appStyle(14, kDark, FontWeight.w200)),
        ),
      ),
    );
  }

  /// --------------------------- Build Carousel Slider ----------------------------*
  Widget buildImageSlider() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("homeSliders")
          .where("active", isEqualTo: true)
          .orderBy("priority")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerEffect();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final sliderDocs = snapshot.data!.docs;
          return Container(
            height: 160.h,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey),
            ),
            child: CarouselSlider(
              items: sliderDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    data['img'],
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return _buildPlaceholder(); // Display placeholder while loading
                      }
                    },
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                enableInfiniteScroll: true,
                autoPlay: true,
                aspectRatio: 16 / 6.4,
                viewportFraction: 1,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child:
          CircularProgressIndicator(), // You can use any widget as a placeholder
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 160.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 120.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
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
