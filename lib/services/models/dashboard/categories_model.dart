import 'package:flutter/material.dart';

class DashboardCategoriesModel{
  final String title;
  final String heading;
  final String subheading;
  final VoidCallback? onPress;

  DashboardCategoriesModel(this.title, this.heading, this.subheading, this.onPress);

  static List<DashboardCategoriesModel> list = [
    DashboardCategoriesModel("#4534", "View Details", "Track Order", null),
    DashboardCategoriesModel("#1890", "View Details", "Track Order", null),
    DashboardCategoriesModel("#9032", "View Details", "Track Order", null),
    DashboardCategoriesModel("#7689", "View Details", "Track Order", null),
    DashboardCategoriesModel("#1246", "View Details", "Track Order", null),
  ];
}