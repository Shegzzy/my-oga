import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../constants/colors.dart';


class MyWalletScreen extends StatelessWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final txtTheme = Theme
        .of(context)
        .textTheme;
    String symbol ='\₦';
    var format = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'NGN').currencySymbol;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Center(child: Text("My Wallet", style: Theme.of(context).textTheme.headline4)),
        actions: [
          IconButton(
              onPressed: () {},
              icon:
              Icon(isDark ? LineAwesomeIcons.address_book : LineAwesomeIcons.address_book_1)),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 20,
                  shadowColor: Colors.black,
                  color: moPrimaryColor,
                  child: SizedBox(
                    width: 300,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text("Balance", style: txtTheme.headline2),
                          const SizedBox(height: 10,),
                          Text("NGN 0.00", style: txtTheme.headline5?.apply(fontSizeFactor: 2.2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Top Up Wallet", style: Theme.of(context).textTheme.headline6,),
                  SizedBox(width: 10,),
                  FloatingActionButton(
                    onPressed: () {
                      // Get.to(const PickupLocationScreen());
                    },
                    backgroundColor: PButtonColor,
                    elevation: 10.0,
                    child: const Icon(LineAwesomeIcons.plus,
                        color: Colors.white,
                        size: 30.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
