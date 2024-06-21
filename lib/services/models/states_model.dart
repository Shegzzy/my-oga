import 'package:cloud_firestore/cloud_firestore.dart';

class StatesModel {
  final String? id;
  final String? name;

  const StatesModel({
    this.id,
    this.name,
  });

  toJson() {
    return {
      "name": name,
    };
  }

  factory StatesModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return StatesModel(
      id: document.id,
      name: data["name"],
    );
  }

}