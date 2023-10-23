import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../views/onboarding_screen/onboarding_screen.dart';
import '../views/welcome_screen/welcome_screen.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;



  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 2000));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seenOnboard = prefs.getBool('seenOnBoard');
    seenOnboard == true ? Get.offAll(() => const WelcomeScreen()) : Get.offAll(() => const OnBoardingScreen());
  }

}