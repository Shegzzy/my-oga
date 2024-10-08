import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:myoga/services/views/Email_Verification_Screen/email_verification_screen.dart';
import 'package:myoga/services/views/Permission_request/permission_request_info.dart';
import 'package:myoga/services/views/User_Dashboard/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/controllers/signup_controller.dart';
import '../../services/models/user_model.dart';
import '../../services/views/Login/login_screen.dart';
import '../../services/views/Phone_Number_Screen/phone_number.dart';
import '../../services/views/welcome_screen/welcome_screen.dart';
import '../user_repository/user_repository.dart';
import 'exceptions/signup_email_password_failure.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  late Timer timer;

  //Variables
  final auth = FirebaseAuth.instance;
  var verificationId = "".obs;
  final _userRepo = Get.put(UserRepository());
  UserModel? _userModel;

// Functions
  void phoneAuthentication(String phoneNo) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (credential) async {},
      codeSent: (verificationId, resendToken) {
        this.verificationId.value = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
      verificationFailed: (e) {
        if (e.code == "invalid-phone-number") {
          Get.snackbar('Error', 'Provided phone number is not valid.');
        } else {
          Get.snackbar('Error', 'Something went wrong. Try again.');
        }
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: otp));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await SignUpController.instance.updatePhoneNumber(prefs.getString("Phone")!);
    return credentials.user != null ? true : false;
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final firebaseUser = await auth.createUserWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.user != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("aUserID", firebaseUser.user!.uid);
        prefs.setString("email", email);
        prefs.setString("password", password);
        // final user = firebaseUser.user!;
        // await user.sendEmailVerification();
        await loginUserWithEmailAndPassword(email, password);
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      Get.snackbar(
          ex.toString(), ex.message, snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red,
      );
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailAndPasswordFailure();
      Get.snackbar(
          ex.toString(), ex.message, snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red,
      );
      throw ex;
    }
  }

  Future<void> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final firebaseUser = await auth.signInWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.user != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("userID", firebaseUser.user!.uid);
        final user = firebaseUser.user!;

        // user.sendEmailVerification();
        if(user.emailVerified){
          checkUserType();
        }else{
          await user.sendEmailVerification();
          Get.to(() => const EmailVerificationScreen());
        }
      }
      else {
        Get.to(() => const LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        Get.snackbar(
            "Error", "No Internet Connection", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else if (e.code == "wrong-password") {
        Get.snackbar(
            "Error", "Please Enter correct password", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else if (e.code == 'user-not-found') {
        Get.snackbar(
            "Error", "No such user with this email", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }  else if (e.code == 'too-many-requests') {
        Get.snackbar(
            "Error", "Too many attempts please try later", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }  else if (e.code == 'unknown') {
        Get.snackbar(
            "Error", "Email and Password Fields are required", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else {
        Get.snackbar(
            "Error", e.toString(), snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }

    }
  }

  Future<void> logout() async {
    await auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userID");
    prefs.remove("aUserID");
    prefs.remove("userPic");
    prefs.remove("userName");
    prefs.remove("userEmail");
    prefs.remove("token");
    Get.offAll(() => const WelcomeScreen());
  }

  checkVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userPhone = prefs.getString("Phone")!;
    await _userRepo.getUserDetailsWithPhone(userPhone).then((value) => {
      _userModel = value
    }) .catchError((error, stackTrace) {
      Get.snackbar("Incomplete", error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      Get.offAll(const PhoneNumberScreen());
    });

    if(_userModel?.phoneNo == null){
      await logout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("Phone");
      Get.offAll(const PhoneNumberScreen());
    } else {
      Get.offAll(() => const UserDashboard());
    }
  }

  checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final iD = prefs.getString("userID");
    final userDoc =  await FirebaseFirestore.instance.collection("Users").doc(iD).get();
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(userDoc.exists){
      if(Platform.isAndroid){
        if(permission == LocationPermission.denied){
          Get.to(()=> const PermissionScreen());
        }else{
          Get.offAll(() => const UserDashboard());
        }
      }else{
        Get.offAll(() => const UserDashboard());
      }
    } else{
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      logout();
    }
  }

  void autoRedirectTimer() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer){
      print(timer);
      auth.currentUser?.reload();
      final user = auth.currentUser;

      if(user != null){
        if(user.emailVerified){
          timer.cancel();
          checkUserType();
        }
      } else {
        // timer.cancel();
        return;
      }
    });
  }

}
