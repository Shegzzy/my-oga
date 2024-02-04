import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/utils/formatter/formatter.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../repositories/authentication_repository/authentication_repository.dart';
import '../../../repositories/user_repository/user_repository.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/signup_controller.dart';
import '../../models/booking_model.dart';
import '../../models/orderStatusModel.dart';
import '../../models/package_details_model.dart';
import '../bookingDetails.dart';
import '../ratingScreen.dart';

class MyOrdersScreen extends StatefulWidget {
  MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<BookingModel>?> userFuture;
  ProfileController controller = Get.put(ProfileController());
  UserRepository userRepo = Get.put(UserRepository());
  CollectionReference _ref = FirebaseFirestore.instance.collection("Bookings");
  CollectionReference _refOrderStatus = FirebaseFirestore.instance.collection("Order_Status");
  bool cancelingBooking = false;


  final GetXSwitchState getXSwitchState = Get.find();

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

  Future<List<BookingModel>?>_getBookings() async {
    return await controller.getAllUserBookings();
  }

  // canceling booking
  Future<void> cancelBookingRequest(String bookingNumber) async {
    try{
      setState(() {
        cancelingBooking = true;
      });
      BookingModel bookingInfo = await userRepo.getBookingDetails(bookingNumber);
      OrderStatusModel? orderStatusModel = await userRepo.getBookingOrderStatus(bookingNumber);

      bool shouldCancelBooking = (bookingInfo.status == 'pending' || (bookingInfo.status == 'active' && orderStatusModel?.orderAssign == '1'));

      await _ref.doc(bookingInfo.id.toString()).delete();

      if (shouldCancelBooking && orderStatusModel != null) {
        await _refOrderStatus.doc(orderStatusModel.id.toString()).delete();
      }

      if (mounted) {
        Navigator.pop(context);
      }

      reloadScreen();
      Get.snackbar('Success', 'Booking $bookingNumber has been canceled');

    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        cancelingBooking = false;
      });
    }
  }

  void showDeleteAlert(BuildContext context, String bookingNumber) async {
    return await showDialog(context: context, builder: (context){
      print(bookingNumber);
      var isDark = getXSwitchState.isDarkMode;
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, size: 22, color: Colors.redAccent,),
            const SizedBox(height: 5,),

            Text("Notice!", style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 10,),

            Text("Are you sure you want to cancel this booking?",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Text("No".toUpperCase()),
                  ),
                ),
                const SizedBox(width: 10.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async{
                      await cancelBookingRequest(bookingNumber);
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: cancelingBooking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(),) : Text("Yes".toUpperCase()),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(LineAwesomeIcons.angle_left)),
          title: Text(moMyOrders, style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),

          ///Future Builder
          child: FutureBuilder<List<BookingModel>?>(
            future: userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  //Controllers
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (c, index){
                      return  GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(bookingData: snapshot.data![index],)));
                          if(result == true){
                            reloadScreen();
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only( top: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: isDark ? Colors.black.withOpacity(0.1) : moPrimaryColor),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text(snapshot.data![index].bookingNumber ?? "",
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis)),
                                    if(snapshot.data![index].status == 'active')...[
                                      Text(snapshot.data![index].status ?? "",
                                          style: TextStyle(fontSize: 18.0, color: snapshot.data![index].status == "active" ? Colors.green : Colors.amber ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)
                                    ]else if(snapshot.data![index].status == 'completed' && snapshot.data![index].rated == '0')...[
                                      Flexible(child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>RatingScreen(
                                            driverID: snapshot.data![index].driver_id!,
                                            bookingID: snapshot.data![index].bookingNumber!,
                                          )));
                                        },
                                        child: Text("Rate Rider",
                                          style: Theme.of(context).textTheme.headlineSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,),
                                      ))
                                    ]else if(snapshot.data![index].status == 'completed' && snapshot.data![index].rated == null)...[
                                      Flexible(child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>RatingScreen(
                                            driverID: snapshot.data![index].driver_id!,
                                            bookingID: snapshot.data![index].bookingNumber!,
                                          )));
                                        },
                                        child: Text("Rate Rider",
                                          style: Theme.of(context).textTheme.headlineSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,),
                                      ))
                                    ]else...[
                                        Text(snapshot.data![index].status ?? "",
                                        style: TextStyle(fontSize: 18.0, color: snapshot.data![index].status == "active" ? Colors.green : Colors.amber ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)
                                    ],

                                  ],
                                ),
                                // const SizedBox(height: 20,),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(shape: const CircleBorder(), minimumSize: const Size(50, 50)),
                                      onPressed: () {},
                                      child: const Icon(Icons.location_pin, size: 20,),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot.data![index].pickup_address ?? "", style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                            const SizedBox(height: 10,),
                                            Text(snapshot.data![index].dropOff_address ?? "", style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),


                                if(snapshot.data![index].status == 'active' || snapshot.data![index].status == 'pending')
                                  Center(
                                    child: TextButton(
                                        style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all(Colors.white),
                                          backgroundColor: MaterialStateProperty.all(PButtonColor),
                                        ),
                                        onPressed: () async {
                                          // print(snapshot.data![index].bookingNumber);
                                          showDeleteAlert(context, snapshot.data![index].bookingNumber!);
                                        },
                                        child: const Text('Cancel')
                                    ),
                                  ),

                                const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text(snapshot.data![index].deliveryMode ?? "",
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),

                                    Flexible(child: Text(MyOgaFormatter.currencyFormatter(double.parse(snapshot.data![index].amount ?? "")),
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),

                                    Flexible(child: Text(snapshot.data![index].distance ??"",
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                // const SizedBox(height: 5,),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }
              }
              else {
                return const Center(
                    child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }
}
