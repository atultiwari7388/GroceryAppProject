import 'dart:developer';
import 'package:admin_app/services/firebase_collection_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';

class ManageAllergicIngredients extends StatefulWidget {
  static const String id = "allergic_ingredients_screen";

  const ManageAllergicIngredients({super.key});

  @override
  State<ManageAllergicIngredients> createState() =>
      _ManageAllergicIngredientsState();
}

class _ManageAllergicIngredientsState extends State<ManageAllergicIngredients> {
  final TextEditingController searchController = TextEditingController();
  late Stream<DocumentSnapshot> _allergicIngredientsStream;
  int _perPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _allergicIngredientsStream = FirebaseCollectionServices()
        .allAllergicIngredients
        .doc('Wnn51jzyAKKCHPSfXsQY')
        .snapshots();
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
      _perPage += 10;
    });
  }

  void _showPopup({Map<String, dynamic>? item, required int index}) {
    final isEditing = item != null;
    final TextEditingController nameController = TextEditingController(
      text: isEditing ? item!['title'] : '',
    );
    final TextEditingController priorityController = TextEditingController(
      text: isEditing ? item!['priority'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Item' : 'Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priorityController,
                decoration: InputDecoration(labelText: 'Priority'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final priority = int.tryParse(priorityController.text) ?? 0;

                if (name.isNotEmpty) {
                  if (isEditing) {
                    _updateItem(index, name, priority);
                  } else {
                    _addItem(name, priority);
                  }
                  Navigator.pop(context);
                } else {
                  showToastMessage("Error", "Name cannot be empty", Colors.red);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addItem(String name, int priority) async {
    try {
      final docRef = FirebaseCollectionServices()
          .allAllergicIngredients
          .doc('Wnn51jzyAKKCHPSfXsQY');
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> items = data['items'] ?? [];

      items.add({
        'title': name,
        'priority': priority,
        'active': true,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      await docRef.update({'items': items});
      showToastMessage("Success", "Item added", Colors.green);
    } catch (e) {
      log("Error adding item: $e");
      showToastMessage("Error", "Error adding item", Colors.red);
    }
  }

  Future<void> _updateItem(int index, String name, int priority) async {
    try {
      final docRef = FirebaseCollectionServices()
          .allAllergicIngredients
          .doc('Wnn51jzyAKKCHPSfXsQY');
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> items = data['items'] ?? [];

      items[index]['title'] = name;
      items[index]['priority'] = priority;

      await docRef.update({'items': items});
      showToastMessage("Success", "Item updated", Colors.green);
    } catch (e) {
      log("Error updating item: $e");
      showToastMessage("Error", "Error updating item", Colors.red);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Allergic Ingredients",
                  style: appStyle(25, kDark, FontWeight.normal)),
              TextButton(
                onPressed: () => _showPopup(index: -1),
                child: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          buildHeadingRowWidgets(
              "Sr.no.", "Allergic Name", "Priority", "Actions", "Active"),
          StreamBuilder<DocumentSnapshot>(
            stream: _allergicIngredientsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> items = data['items'] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index] as Map<String, dynamic>;
                        final serialNumber = index + 1;
                        final categoryName = item["title"] ?? "";
                        final priority = item["priority"].toString();
                        final bool approved = item["active"];
                        final String categoryId = item["id"] ?? "";

                        return reusableRowWidget(
                          serialNumber.toString(),
                          categoryName,
                          priority.toString(),
                          approved,
                          index,
                          items,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: TextButton(
                          onPressed: _loadNextPage,
                          child: const Text("Next"),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTertiary,
        title: Text(
          "Allergic Ingredients",
          style: appStyle(18, kWhite, FontWeight.normal),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _showPopup(index: -1),
            child: const Text(
              'Add Item',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Allergic Ingredients",
                      style: appStyle(16, kDark, FontWeight.normal)),
                ],
              ),
              const SizedBox(height: 30),
              StreamBuilder<DocumentSnapshot>(
                stream: _allergicIngredientsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final List<dynamic> items = data['items'] ?? [];

                    return Table(
                      border: TableBorder.all(color: kDark, width: 1.0),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: kTertiary),
                          children: [
                            buildTableHeaderCell("Sr.No"),
                            buildTableHeaderCell("A'Name"),
                            buildTableHeaderCell("Priority"),
                            buildTableHeaderCell("Actions"),
                            buildTableHeaderCell("Active"),
                          ],
                        ),
                        for (int index = 0; index < items.length; index++) ...[
                          TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "${index + 1}",
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  items[index]["title"].toString(),
                                  style: appStyle(12, kDark, FontWeight.normal),
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  items[index]["priority"].toString(),
                                  textAlign: TextAlign.center,
                                  style: appStyle(12, kDark, FontWeight.normal),
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () => _showPopup(
                                          item: items[index], index: index),
                                      icon: const Icon(Icons.edit, color: kRed),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Switch(
                                  value: items[index]["active"],
                                  onChanged: (value) async {
                                    try {
                                      final docRef =
                                          FirebaseCollectionServices()
                                              .allAllergicIngredients
                                              .doc('Wnn51jzyAKKCHPSfXsQY');
                                      final doc = await docRef.get();
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final List<dynamic> items =
                                          data['items'] ?? [];
                                      items[index]['active'] = value;
                                      await docRef.update({'items': items});
                                    } catch (e) {
                                      log("Error updating active status: $e");
                                      showToastMessage(
                                          "Error",
                                          "Error updating active status",
                                          Colors.red);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: appStyle(12, kWhite, FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildHeadingRowWidgets(
      String id, String name, String email, String roles, String isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildHeaderWidget(id),
        buildHeaderWidget(name),
        buildHeaderWidget(email),
        buildHeaderWidget(roles),
        buildHeaderWidget(isActive),
      ],
    );
  }

  Widget buildHeaderWidget(String title) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: kTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          title,
          style: appStyle(12, kWhite, FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget reusableRowWidget(
    String id,
    String name,
    String priority,
    bool active,
    int index,
    List<dynamic> items,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildRowItemWidget(id),
        buildRowItemWidget(name),
        buildRowItemWidget(priority),
        buildRowItemWidgetWithActionButton(index, items),
        buildRowItemSwitch(active, index, items),
      ],
    );
  }

  Widget buildRowItemWidget(String data) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: kRed,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          data,
          style: appStyle(12, kDark, FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildRowItemWidgetWithActionButton(int index, List<dynamic> items) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: IconButton(
          onPressed: () => _showPopup(item: items[index], index: index),
          icon: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget buildRowItemSwitch(bool active, int index, List<dynamic> items) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: kRed,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Switch(
          value: active,
          onChanged: (value) async {
            try {
              final docRef = FirebaseCollectionServices()
                  .allAllergicIngredients
                  .doc('Wnn51jzyAKKCHPSfXsQY');
              final doc = await docRef.get();
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> items = data['items'] ?? [];
              items[index]['active'] = value;
              await docRef.update({'items': items});
            } catch (e) {
              log("Error updating active status: $e");
              showToastMessage(
                  "Error", "Error updating active status", Colors.red);
            }
          },
        ),
      ),
    );
  }
}



// import 'dart:developer';
// import 'package:admin_app/services/firebase_collection_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import '../../constants/constants.dart';
// import '../../utils/app_style.dart';
// import '../../utils/toast_msg.dart';

// class ManageAllergicIngredients extends StatefulWidget {
//   static const String id = "allergic_ingredients_screen";

//   const ManageAllergicIngredients({super.key});

//   @override
//   State<ManageAllergicIngredients> createState() =>
//       _ManageAllergicIngredientsState();
// }

// class _ManageAllergicIngredientsState extends State<ManageAllergicIngredients> {
//   final TextEditingController searchController = TextEditingController();
//   late Stream<DocumentSnapshot> _allergicIngredientsStream;
//   int _perPage = 10;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _allergicIngredientsStream = FirebaseCollectionServices()
//         .allAllergicIngredients
//         .doc('Wnn51jzyAKKCHPSfXsQY')
//         .snapshots();
//   }

//   void _loadNextPage() {
//     setState(() {
//       _currentPage++;
//       _perPage += 10;
//       // log(_currentPage.toString());
//       // log(_perPage.toString());
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb) {
//       return _buildWebLayout();
//     } else {
//       return _buildMobileLayout();
//     }
//   }

//   Widget _buildWebLayout() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       margin: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Allergic Ingredients",
//                   style: appStyle(25, kDark, FontWeight.normal)),
//             ],
//           ),
//           const SizedBox(height: 30),
//           SizedBox(height: 30),
//           buildHeadingRowWidgets(
//               "Sr.no.", "Allergic Name", "Priority", "Actions", "Active"),
//           StreamBuilder<DocumentSnapshot>(
//             stream: _allergicIngredientsStream,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 final data = snapshot.data!.data() as Map<String, dynamic>;
//                 final List<dynamic> items = data['items'] ?? [];

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: items.length,
//                       itemBuilder: (context, index) {
//                         final item = items[index] as Map<String, dynamic>;
//                         final serialNumber = index + 1;
//                         final categoryName = item["title"] ?? "";
//                         final priority = item["priority"].toString();
//                         final bool approved = item["active"];
//                         final String categoryId = item["id"] ?? "";

//                         return reusableRowWidget(
//                           serialNumber.toString(),
//                           categoryName,
//                           priority.toString(),
//                           approved,
//                           index,
//                           items,
//                         );
//                       },
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10.0),
//                       child: Center(
//                         child: TextButton(
//                           onPressed: _loadNextPage,
//                           child: const Text("Next"),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(child: Text("Error: ${snapshot.error}"));
//               } else {
//                 return const Center(child: CircularProgressIndicator());
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLayout() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kTertiary,
//         title: Text(
//           "Allergic Ingredients",
//           style: appStyle(18, kWhite, FontWeight.normal),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(5),
//           margin: const EdgeInsets.all(5),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Allergic Ingredients",
//                       style: appStyle(16, kDark, FontWeight.normal)),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               SizedBox(height: 30),
//               StreamBuilder<DocumentSnapshot>(
//                 stream: _allergicIngredientsStream,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     final data = snapshot.data!.data() as Map<String, dynamic>;
//                     final List<dynamic> items = data['items'] ?? [];

//                     return Table(
//                       border: TableBorder.all(color: kDark, width: 1.0),
//                       children: [
//                         TableRow(
//                           decoration: BoxDecoration(color: kTertiary),
//                           children: [
//                             buildTableHeaderCell("Sr.No"),
//                             buildTableHeaderCell("A'Name"),
//                             buildTableHeaderCell("Priority"),
//                             buildTableHeaderCell("Actions"),
//                             buildTableHeaderCell("Active"),
//                           ],
//                         ),
//                         for (int index = 0; index < items.length; index++) ...[
//                           TableRow(
//                             children: [
//                               TableCell(
//                                 child: Text(
//                                   "${index + 1}",
//                                 ),
//                               ),
//                               TableCell(
//                                 child: Text(
//                                   items[index]["title"].toString(),
//                                   style: appStyle(12, kDark, FontWeight.normal),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               TableCell(
//                                 child: Text(
//                                   items[index]["priority"].toString(),
//                                   style: appStyle(12, kDark, FontWeight.normal),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               TableCell(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {},
//                                       child: const Icon(Icons.edit,
//                                           color: Colors.green),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               TableCell(
//                                 child: Switch(
//                                   value: items[index]["active"],
//                                   onChanged: (value) {
//                                     _updateActiveStatus(index, value);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                         TableRow(
//                           children: [
//                             TableCell(
//                                 child:
//                                     SizedBox()), // This cell is for the pagination button
//                             TableCell(child: SizedBox()),
//                             TableCell(child: SizedBox()),
//                             TableCell(child: SizedBox()),
//                             TableCell(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Center(
//                                   child: TextButton(
//                                     onPressed: _loadNextPage,
//                                     child: const Text("Next"),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     );
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTableHeaderCell(String text) {
//     return TableCell(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.normal,
//             color: Colors.white,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget buildHeadingRowWidgets(String srNum, String categoryName,
//       String priority, String actions, String isActive) {
//     return Container(
//       padding:
//           const EdgeInsets.only(top: 18.0, left: 10, right: 10, bottom: 10),
//       decoration: BoxDecoration(
//         color: kDark,
//         borderRadius: BorderRadius.circular(7),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 1,
//             child:
//                 Text(srNum, style: appStyle(20, kSecondary, FontWeight.normal)),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(categoryName,
//                 style: appStyle(20, kSecondary, FontWeight.normal)),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(
//               priority,
//               style: appStyle(20, kSecondary, FontWeight.normal),
//               textAlign: TextAlign.left,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(
//               actions,
//               style: appStyle(20, kSecondary, FontWeight.normal),
//               textAlign: TextAlign.left,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(
//               isActive,
//               textAlign: TextAlign.center,
//               style: appStyle(20, kSecondary, FontWeight.normal),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget reusableRowWidget(
//     String serialNumber,
//     String categoryName,
//     String priority,
//     bool approved,
//     int index,
//     List<dynamic> items,
//   ) {
//     return Container(
//       padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
//       child: Column(
//         children: [
//           Container(
//             height: 0.5,
//             width: double.infinity,
//             color: kGrayLight,
//           ),
//           const SizedBox(height: 10),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   serialNumber,
//                   style: appStyle(18, kDark, FontWeight.normal),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   categoryName,
//                   style: appStyle(18, kDark, FontWeight.normal),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   priority,
//                   style: appStyle(18, kDark, FontWeight.normal),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     InkWell(
//                       onTap: () {},
//                       child: const Icon(
//                         Icons.edit,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Center(
//                   child: Switch(
//                     value: approved,
//                     onChanged: (value) {
//                       _updateActiveStatus(index, value);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _updateActiveStatus(int index, bool newStatus) async {
//     try {
//       final docRef = FirebaseCollectionServices()
//           .allAllergicIngredients
//           .doc('Wnn51jzyAKKCHPSfXsQY');
//       final doc = await docRef.get();
//       final data = doc.data() as Map<String, dynamic>;
//       final List<dynamic> items = data['items'] ?? [];

//       items[index]['active'] = newStatus;

//       await docRef.update({'items': items});
//       showToastMessage("Success", "Item updated", Colors.green);
//     } catch (e) {
//       log("Error updating status: $e");
//       showToastMessage("Error", "Error updating status", Colors.red);
//     }
//   }
// }
