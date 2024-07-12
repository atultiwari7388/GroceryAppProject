import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/collection_ref.dart';
import '../utils/app_style.dart';

void updateQuantity(String foodId, int newQuantity, num quantityPrice) {
  num newTotalPrice = newQuantity * quantityPrice;
  FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUId)
      .collection("cart")
      .doc(foodId)
      .update({
    "quantity": newQuantity,
    "totalPrice": newTotalPrice,
    "subTotalPrice": newTotalPrice,
    "quantityPrice": newTotalPrice, // Update totalPrice field
  });
}

void updateIncrementQuantity(
    String foodId, int newQuantity, num quantityPrice) {
  num newTotalPrice = newQuantity * quantityPrice;
  FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUId)
      .collection("cart")
      .doc(foodId)
      .update({
    "quantity": newQuantity,
    "totalPrice": newTotalPrice,
    "subTotalPrice": newTotalPrice,
    "quantityPrice": newTotalPrice, // Update totalPrice field
  });
}

void deleteItem(String foodId) {
  FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUId)
      .collection("cart")
      .doc(foodId)
      .delete()
      .then((value) {
    log("Item successfully deleted! $foodId");
  });
}

void showDeleteConfirmationDialog(BuildContext context, dynamic food) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:
            Text("Delete Item", style: appStyle(18, kPrimary, FontWeight.bold)),
        content: Text(
            "Are you sure you want to delete this item from your cart?",
            style: appStyle(16, kDark, FontWeight.normal)),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel", style: appStyle(13, kRed, FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Yes", style: appStyle(13, kSuccess, FontWeight.bold)),
            onPressed: () {
              deleteItem(food.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
