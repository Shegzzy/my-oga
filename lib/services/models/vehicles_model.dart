import 'package:cloud_firestore/cloud_firestore.dart';

class VehiclesModel {
  final String? id;
  final String? name;

  const VehiclesModel({
    this.id,
    this.name,
  });

  toJson() {
    return {
      "name": name,
    };
  }

  factory VehiclesModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return VehiclesModel(
      id: document.id,
      name: data["name"],
    );
  }

}