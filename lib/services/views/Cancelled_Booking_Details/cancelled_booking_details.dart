import 'dart:async';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/models/cancelled_bookings_model.dart';
import 'package:get/get.dart';

import '../../../repositories/user_repository/user_repository.dart';
import '../../../utils/formatter/formatter.dart';

class CancelledBookingDetails extends StatefulWidget {
  final CancelledBookingModel bookingData;

  const CancelledBookingDetails({super.key, required this.bookingData});

  @override
  State<CancelledBookingDetails> createState() => _CancelledBookingDetailsState();
}

class _CancelledBookingDetailsState extends State<CancelledBookingDetails> {

  late StreamSubscription<CancelledBookingModel?> _bookingStatusSubscription;
  final userController = Get.put(UserRepository());
  CancelledBookingModel? cancelledBookingModel;

  @override
  void initState(){
    super.initState();
    _startListeningToBookingStatusChanges();
  }

  @override
  void dispose() {
    _bookingStatusSubscription.cancel();
    super.dispose();
  }



  void _startListeningToBookingStatusChanges() {
    print('started');
    _bookingStatusSubscription = userController.getCancelledBookingStatusData(widget.bookingData.bookingNumber!).listen((event) {
      setState(() {
        cancelledBookingModel = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text("Booking Details",
            style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          width: Get.width,
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: Get.height,
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BN: ${widget.bookingData.bookingNumber}",
                      style: theme.textTheme.headlineSmall,
                    ),

                    if(cancelledBookingModel?.status == 'cancelled' || cancelledBookingModel?.status == null)...[
                      const Center(
                        child: Text("Awaiting Refund",
                          style: TextStyle(fontSize: 12.0, color: Colors.amber ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                      ),

                    ]else if(cancelledBookingModel?.status == 'refunded')...const [
                      Center(
                        child: Text("Refunded",
                            style: TextStyle(fontSize: 12.0, color: Colors.green )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookingData.customer_name!,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.bookingData.customer_phone!,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MyOgaFormatter.currencyFormatter(
                              double.parse(widget.bookingData.amount!)),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${widget.bookingData.distance}",
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                          "Package Type: ${widget.bookingData.packageType}",
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        "Delivery Mode: ${widget.bookingData.deliveryMode ?? ""}",
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Payment Mode: ${widget.bookingData.payment_method}",
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        "Ride Type: ${widget.bookingData.rideType ?? ""}",
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Pick Up: ",
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.bookingData.pickup_address ?? "",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Drop:",
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.bookingData.dropOff_address ?? "",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Date Created: ${MyOgaFormatter.dateFormatter(DateTime.parse(widget.bookingData.created_at!))}",
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                      Text(
                        "Status: ${widget.bookingData.status}",
                        style: theme.textTheme.titleSmall,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Additional Details: ${widget.bookingData.additional_details}",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
