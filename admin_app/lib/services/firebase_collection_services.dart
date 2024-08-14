import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCollectionServices {
  //for users Collection
  final Stream<QuerySnapshot> usersList =
      FirebaseFirestore.instance.collection('Users').snapshots();

  final Stream<QuerySnapshot> managerList =
      FirebaseFirestore.instance.collection('Managers').snapshots();

  final Stream<QuerySnapshot> driverList =
      FirebaseFirestore.instance.collection('Drivers').snapshots();

  final Stream<QuerySnapshot> ordersList =
      FirebaseFirestore.instance.collection('orders').snapshots();

  final Stream<QuerySnapshot> pendingOrdersList = FirebaseFirestore.instance
      .collection('orders')
      .where("status", isEqualTo: 0)
      .snapshots();

//for managers collection
  final CollectionReference allManagersList =
      FirebaseFirestore.instance.collection("Managers");

  //for restaurants collection
  final CollectionReference allRestaurantList =
      FirebaseFirestore.instance.collection("Restaurants");

  //for categories collection
  final CollectionReference allCategoriesList =
      FirebaseFirestore.instance.collection("Categories");
// for subcategories collection
  final CollectionReference allSubCategoriesList =
      FirebaseFirestore.instance.collection("SubCategories");

// for items collection
  final CollectionReference allItemsList =
      FirebaseFirestore.instance.collection("Items");
//for orders collection
  final CollectionReference allOrdersList =
      FirebaseFirestore.instance.collection("orders");
//for coupons collection
  final CollectionReference allCouponsList =
      FirebaseFirestore.instance.collection("coupons");

  //for coupons collection
  final CollectionReference allDriversList =
      FirebaseFirestore.instance.collection("Drivers");

  //for coupons collection
  final CollectionReference allVendorsList =
      FirebaseFirestore.instance.collection("Vendors");

  //for coupons collection
  final CollectionReference allCustomersList =
      FirebaseFirestore.instance.collection("Users");

  //for coupons collection
  final CollectionReference allBannerList =
      FirebaseFirestore.instance.collection("homeSliders");

  //for coupons collection
  final CollectionReference allAddonsList =
      FirebaseFirestore.instance.collection("AddOns");

  //for sizes collection
  final CollectionReference allSizesList =
      FirebaseFirestore.instance.collection("sizes");

  //for categories collection
  final CollectionReference allAllergicIngredients =
      FirebaseFirestore.instance.collection("allergicIngredients");

  //for coupons collection
  final CollectionReference allPaymentsList =
      FirebaseFirestore.instance.collection("Payments");
}



// import 'package:cloud_firestore/cloud_firestore.dart';


// class FirebaseCollectionServices {
//   //for users Collection
//   final Stream<QuerySnapshot> usersList =
//       FirebaseFirestore.instance.collection('Users').snapshots();

//   final Stream<QuerySnapshot> managerList =
//       FirebaseFirestore.instance.collection('Managers').snapshots();

//   final Stream<QuerySnapshot> driverList =
//       FirebaseFirestore.instance.collection('Drivers').snapshots();

//   final Stream<QuerySnapshot> ordersList =
//       FirebaseFirestore.instance.collection('orders').snapshots();

//   final Stream<QuerySnapshot> pendingOrdersList = FirebaseFirestore.instance
//       .collection('orders')
//       .where("status", isEqualTo: 0)
//       .snapshots();

// //for managers collection
//   final CollectionReference allManagersList =
//       FirebaseFirestore.instance.collection("Managers");

//   //for restaurants collection
//   final CollectionReference allRestaurantList =
//       FirebaseFirestore.instance.collection("Restaurants");

//   //for categories collection
//   final CollectionReference allCategoriesList =
//       FirebaseFirestore.instance.collection("Categories");
// // for subcategories collection
//   final CollectionReference allSubCategoriesList =
//       FirebaseFirestore.instance.collection("SubCategories");

// // for items collection
//   final CollectionReference allItemsList =
//       FirebaseFirestore.instance.collection("Items");
// //for orders collection
//   final CollectionReference allOrdersList =
//       FirebaseFirestore.instance.collection("orders");
// //for coupons collection
//   final CollectionReference allCouponsList =
//       FirebaseFirestore.instance.collection("coupons");

//   //for coupons collection
//   final CollectionReference allDriversList =
//       FirebaseFirestore.instance.collection("Drivers");

//   //for coupons collection
//   final CollectionReference allVendorsList =
//       FirebaseFirestore.instance.collection("Vendors");

//   //for coupons collection
//   final CollectionReference allCustomersList =
//       FirebaseFirestore.instance.collection("Users");

//   //for coupons collection
//   final CollectionReference allBannerList =
//       FirebaseFirestore.instance.collection("homeSliders");

//   //for coupons collection
//   final CollectionReference allPaymentsList =
//       FirebaseFirestore.instance.collection("Payments");
// }
