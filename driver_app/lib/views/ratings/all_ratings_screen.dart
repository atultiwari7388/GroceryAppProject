import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:driver_app/services/collection_refrences.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../utils/app_style.dart';

class AllRatingsScreen extends StatelessWidget {
  const AllRatingsScreen({super.key});

  Future<Map<String, dynamic>> fetchRatings() async {
    final userId =
        currentUId; // replace with your method of getting the current user ID
    final snapshot = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(userId)
        .collection('ratings')
        .get();

    if (snapshot.docs.isEmpty) {
      return {'ratings': [], 'averageRating': 0.0};
    }

    final ratings =
        snapshot.docs.map((doc) => doc.data()['rating'] as num).toList();
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

    return {'ratings': ratings, 'averageRating': averageRating};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightWhite,
        elevation: 0,
        title: ReusableText(
            text: "Your Ratings",
            style: appStyle(18, kDark, FontWeight.normal)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRatings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final ratings = data['ratings'] as List;
          final averageRating = data['averageRating'] as double;

          if (ratings.isEmpty) {
            return Center(child: Text("You don't have ratings."));
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Ratings: ${ratings.length}",
                  style: appStyle(16, kDark, FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 30.w,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                      style: appStyle(16, kDark, FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: ratings.length,
                //     itemBuilder: (context, index) {
                //       return ListTile(
                //         leading: Icon(Icons.star, color: Colors.amber),
                //         title: Text("Rating: ${ratings[index]}"),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
