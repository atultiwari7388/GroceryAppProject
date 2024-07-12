import 'package:cloud_firestore/cloud_firestore.dart';

Stream<int> getCartItemCountStream(String userId) {
  // Access Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Reference to the user's document
  DocumentReference userRef = firestore.collection('Users').doc(userId);
  // Reference to the user's cart subcollection
  CollectionReference cartRef = userRef.collection('cart');
  // Create a stream that listens to changes in the cart subcollection
  return cartRef.snapshots().map((snapshot) => snapshot.docs.length);
}
