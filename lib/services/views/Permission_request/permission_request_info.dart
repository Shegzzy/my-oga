import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../User_Dashboard/user_dashboard.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState(){
    super.initState();
    _requestLocationPermission();
  }

  // Showing a pop up message for location access
  Future<void> _requestLocationPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Location Permission"),
              content: const Text(
                  "Myoga User App collects location data to enable real-time tracking of rider location, and user locations even when the app"
                      " is closed or minimized, this enables cost calculations and precise parcel pick-ups and drop-offs,"
              " needs access to location when in the background, to keep track of ride and destination, "
              "access to location when open, to provide real-time tracking, faster pickups, and efficient route planning to pickups and drop-offs."),
              actions: [
                TextButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    Get.offAll(() => const UserDashboard());
                    },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      Get.offAll(() => const UserDashboard());
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(),
    );
  }
}
