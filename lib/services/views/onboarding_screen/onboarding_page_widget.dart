import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myoga/services/controllers/getXSwitchStateController.dart';

import '../../models/onboarding_model.dart';

class OnBoardingPageWidget extends StatelessWidget {
 OnBoardingPageWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final OnBoardingModel model;
  final GetXSwitchState getXSwitchState = Get.find();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var isDark = getXSwitchState.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(25.0),
      alignment: Alignment.center,
      color: model.bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image(image: AssetImage(model.image), height: size.height * 0.4,),
          Text(model.title, style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87.withOpacity(0.001)
          ), textAlign: TextAlign.center,),
              // : Text(model.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center,),
          const SizedBox(height: 50.0,)
        ],
      ),
    );
  }
}