import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOgaTextTheme {
  MyOgaTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.bold,),
    displayMedium: GoogleFonts.montserrat(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.w800,),
    displaySmall: GoogleFonts.poppins(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headlineMedium: GoogleFonts.poppins(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w700,),
    headlineSmall: GoogleFonts.poppins(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600,),
    titleLarge: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w700,),
    bodyLarge: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.normal,),
    bodyMedium: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.normal),
    titleMedium: GoogleFonts.poppins(color: Colors.black, fontSize: 12.0,fontWeight: FontWeight.normal,),
  );
  static TextTheme darkTextTheme =  TextTheme(
    displayLarge: GoogleFonts.montserrat(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold,),
    displayMedium: GoogleFonts.montserrat(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w800,),
    displaySmall: GoogleFonts.poppins(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headlineMedium: GoogleFonts.poppins(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700,),
    headlineSmall: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600,),
    titleLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w500,),
    bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal,),
    bodyMedium: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal),
    titleMedium: GoogleFonts.poppins(color: Colors.white, fontSize: 12.0,fontWeight: FontWeight.normal,),
  );
}