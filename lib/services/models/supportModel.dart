//Creating Support Model

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportModel {
  final String? id;
  final String? name;
  final String? email;
  final String? message;
  final String? subject;
  final String? status;
  final String? type;
  final String? ticketNumber;
  final String? dateCreated;
  final Timestamp? timeStamp;

  const SupportModel({
    this.id,
    this.name,
    this.email,
    this.message,
    this.subject,
    this.status,
    this.type,
    this.timeStamp,
    this.ticketNumber,
    this.dateCreated,
  });

  toJson() {
    return {
      "name": name,
      "email": email,
      "message": message,
      "type": type,
      "status": status,
      "subject": subject,
      "dateCreated": dateCreated,
      "ticketNumber": ticketNumber,
      "timeStamp": timeStamp,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory SupportModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return SupportModel(
      id: document.id,
      name: data["name"],
      email: data["email"],
      subject: data["subject"],
      type: data["type"],
      message: data["message"],
      dateCreated: data["dateCreated"],
      timeStamp: data["timeStamp"],
      status: data["status"],
      ticketNumber: data["ticketNumber"],
    );
  }

}