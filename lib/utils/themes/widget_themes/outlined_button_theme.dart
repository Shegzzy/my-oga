import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class MyOgaOutlinedButtonTheme {
  MyOgaOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: const RoundedRectangleBorder(),
      foregroundColor: PButtonColor,
      side: const BorderSide(color: PButtonColor),
      padding: const EdgeInsets.symmetric(vertical: 20.0),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: const RoundedRectangleBorder(),
      foregroundColor: PWhiteColor,
      side: const BorderSide(color: PWhiteColor),
      padding: const EdgeInsets.symmetric(vertical: 20.0),
    ),
  );

}