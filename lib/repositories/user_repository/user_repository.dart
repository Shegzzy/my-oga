
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/models/booking_model.dart';
import '../../services/models/delivryModeModel.dart';
import '../../services/models/driverModel.dart';
import '../../services/models/orderStatusModel.dart';
import '../../services/models/package_details_model.dart';
import '../../services/models/supportModel.dart';
import '../../services/models/user_model.dart';


//Here performs the database operations

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  User? userId = FirebaseAuth.instance.currentUser;


  ///Stores users info in FireStore
  createUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("aUserID")!;
    await _db.collection("Users").doc(userID).set(user.toJson()).whenComplete(() => Get.snackbar(
        "Success", "Your account have been created.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
          Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
    });
  }

  ///Fetch  User Details
  Future<UserModel> getUserDetailsWithPhone(String phone) async {
    final snapshot = await _db.collection("Users").where("Phone", isEqualTo: phone).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).first;
    return userData;
  }

  ///Fetch  User Details
  Future<UserModel> getUserDetailsWithEmail(String email) async {
    final snapshot = await _db.collection("Users").where("Email", isEqualTo: email).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).first;
    return userData;
  }


  ///Fetch All Users
  Future<List<UserModel>> getAllUserDetails() async {
    final snapshot = await _db.collection("Users").get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  ///Updating User Details
  Future<void> updateUserRecord(UserModel user) async {
    final phone = userId!.phoneNumber;
    final email = userId!.email;
    if(email != null){
      UserModel userInfo = await getUserDetailsWithEmail(email);
      await _db.collection("Users").doc(userInfo.id).update(user.toJson()).then((value) => Get.snackbar(
          "Good", "Details Updated Successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green),
      ).catchError((error, setTrack){
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });
    }
    else {
      UserModel userInfo = await getUserDetailsWithPhone(phone!);
      await _db.collection("Users").doc(userInfo.id).update(user.toJson());
    }
  }

  ///Updating Phone Number
  Future<void> updatePhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("aUserID")!;
    await _db.collection("Users").doc(userID).update({'Phone': phone}).then((value) => Get.snackbar(
        "Good", "Phone Number Accepted",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.green),
    ).catchError((error, setTrack){
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }

  ///Updating Password
  Future<void> updatePassword(String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("userID")!;
    await _db.collection("Users").doc(userID).update({'Password': pass}).then((value) => Get.snackbar(
        "Good", "Password Updated Successfully, Login Again",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.green),
    ).catchError((error, setTrack){
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }

  ///Saving Booking Information
  saveBookingRequest(BookingModel bookings) async {
    ///FirebaseDatabase.instance.ref().child('Booking Request').push();
    await _db.collection("Bookings").add(bookings.toJson()).whenComplete(() => Get.snackbar(
        "Success", "Your booking have been received",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Colors.red);
    });
  }

  ///Saving Package Details
  savePackageDetail(PackageDetails package) async {
    await _db.collection("Packages").add(package.toJson()).whenComplete(() => Get.snackbar(
        "Success", "Package Details Received",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    });
  }

  ///Retrieving Package Details From Database
  Future<List<PackageDetails>>getPackageDetails() async {
    final email = userId!.email;
    UserModel userInfo = await getUserDetailsWithEmail(email!);
    final snapshot = await _db.collection("Packages").where("Customer", isEqualTo: userInfo.id).get();
    final packageData = snapshot.docs.map((e) => PackageDetails.fromSnapshot(e)).toList();
    return packageData;
  }

  ///Retrieving Booking Details From Database
  Future<List<BookingModel>?>getUserBookingDetails() async {
    final email = userId!.email;
    if(email == null){
      final phone = userId!.phoneNumber;
      UserModel userInfo = await getUserDetailsWithPhone(phone!);
      final snapshot = await _db.collection("Bookings").where("Customer ID", isEqualTo: userInfo.id).get();
      List<BookingModel> bookingData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e)).toList();
      bookingData.sort((a,b) => DateTime.parse(b.created_at!).compareTo(DateTime.parse(a.created_at!)));
      return bookingData;
    }
    else {
      UserModel userInfo = await getUserDetailsWithEmail(email);
      final snapshot = await _db.collection("Bookings").where("Customer ID", isEqualTo: userInfo.id).get();
      List<BookingModel> bookingData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e)).toList();
      bookingData.sort((a,b) => DateTime.parse(b.created_at!).compareTo(DateTime.parse(a.created_at!)));
      return bookingData;
    }

  }

  ///Retrieving Support Details From Database
  Future<List<SupportModel>?>getUserSupport() async {
      final email = userId!.email;
      final snapshot = await _db.collection("supportTickets").where("email", isEqualTo: email).get();
      final bookingData = snapshot.docs.map((e) => SupportModel.fromSnapshot(e)).toList();
      return bookingData;
    }

  ///Retrieving Delivery Mode Details From Database
  Future<List<DeliveryModeModel>?>getModes() async {
      final snapshot = await _db.collection("Settings").doc("deliverymodes").collection("modes").get();
      final modeData = snapshot.docs.map((e) => DeliveryModeModel.fromSnapshot(e)).toList();
      return modeData;

  }

  ///Fetch  User Details
  Future<BookingModel> getBookingDetails(String bookingNumber) async {
    final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: bookingNumber).get();
    final bookinData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e)).single;
    return bookinData;
  }

  /// Getting Driver Details 2
  Future<DriverModel> getDriverById(String id) =>
      _db.collection("Drivers").doc(id).get().then((doc) {
        return DriverModel.fromSnapshot(doc);
      });

  ///Fetch  User Details using stream
  Stream<DriverModel> getDriverData(){
    final email = FirebaseAuth.instance.currentUser!.email;
    return _db.collection("Drivers")
        .where("Email", isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => DriverModel.fromSnapshot(document)).first
    );
  }

  Stream<OrderStatusModel> getOrderStatusData( String num){
    return _db.collection("Order_Status")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => OrderStatusModel.fromSnapshot(document)).first
    );
  }



}
