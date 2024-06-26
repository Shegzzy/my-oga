
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myoga/services/models/cancelled_bookings_model.dart';
import 'package:myoga/services/models/states_model.dart';
import 'package:myoga/services/models/vehicles_model.dart';
import 'package:myoga/services/views/Cancelled_Bookings/cancelled_bookings.dart';
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
  Future<void> createUser(UserModel user) async {
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

  UserModel _userModel = const UserModel();
  UserModel get userModel => _userModel;
  bool _loadingEditProfile = false;
  bool get loadingEditProfile => _loadingEditProfile;

  ///Fetch  User Details by ID
  Future<UserModel> getUserById(String id) async{
    _loadingEditProfile = true;
    update();

    try{

      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('Users').doc(id).get();
      if(snapshot.exists){
        _userModel = UserModel.fromSnapshot(snapshot);
      }

      return _userModel;

    } catch (e){
      throw e.toString();
    } finally{
      _loadingEditProfile = false;
      update();
    }
  }


  ///Fetch All Users
  // Future<List<UserModel>> getAllUserDetails() async {
  //   final snapshot = await _db.collection("Users").get();
  //   final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
  //   return userData;
  // }

  ///Updating User Details
  Future<void> updateUserRecord(UserModel user, String userID) async {
    await _db.collection("Users").doc(userID).update(user.updateToJson()).then((value) => Get.snackbar(
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

  ///Saving Cancelled Booking Information
  saveCancelledBookingRequest(BookingModel bookings) async {
    await _db.collection("Cancelled Bookings").add(bookings.toJson());
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

  ///Retrieving Cancelled Bookings Details From Database
  Future<List<CancelledBookingModel>?>getUserCancelledBookingDetails() async {
    final email = userId!.email;
    if(email == null){
      final phone = userId!.phoneNumber;
      UserModel userInfo = await getUserDetailsWithPhone(phone!);
      final snapshot = await _db.collection("Cancelled Bookings").where("Customer ID", isEqualTo: userInfo.id).get();
      List<CancelledBookingModel> bookingData = snapshot.docs.map((e) => CancelledBookingModel.fromSnapshot(e)).toList();
      bookingData.sort((a,b) => DateTime.parse(b.created_at!).compareTo(DateTime.parse(a.created_at!)));
      return bookingData;
    }
    else {
      UserModel userInfo = await getUserDetailsWithEmail(email);
      final snapshot = await _db.collection("Cancelled Bookings").where("Customer ID", isEqualTo: userInfo.id).get();
      List<CancelledBookingModel> bookingData = snapshot.docs.map((e) => CancelledBookingModel.fromSnapshot(e)).toList();
      bookingData.sort((a,b) => DateTime.parse(b.created_at!).compareTo(DateTime.parse(a.created_at!)));
      return bookingData;
    }

  }

  ///Retrieving Support Details From Database
  Future<List<SupportModel>?>getUserSupport() async {
      final email = userId!.email;
      final snapshot = await _db.collection("supportTickets").where("email", isEqualTo: email).get();
      final bookingData = snapshot.docs.map((e) => SupportModel.fromSnapshot(e)).toList();
      // print(bookingData.first.name);
      return bookingData;
    }

  ///Retrieving Delivery Mode Details From Database
  Future<List<DeliveryModeModel>?>getModes() async {
      final snapshot = await _db.collection("Settings").doc("deliverymodes").collection("modes").get();
      final modeData = snapshot.docs.map((e) => DeliveryModeModel.fromSnapshot(e)).toList();
      return modeData;

  }

  List<StatesModel> _stateModel = [];
  List<StatesModel> get stateModel => _stateModel;


  ///Retrieving Delivery States From Database
  Future<List<StatesModel>?> getStates() async {
    _stateModel.clear();
    final snapshot = await _db.collection("Settings").doc("locations").collection("states").get();
    _stateModel.addAll(snapshot.docs.map((e) => StatesModel.fromSnapshot(e)).toList());
    // print(_stateModel.first.id);
    return _stateModel;
  }

  List<VehiclesModel> _vehiclesModel = [];
  List<VehiclesModel> get vehiclesModel => _vehiclesModel;
  //Retrieving types of vehicles From Database
  Future<List<VehiclesModel>?> getVehicles() async {
    _vehiclesModel.clear();
    final snapshot = await _db.collection("Settings").doc("deliveryVehicles").collection("vehicles").get();
    _vehiclesModel.addAll(snapshot.docs.map((e) => VehiclesModel.fromSnapshot(e)).toList());
    // print(_vehiclesModel.first.id);
    return _vehiclesModel;
  }

  List<SupportTypeModel> _supportTypeModel = [];
  List<SupportTypeModel> get supportTypeModel => _supportTypeModel;

  //Retrieving types of supports States From Database
  Future<List<SupportTypeModel>?> getSupportTypes() async {
    _supportTypeModel.clear();
    final snapshot = await _db.collection("Settings").doc("supports").collection("types").get();
    _supportTypeModel.addAll(snapshot.docs.map((e) => SupportTypeModel.fromSnapshot(e)).toList());
    // print(_supportTypeModel.first.id);
    return _supportTypeModel;
  }

  ///Fetch  Booking Details
  Future<BookingModel> getBookingDetails(String bookingNumber) async {
    final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: bookingNumber).get();
    final bookinData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e)).single;
    return bookinData;
  }

  ///Fetch Order Status of a booking
  Future<OrderStatusModel?> getBookingOrderStatus(String bookingNumber) async {
    final snapshot = await _db.collection("Order_Status").where("Booking Number", isEqualTo: bookingNumber).get();
    if(snapshot.docs.isNotEmpty){
      final orderStatusData = snapshot.docs.map((e) => OrderStatusModel.fromSnapshot(e)).single;
      return orderStatusData;
    }else {
      return null;
    }
  }

  /// Getting Driver Details 2
  Future<DriverModel> getDriverById(String id) =>
      _db.collection("Drivers").doc(id).get().then((doc) {
        return DriverModel.fromSnapshot(doc);
      });

  ///Fetch  User Details using stream
  // Stream<DriverModel> getDriverData(){
  //   final email = FirebaseAuth.instance.currentUser!.email;
  //   return _db.collection("Drivers")
  //       .where("Email", isEqualTo: email)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //       .map((document) => DriverModel.fromSnapshot(document)).first
  //   );
  // }

  Stream<OrderStatusModel?> getOrderStatusData(String num) {
    return _db.collection("Order_Status")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return OrderStatusModel.fromSnapshot(snapshot.docs.first);
      } else {
        // throw Exception('No order status found for the given booking number.');
        return null;
      }
    });
  }


  Stream<BookingModel?> getBookingStatusData(String num) {
    return _db.collection("Bookings")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return BookingModel.fromSnapshot(snapshot.docs.first);
      } else {
        return null;
        // throw Exception('No booking status found for the given booking number.');
      }
    });
  }


  Stream<CancelledBookingModel?> getCancelledBookingStatusData(String num) {
    return _db.collection("Cancelled Bookings")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return CancelledBookingModel.fromSnapshot(snapshot.docs.first);
      } else {
        return null;
        // throw Exception('No cancelled booking status found for the given booking number.');
      }
    });
  }


}
