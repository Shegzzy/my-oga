import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class MyOgaElevatedButtonTheme {
  MyOgaElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: const RoundedRectangleBorder(),
      backgroundColor: PButtonColor,
      foregroundColor: PWhiteColor,
      side: const BorderSide(color: PButtonColor),
      padding: const EdgeInsets.symmetric(vertical: 20.0),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: const RoundedRectangleBorder(),
      backgroundColor: PWhiteColor,
      foregroundColor: PButtonColor,
      side: const BorderSide(color: PWhiteColor),
      padding: const EdgeInsets.symmetric(vertical: 20.0),
    ),
  );

}