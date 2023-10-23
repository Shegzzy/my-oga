import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class moTextFormFieldTheme {
  moTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme =
      const InputDecorationTheme(
        border: OutlineInputBorder(),
        prefixIconColor: moAccentColor,
        floatingLabelStyle: TextStyle(color: moAccentColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2.0, color: moAccentColor),
        )
      );

  static InputDecorationTheme darkInputDecorationTheme =
    const InputDecorationTheme(
        border: OutlineInputBorder(),
        prefixIconColor: moPrimaryColor,
        floatingLabelStyle: TextStyle(color: moPrimaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2.0, color: moPrimaryColor),
        )
    );

}