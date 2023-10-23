import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../views/Package_Type/package_type_screen.dart';

class PackageDetails{
  final String? id;
  final String? packageHeight;
  final String? packageWeight;
  final String? packageWidth;
  final String? additionalDetails;
  final String? packageType;
  final String? paymentType;
  final String? customerId;

  PackageDetails({
    this.id,
    this.packageHeight,
    this.packageWeight,
    this.packageWidth,
    this.additionalDetails,
    this.packageType,
    this.paymentType,
    this.customerId,
  });

  ///Saving to Firestore Database

  toJson(){
    return{
      "Package Height": packageHeight,
      "Package Weight": packageWeight,
      "Package Width": packageWidth,
      "Package Type": packageType,
      "Additional Details": additionalDetails,
      "Payment Method": paymentType,
      "Customer": customerId,
    };
  }

  /// Map details fetched from Firebase to PackageModel

  factory PackageDetails.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return PackageDetails(
      id: document.id,
      packageWeight: data["Package Weight"],
      packageHeight: data["Package Height"],
      packageWidth: data["Package Width"],
      packageType: data["Package Type"],
      additionalDetails: data["Additional Details"],
      customerId: data["Customer"],
    );
  }

}