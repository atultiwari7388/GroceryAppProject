// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<List<Map<String, dynamic>>> searchFirestore(String query) async {
//   List<Map<String, dynamic>> searchResults = [];

//   // Query Categories
//   QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
//       .collection('Categories')
//       .where('categoryName', isGreaterThanOrEqualTo: query)
//       .where('categoryName', isLessThanOrEqualTo: query + '\uf8ff')
//       .get();

//   for (var doc in categorySnapshot.docs) {
//     searchResults.add({'type': 'category', 'data': doc.data()});
//   }

//   // Query Item Names
//   QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
//       .collection('Items')
//       .where('title', isGreaterThanOrEqualTo: query)
//       .where('title', isLessThanOrEqualTo: query + '\uf8ff')
//       .get();

//   for (var doc in itemSnapshot.docs) {
//     searchResults.add({'type': 'item', 'data': doc.data()});
//   }

//   return searchResults;
// }
