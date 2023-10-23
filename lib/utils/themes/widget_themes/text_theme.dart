import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOgaTextTheme {
  MyOgaTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headline1: GoogleFonts.montserrat(color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.bold,),
    headline2: GoogleFonts.montserrat(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headline3: GoogleFonts.poppins(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headline4: GoogleFonts.poppins(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w700,),
    headline5: GoogleFonts.poppins(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600,),
    headline6: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w700,),
    bodyText1: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.normal,),
    bodyText2: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.normal),
    subtitle1: GoogleFonts.poppins(color: Colors.black, fontSize: 12.0,fontWeight: FontWeight.normal,),
  );
  static TextTheme darkTextTheme =  TextTheme(
    headline1: GoogleFonts.montserrat(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold,),
    headline2: GoogleFonts.montserrat(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headline3: GoogleFonts.poppins(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w800,),
    headline4: GoogleFonts.poppins(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w700,),
    headline5: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600,),
    headline6: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w500,),
    bodyText1: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal,),
    bodyText2: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal),
    subtitle1: GoogleFonts.poppins(color: Colors.white, fontSize: 12.0,fontWeight: FontWeight.normal,),
  );
}