//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTypeModel {
  final String? id;
  final String? name;

  const SupportTypeModel({
    this.id,
    this.name,
  });

  toJson() {
    return {
      "name": name,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory SupportTypeModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return SupportTypeModel(
      id: document.id,
      name: data["name"],
    );
  }

}