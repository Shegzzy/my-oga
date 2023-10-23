import 'package:flutter/material.dart';
import 'package:myoga/utils/themes/widget_themes/text_theme.dart';

import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';

class MyOgaTheme {
  MyOgaTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: const MaterialColor(0xFFCEC3FD, <int, Color>{
      50: Color(0x1ACEC3FD),
      100: Color(0x33CEC3FD),
      200: Color(0x4DCEC3FD),
      300: Color(0x66CEC3FD),
      400: Color(0x80CEC3FD),
      500: Color(0x99CEC3FD),
      600: Color(0xB3CEC3FD),
      700: Color(0xCCCEC3FD),
      800: Color(0xE6CEC3FD),
      900: Color(0xFFCEC3FD),
    }),
    textTheme: MyOgaTextTheme.lightTextTheme,
    outlinedButtonTheme: MyOgaOutlinedButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: MyOgaElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: moTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: MyOgaTextTheme.darkTextTheme,
    outlinedButtonTheme: MyOgaOutlinedButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: MyOgaElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: moTextFormFieldTheme.darkInputDecorationTheme,
  );
}