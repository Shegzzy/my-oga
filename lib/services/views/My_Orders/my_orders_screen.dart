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
import '../../../widgets/progressDialog.dart';
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
  SignUpController signUpController = Get.put(SignUpController());
  CollectionReference _ref = FirebaseFirestore.instance.collection("Bookings");
  CollectionReference _refOrderStatus = FirebaseFirestore.instance.collection("Order_Status");
  bool cancelingBooking = false;


  final GetXSwitchState getXSwitchState = Get.find();

  @override
  void initState() {
    super.initState();
    userFuture = _getBookings();
  }

  Future<void> reloadScreen() async {
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

      BookingModel bookingInfo = await userRepo.getBookingDetails(bookingNumber);
      OrderStatusModel? orderStatusModel = await userRepo.getBookingOrderStatus(bookingNumber);

      bool shouldCancelBooking = (bookingInfo.status == 'pending' || (bookingInfo.status == 'active' && orderStatusModel?.orderAssign == '1'));

      await _ref.doc(bookingInfo.id.toString()).delete();

      if (shouldCancelBooking && orderStatusModel != null) {
        await _refOrderStatus.doc(orderStatusModel.id.toString()).delete();
      }

      if(bookingInfo.payment_method == "Card"){
        BookingModel booking = BookingModel(
          payment_method: bookingInfo.payment_method,
          additional_details: bookingInfo.additional_details,
          dropOff_latitude: bookingInfo.dropOff_latitude,
          dropOff_longitude: bookingInfo.dropOff_longitude,
          pickUp_latitude: bookingInfo.pickUp_latitude,
          pickUp_longitude: bookingInfo.pickUp_longitude,
          created_at: DateTime.now().toString(),
          customer_name: bookingInfo.customer_name,
          customer_phone: bookingInfo.customer_phone,
          customer_id: bookingInfo.customer_id,
          pickup_address: bookingInfo.pickup_address,
          dropOff_address: bookingInfo.dropOff_address,
          status: "cancelled",
          amount: bookingInfo.amount,
          distance: bookingInfo.distance,
          driver_id: bookingInfo.driver_id,
          bookingNumber: bookingNumber,
          deliveryMode: bookingInfo.deliveryMode,
          rideType: bookingInfo.rideType,
          rated: "0",
          packageType: bookingInfo.packageType,
          timeStamp: Timestamp.now(),
        );
        await signUpController.saveCancelledBookings(booking);
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

  // cancel booking dialogue
  void showDeleteAlert(BuildContext context, String bookingNumber) async {
    return await showDialog(
        barrierDismissible: cancelingBooking ? false : true,
        context: context,
        builder: (context){
      // print(bookingNumber);
      var isDark = getXSwitchState.isDarkMode;
      return StatefulBuilder(builder: (context, setState){
        return PopScope(
          canPop: cancelingBooking ? false : true,
          child: AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, size: 22, color: Colors.redAccent,),
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
                        onPressed: cancelingBooking ? null : () {
                          Navigator.pop(context);
                        },
                        style: Theme.of(context).outlinedButtonTheme.style,
                        child: Text("No".toUpperCase()),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cancelingBooking ? null : () async{
                          setState(() {
                            cancelingBooking = true;
                          });
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
          ),
        );
      });
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
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {

            });
            return await reloadScreen();
          },
          child: Container(
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
                                            style: TextStyle(fontSize: 13.0, color: snapshot.data![index].status == "active" ? Colors.green : Colors.amber ),
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
                                            style: Theme.of(context).textTheme.labelLarge,
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
                                            style: Theme.of(context).textTheme.labelLarge,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,),
                                        ))
                                      ]else...[
                                          Text(snapshot.data![index].status ?? "",
                                          style: TextStyle(fontSize: 13.0, color: snapshot.data![index].status == "active" ? Colors.green : Colors.amber ),
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
                                            foregroundColor: WidgetStateProperty.all(Colors.white),
                                            backgroundColor: WidgetStateProperty.all(PButtonColor),
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
          ),
        ));
  }
}
