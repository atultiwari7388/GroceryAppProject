import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/constants.dart';
import '../services/collection_ref.dart';
import '../utils/toast_msg.dart';

Future<void> addToCart(Map<String, dynamic> foodItem, String docId) async {
  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;
  // Check if user is authenticated
  if (user != null) {
    // Reference to the user's cart collection
    CollectionReference cartCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUId)
        .collection('cart');
    // Add the food item details to the cart
    await cartCollection.doc(docId).set(foodItem).then((value) {
      showToastMessage("Cart", "Item added to cart", kSuccess);
    });
  } else {
    // User not authenticated, handle accordingly
    log('User not authenticated');
  }
}
