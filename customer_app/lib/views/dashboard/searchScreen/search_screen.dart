import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/constants.dart';
import '../foodTile/food_tile.dart';

class SearchScreen extends StatefulWidget {
  final String subCategoryName;
  final String subCategoryId;
  const SearchScreen(
      {super.key, required this.subCategoryName, required this.subCategoryId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        backgroundColor: kWhite,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_sharp, color: kDark),
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search in ${widget.subCategoryName}',
            border: InputBorder.none,
            hintStyle: TextStyle(color: kDark.withOpacity(0.5)),
          ),
          style: const TextStyle(color: kDark),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Items")
            .where("subCategoryId", isEqualTo: widget.subCategoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            final items = snapshot.data!.docs.where((doc) => doc['title']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()));

            if (items.isEmpty) {
              return Center(
                child: Lottie.asset("assets/no-data-found.json",
                    repeat: true, height: 320.h),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final itemDoc = items.elementAt(index).data();
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 18.0, right: 18, top: 10),
                  child: FoodTileWidget(food: itemDoc),
                );
              },
            );
          }
        },
      ),
    );
  }
}
