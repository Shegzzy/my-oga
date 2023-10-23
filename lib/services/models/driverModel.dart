//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String? id;
  final String? fullname;
  final String? email;
  final String? password;
  final String? phoneNo;
  final String? address;
  final String? profilePic;
  final String? gender;
  final String? dateOfBirth;
  final String? isVerified;
  final String? isOnline;
  final List? userDocuments;
  final String? userCompany;
  final String? vehicleColor;
  final String? vehicleNumber;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleType;
  final String? vehicleYear;
  final String? userState;
  final String? token;
  final String? currentLat;
  final String? currentLong;
  final String? currentAddress;

  const DriverModel({
    this.id,
    this.fullname,
    this.email,
    this.password,
    this.phoneNo,
    this.address,
    this.profilePic,
    this.gender,
    this.dateOfBirth,
    this.isVerified,
    this.isOnline,
    this.userDocuments,
    this.userCompany,
    this.vehicleColor,
    this.vehicleNumber,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleType,
    this.vehicleYear,
    this.userState,
    this.token,
    this.currentLat,
    this.currentLong,
    this.currentAddress,
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
      "Verified": isVerified,
      "Online": isOnline,
      "Documents": userDocuments,
      "Company": userCompany,
      "State": userState,
      "Vehicle Type": vehicleType,
      "Vehicle Make": vehicleMake,
      "Vehicle Model": vehicleModel,
      "Vehicle Year": vehicleYear,
      "Vehicle Number": vehicleNumber,
      "Vehicle Color": vehicleColor,
      "Token": token,
      "Driver Latitude": currentLat,
      "Driver Longitude": currentLong,
      "Driver Address": currentAddress,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory DriverModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return DriverModel(
      id: document.id,
      email: data["Email"],
      password: data["Password"],
      fullname: data["FullName"],
      phoneNo: data["Phone"],
      address: data["Address"],
      profilePic: data["Profile Photo"],
      gender: data["Gender"],
      dateOfBirth: data["Date of Birth"],
      isVerified: data["Verified"],
      isOnline: data["Online"],
      userDocuments: data["Documents"],
      userState: data["Country"],
      userCompany: data["Company"],
      vehicleColor: data["Vehicle Color"],
      vehicleNumber: data["Vehicle Number"],
      vehicleYear: data["Vehicle Year"],
      vehicleModel: data["Vehicle Model"],
      vehicleMake: data["Vehicle Make"],
      vehicleType: data["Vehicle Type"],
      token: data["Token"],
      currentLat: data["Driver Latitude"],
      currentLong: data["Driver Longitude"],
      currentAddress: data["Driver Address"],
    );
  }

}