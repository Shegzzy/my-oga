import 'package:flutter/material.dart';
import 'package:myoga/services/views/Dashboard/widget/appbar.dart';
import 'package:myoga/services/views/Dashboard/widget/banner.dart';
import 'package:myoga/services/views/Dashboard/widget/categories.dart';
import 'package:myoga/services/views/Dashboard/widget/drivers.dart';
import 'package:myoga/services/views/Dashboard/widget/search.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme
        .of(context)
        .textTheme;
    return Scaffold(
      appBar: DashboardAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hey, My Oga", style: txtTheme.bodyMedium),
              Text("My Bookings", style: txtTheme.displayMedium),
              const SizedBox(height: 20.0),


              DashboardSearchBox(txtTheme: txtTheme),
              const SizedBox(height: 20.0),

              DashboardCategories(txtTheme: txtTheme),
              const SizedBox(height: 20.0),

              DashboardBanners(txtTheme: txtTheme),
              const SizedBox(height: 20.0),

              Text("Drivers",
                style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2),),
              DashboardDrivers(txtTheme: txtTheme),
            ],
          ),
        ),
      ),
    );
  }
}










