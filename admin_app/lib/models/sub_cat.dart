import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategory {
  final String id;
  final String name;

  SubCategory({required this.id, required this.name});

  // Factory method to create SubCategory object from Firestore snapshot
  factory SubCategory.fromSnapshot(DocumentSnapshot snapshot) {
    return SubCategory(
      id: snapshot.id,
      name: snapshot['subCatName'],
    );
  }
}
