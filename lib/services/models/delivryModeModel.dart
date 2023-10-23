//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryModeModel {
  final String? id;
  final String? name;
  final String? duration;
  final String? rate;

  const DeliveryModeModel({
    this.id,
    this.name,
    this.duration,
    this.rate,
  });

  toJson() {
    return {
      "name": name,
      "duration": duration,
      "rate": rate,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory DeliveryModeModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return DeliveryModeModel(
      id: document.id,
      name: data["name"],
      duration: data["duration"],
      rate: data["rate"],
    );
  }

}