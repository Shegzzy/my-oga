import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myoga/repositories/authentication_repository/authentication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/Forget_Password/Forget_Password_Otp/otp_screen.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _authRepo = Get.put(AuthenticationRepository());
  bool _otpVerifying = false;
  bool get otpVerifying => _otpVerifying;

  Future<void> verifyOTP(String otp) async {
    try {
      _otpVerifying = true;
      update();

      var isVerified = await _authRepo.verifyOTP(otp);
      if (isVerified == true) {
        Get.snackbar(
            "Success", "OTP Verified",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green
        );
        await _auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString("email");
        final userPassword = prefs.getString("password");
        _authRepo.loginUserWithEmailAndPassword(userEmail!, userPassword!);
      } else {
        Get.offAll(const OTPScreen());
      }
    } catch (e) {
      // print('OTP Error $e');
      Get.snackbar(
          "Error", "Incorrect OTP or OTP expired",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.redAccent
      );
    } finally {
      _otpVerifying = false;
      update();
    }
  }
}