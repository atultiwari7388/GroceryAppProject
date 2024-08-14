import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/constants/constants.dart';
import 'package:customer_app/utils/app_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../../controllers/lowest_price_controller.dart';
import '../../functions/get_cart_item_count_string.dart';
import '../../services/collection_ref.dart';
import '../checkout/checkout_screen.dart';
import '../dashboard/lowestPrice/widgets/lowest_price_widget.dart';

class VendorsDetailsScreen extends StatefulWidget {
  const VendorsDetailsScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  final String vendorId;
  final String vendorName;

  @override
  State<VendorsDetailsScreen> createState() => _VendorsDetailsScreenState();
}

class _VendorsDetailsScreenState extends State<VendorsDetailsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  void searchFromFirebase(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
          .collection('Items')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .where("venId", isEqualTo: widget.vendorId)
          .get();

      setState(() {
        searchResults = itemSnapshot.docs;
      });
    } else {
      setState(() {
        searchResults.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LowestPriceController());

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: kPrimary,
        title: Text(widget.vendorName,
            style: appStyle(18, kWhite, FontWeight.normal)),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, color: kWhite, size: 28.sp)),
        actions: [
          StreamBuilder<int>(
            stream: getCartItemCountStream(currentUId),
            builder: (context, snapshot) {
              int itemCount = snapshot.data ?? 0;
              return itemCount > 0
                  ? GestureDetector(
                      onTap: () => Get.to(() => const CheckoutScreen()),
                      child: Badge(
                        backgroundColor: kWhite,
                        textColor: kPrimary,
                        label: Text(itemCount.toString()),
                        child:
                            const Icon(AntDesign.shoppingcart, color: kWhite),
                      ),
                    )
                  : Container();
            },
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: Column(
        children: [
          buildTopSearchBar(),
          Expanded(
            child: searchResults.isNotEmpty
                ? buildGridView(searchResults, controller)
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Items')
                        .where('venId', isEqualTo: widget.vendorId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No items found'));
                      }
                      return buildGridView(snapshot.data!.docs, controller);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildTopSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 10.h),
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
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: searchController,
                onChanged: (value) => searchFromFirebase(value),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search by item name ",
                  prefixIcon: const Icon(Icons.search),
                  prefixStyle: appStyle(14, kDark, FontWeight.w200),
                ),
              ),
            ),
            if (searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  searchFromFirebase('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildGridView(
      List<DocumentSnapshot> items, LowestPriceController controller) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      padding: EdgeInsets.all(10.0),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final itemData = items[i].data() as Map<String, dynamic>;
        return Card(
          color: kTertiary.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LowestPriceListWidget(
                    lowestPriceController: controller,
                    lowestPrice: itemData,
                    index: i,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:customer_app/views/dashboard/lowestPrice/lowest_price_list.dart';
// import 'package:flutter/material.dart';
// import 'package:customer_app/constants/constants.dart';
// import 'package:customer_app/utils/app_style.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:get/get.dart';
// import '../../controllers/lowest_price_controller.dart';
// import '../../functions/get_cart_item_count_string.dart';
// import '../../services/collection_ref.dart';
// import '../checkout/checkout_screen.dart';
// import '../dashboard/lowestPrice/widgets/lowest_price_widget.dart';

// class VendorsDetailsScreen extends StatefulWidget {
//   const VendorsDetailsScreen({
//     super.key,
//     required this.vendorId,
//     required this.vendorName,
//   });

//   final String vendorId;
//   final String vendorName;

//   @override
//   State<VendorsDetailsScreen> createState() => _VendorsDetailsScreenState();
// }

// class _VendorsDetailsScreenState extends State<VendorsDetailsScreen> {
//   final TextEditingController searchController = TextEditingController();
//   String searchText = '';
//   List<DocumentSnapshot> searchResults = [];

//   void searchFromFirebase(String query) async {
//     if (query.isNotEmpty) {
//       // Fetch item names that match the search text
//       QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
//           .collection('Items')
//           .where('title', isGreaterThanOrEqualTo: query)
//           .where('title', isLessThanOrEqualTo: query + '\uf8ff')
//           .where("venId", isEqualTo: widget.vendorId)
//           .get();

//       setState(() {
//         searchResults = [
//           ...itemSnapshot.docs,
//         ];
//       });
//     } else if (query.isEmpty) {
//       // Clear results if the query is empty
//       setState(() {
//         searchResults.clear();
//         searchController.clear();
//       });
//     } else {
//       setState(() {
//         searchResults.clear();
//         searchController.clear();
//       });
//     }
//   }

//   void _performSearch(String searchQuery) {
//     if (searchQuery.isEmpty) {
//       setState(() {
//         searchResults.clear();
//         searchController.clear();
//       });
//     } else {
//       final results = searchResults.where((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final title = data['title']?.toLowerCase() ?? '';
//         return title.contains(searchQuery);
//       }).toList();

//       setState(() {
//         searchResults = results;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(LowestPriceController());

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: kPrimary,
//         title: Text(widget.vendorName,
//             style: appStyle(18, kWhite, FontWeight.normal)),
//         leading: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Icon(Icons.arrow_back_ios, color: kWhite, size: 28.sp)),
//         actions: [
//           StreamBuilder<int>(
//             stream: getCartItemCountStream(currentUId),
//             builder: (context, snapshot) {
//               int itemCount = snapshot.data ?? 0;
//               if (itemCount > 0) {
//                 return GestureDetector(
//                   onTap: () {
//                     Get.to(() => const CheckoutScreen());
//                   },
//                   child: Badge(
//                     backgroundColor: kWhite,
//                     textColor: kPrimary,
//                     label: Text(itemCount.toString()),
//                     child: const Icon(AntDesign.shoppingcart, color: kWhite),
//                   ),
//                 );
//               } else {
//                 return Container();
//               }
//             },
//           ),
//           SizedBox(width: 20.w),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('Items')
//             .where('venId', isEqualTo: widget.vendorId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No items found'));
//           }

//           final items = snapshot.data!.docs;

//           return GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Two items per row
//               crossAxisSpacing: 10.0, // Space between columns
//               mainAxisSpacing: 10.0, // Space between rows
//               childAspectRatio: 0.75, // Adjust this ratio as per your design
//             ),
//             padding: EdgeInsets.all(10.0), // Overall padding for the grid
//             itemCount: items.length,
//             itemBuilder: (ctx, i) {
//               final itemData = items[i].data();
//               return Card(
//                 color: kTertiary.withOpacity(0.1),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildTopSearchBar(),
//                       SizedBox(height: 10.h),
//                       Expanded(
//                         child: LowestPriceListWidget(
//                           lowestPriceController: controller,
//                           lowestPrice: itemData,
//                           index: i,
//                         ),
//                       ),
//                       // const Divider(color: Colors.grey, height: 1),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget buildTopSearchBar() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 10.h),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18.h),
//           border: Border.all(color: kGrayLight),
//           boxShadow: const [
//             BoxShadow(
//               color: kLightWhite,
//               spreadRadius: 0.2,
//               blurRadius: 1,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: searchController,
//                 onChanged: (value) {
//                   searchFromFirebase(value);
//                   _performSearch(value);
//                 },
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: "Search by item name or category name",
//                   prefixIcon: const Icon(Icons.search),
//                   prefixStyle: appStyle(14, kDark, FontWeight.w200),
//                 ),
//               ),
//             ),
//             if (searchController.text.isNotEmpty)
//               IconButton(
//                 icon: Icon(Icons.clear),
//                 onPressed: () {
//                   setState(() {
//                     searchController.clear();
//                     searchResults.clear();
//                   });
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     searchController.dispose();
//     searchResults.clear();
//   }
// }
