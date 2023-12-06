import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../repositories/user_repository/user_repository.dart';
import '../../models/booking_model.dart';
import '../../models/driverModel.dart';
import '../../models/orderStatusModel.dart';


class OrderStatusScreen extends StatefulWidget {
  OrderStatusScreen({Key? key, required this.bookingData}) : super(key: key);
  BookingModel? bookingData;
  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {


  var Int1, Int2, Int3, Int4, Int5, Int6;
  OrderStatusModel? _orderStats;
  DriverModel? _driverModel;
  final _userRepo = Get.put(UserRepository());
  //final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _userRepo.getOrderStatusData(widget.bookingData!.bookingNumber!).listen((event) {
      setState(() {
        _orderStats = event;
      });
      if (_orderStats != null) {
        Int1 = int.tryParse(_orderStats!.orderAssign!);
        Int2 = int.tryParse(_orderStats!.outForPick!);
        Int3 = int.tryParse(_orderStats!.arrivePick!);
        Int4 = int.tryParse(_orderStats!.percelPicked!);
        Int5 = int.tryParse(_orderStats!.wayToDrop!);
        Int6 = int.tryParse(_orderStats!.arriveDrop!);
      }
    });

    _userRepo.getDriverById(widget.bookingData!.driver_id!).then((value) {
      setState(() {
        _driverModel = value;
      });
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _userRepo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: AlignmentDirectional.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: -15,
                  child: Container(
                    width: 60,
                    height: 7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey
                    ),
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6.0,),
                    Center(child: Text("Booking Number: ${widget.bookingData!.bookingNumber!}", style: theme.textTheme.titleLarge,)),
                    const SizedBox(height: 15,),
                    Row(
                      children: [
                        SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(100),
                              child: _driverModel?.profilePic == null
                                  ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                  : Image(
                                image: NetworkImage(_driverModel!.profilePic!),
                                fit: BoxFit.cover,
                                loadingBuilder: (context,
                                    child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                      child:
                                      CircularProgressIndicator());
                                },
                                errorBuilder:
                                    (context, object, stack) {
                                  return const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  );
                                },
                              )),
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_driverModel?.fullname ?? "", style: theme.textTheme.titleLarge),
                            Text(_driverModel?.phoneNo ?? "", style: theme.textTheme.bodyLarge),

                          ],
                        ),
                        const SizedBox(width: 92,),
                        const Icon(Icons.phone, color: Colors.purple,)
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Int1 == 1 ?
                              const Icon(Icons.circle, size: 20, color: Colors.purple)
                              :const Icon(Icons.circle_outlined, size: 20, color: Colors.grey),
                              const SizedBox(width: 15,),
                              Int1 == 1 ? Text("Order Assigned", style: theme.textTheme.titleLarge)
                              : const Text("Order Assigned", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Int1 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 2,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int2 == 1 ? const Icon(Icons.circle, size: 20, color: Colors.purple)
                                  :const Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int2 == 1 ? Text("Out For Pickup",style: theme.textTheme.titleLarge)
                              :const Text("Out For Pickup", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Int2 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 2,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int3 == 1 ? const Icon(Icons.circle, size: 20, color: Colors.purple)
                              :const Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int3 == 1 ? Text("Arrive at Pickup Location", style: theme.textTheme.titleLarge)
                              :const Text("Arrive at Pickup Location", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Int3 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 2,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int4 == 1 ? const Icon(Icons.circle, size: 20, color: Colors.purple)
                              :const Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int4 == 1 ? Text("Parcel Picked", style: theme.textTheme.titleLarge)
                              : const Text("Parcel Picked", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children:[
                                    VerticalDivider(
                                      color: Int4 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 2,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int5 == 1 ? const Icon(Icons.circle, size: 20, color: Colors.purple)
                              : const Icon(Icons.circle_outlined, size: 20, color: Colors.grey),
                              const SizedBox(width: 15,),
                              Int5 == 1 ? Text("On the way to Drop Location", style: theme.textTheme.titleLarge)
                              :const Text("On the way to Drop Location", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              ),

                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Container(
                              height: 25,
                              child: Row(
                                  children:[
                                    VerticalDivider(
                                      color: Int5 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 2,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int6 == 1 ? const Icon(Icons.circle, size: 20, color: Colors.purple)
                              :const Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int6 == 1 ? Text("Arrived at Drop Location", style: theme.textTheme.titleLarge)
                              : const Text("Arrived at Drop Location", style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30,),

                          Row(
                            children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: Theme.of(context).elevatedButtonTheme.style,
                                    child: Text("Ok".toUpperCase()),
                                  ),
                                ),
                              ],
                          ),
                          const SizedBox(width: 10.0,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
