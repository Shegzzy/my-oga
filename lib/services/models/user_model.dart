//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? fullname;
  final String? email;
  final String? password;
  final String? phoneNo;
  final String? address;
  final String? profilePic;
  final String? gender;
  final String? dateOfBirth;
  final String? token;
  final Timestamp? timeStamp;
  final String? dateCreated;

  const UserModel({
    this.id,
    this.fullname,
    this.email,
    this.password,
    this.phoneNo,
    this.address,
    this.profilePic,
    this.gender,
    this.dateOfBirth,
    this.token,
    this.timeStamp,
    this.dateCreated,
  });

  toJson() {
    return {
      "FullName": fullname,
      "Email": email,
      "Password": password,
      "Phone": phoneNo,
      "Address": address,
      "Profile Photo": profilePic,
      "Gender": gender,
      "Date of Birth": dateOfBirth,
      "Token": token,
      "timeStamp": timeStamp,
      "Date Created": dateCreated,
    };
  }

  ///Getting User Info Mapping
  
  /// Map user fetched from Firebase to UserModel

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      email: data["Email"],
      password: data["Password"],
      fullname: data["FullName"],
      phoneNo: data["Phone"],
      address: data["Address"],
      profilePic: data["Profile Photo"],
      gender: data["Gender"],
      dateOfBirth: data["Date of Birth"],
      token: data["Token"],
      timeStamp: data["timeStamp"],
      dateCreated: data["Date Created"],
    );
  }

}