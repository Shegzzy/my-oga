import 'package:flutter/material.dart';

import '../../../constants/image_strings.dart';

class DashboardDriversModel{
  final String title;
  final String heading;
  final String subheading;
  final VoidCallback? onPress;
  final String image;

  DashboardDriversModel(this.title, this.heading, this.subheading, this.onPress, this.image);

  static List<DashboardDriversModel> list = [
    DashboardDriversModel("James Mathias Jonah", "View Bookings", "View Earnings", null, moBannerThree),
    DashboardDriversModel("Abdulsalam Shehu", "View Bookings", "View Earnings", null, moBannerFour),
    DashboardDriversModel("Samson Mathew Samuel", "View Bookings", "View Earnings", null, moBannerFive),
    DashboardDriversModel("Daniel Lawrence", "View Bookings", "View Earnings", null, moBannerSix),
    DashboardDriversModel("Prince Emmanuel", "View Bookings", "View Earnings", null, moBannerTwo),
  ];
}