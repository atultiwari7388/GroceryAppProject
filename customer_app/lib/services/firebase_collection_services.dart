import 'package:cloud_firestore/cloud_firestore.dart';
import 'collection_ref.dart';

class FirebaseCollectionServices {
  //for orders collection
  final CollectionReference allOrdersList = FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUId)
      .collection("history");
}
