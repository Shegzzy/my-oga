import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final splashController = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    splashController.startAnimation();
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 1600),
              bottom: splashController.animate.value ? 170.0 : 0,
              left: 0.0,
              right: 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1400),
                opacity: splashController.animate.value ? 1 : 0,
                child: const Image(
                  image: AssetImage(moSplashImage),
                ),
              ),
            ),),
          Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 2600),
              bottom: splashController.animate.value ? 180.0 : 0,
              left: 0.0,
              right: 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 3200),
                opacity: splashController.animate.value ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(moSplashText, style: Theme.of(context).textTheme.headline4,),
                    Text(moAppTagLine, style: Theme.of(context).textTheme.subtitle2,),
                  ],
                ),
              ),
            ),),
          Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 2400),
              bottom: splashController.animate.value ? 30.0 : 0,
                right: 10.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: splashController.animate.value ? 1 : 0,
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: moAccentColor,
                    ),
                  ),
                ),
            ),)
        ],
      ),
    );
  }
}
