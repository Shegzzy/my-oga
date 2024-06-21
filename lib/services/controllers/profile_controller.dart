import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myoga/repositories/authentication_repository/authentication_repository.dart';

import '../../repositories/user_repository/user_repository.dart';
import '../models/booking_model.dart';
import '../models/cancelled_bookings_model.dart';
import '../models/delivryModeModel.dart';
import '../models/package_details_model.dart';
import '../models/supportModel.dart';
import '../models/user_model.dart';
import 'package:async/async.dart';

import '../notifi_services.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _userRepo = Get.put(UserRepository());
  final _memoizer = AsyncMemoizer();
  final _user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get User Email and Pass it to UserRepository to fetch user record.
  getUserData() async {
    final email = _user!.email;
    return await _userRepo.getUserDetailsWithEmail(email!);
  }


  Future<List<UserModel>> getAllUser() async {
    return await _userRepo.getAllUserDetails();
  }

  updateRecord(UserModel user) async {
    await _userRepo.updateUserRecord(user);
  }

  /// Get User Id and Pass it to UserRepository to fetch Package record.
  Future<Future>getPackageData() async {
    return _memoizer.runOnce(()  async {
      final email =_user!.email;
      UserModel userInfo = await _userRepo.getUserDetailsWithEmail(email!);
      if (userInfo != null) {
        //return await _userRepo.getPackageDetails(userInfo.id!);
      } else {
        Get.snackbar("Error", "Can't fetch package");
      }
    });
  }

  Future<List<PackageDetails>> getAllPackage() async {
    return await _userRepo.getPackageDetails();
  }

  Future<List<BookingModel>?> getAllUserBookings() async {
    return await _userRepo.getUserBookingDetails();
  }

  Future<List<CancelledBookingModel>?> getAllUserCancelledBookings() async {
    return await _userRepo.getUserCancelledBookingDetails();
  }

  Future<List<SupportModel>?> getAllUserSupport() async {
    return await _userRepo.getUserSupport();
  }

  Future<List<SupportTypeModel>?> getSupportTypes() async {
    return await _userRepo.getSupportTypes();
  }

  Future<List<DeliveryModeModel>?> getAllMode() async {
    print('hitting');
    return await _userRepo.getModes();
  }

  Stream<UserModel> getUserDataStream(){
      final email = _user!.email;
      return _db.collection("Users")
          .where("Email", isEqualTo: email)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((document) => UserModel.fromSnapshot(document))
          .single);
  }
}