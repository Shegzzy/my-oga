import 'package:flutter/material.dart';

import '../../constants/image_strings.dart';
import '../../constants/texts_string.dart';

class OnBoarding {
  final String image;
  final String title;

  OnBoarding({
    required this.image,
    required this.title,
  });
}

List<OnBoarding> onBoardingContent = [
  OnBoarding(
      image: moOnboardImg1,
      title: moOnboardTitle1,
  ),
  OnBoarding(
      image: moOnboardImg2,
      title: moOnboardTitle2,
  ),
  OnBoarding(
      image: moOnboardImg3,
      title: moOnboardTitle3,
  ),
];
