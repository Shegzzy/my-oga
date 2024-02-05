import 'package:flutter/material.dart';

class CancelledBookings extends StatefulWidget {
  const CancelledBookings({super.key});

  @override
  State<CancelledBookings> createState() => _CancelledBookingsState();
}

class _CancelledBookingsState extends State<CancelledBookings> {
  late Future<List<CancelledBookings>?> userFuture;


  @override
  void initState() {
    super.initState();
    userFuture = _getBookings();
  }

  void reloadScreen() {
    userFuture = _getBookings();
  }

  @override
  void dispose() {
    // if(mounted){
    //   controller.dispose();
    // }
    super.dispose();
  }

  Future<List<CancelledBookings>?>_getBookings() async {
    return await controller.getAllUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ,
    );
  }
}
