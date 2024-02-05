import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/models/cancelled_bookings_model.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../utils/formatter/formatter.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../../controllers/profile_controller.dart';

class CancelledBookings extends StatefulWidget {
  const CancelledBookings({super.key});

  @override
  State<CancelledBookings> createState() => _CancelledBookingsState();
}

class _CancelledBookingsState extends State<CancelledBookings> {
  late Future<List<CancelledBookingModel>?> userFuture;
  ProfileController controller = Get.put(ProfileController());
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
    controller.dispose();
    super.dispose();
  }

  Future<List<CancelledBookingModel>?> _getBookings() async {
    return await controller.getAllUserCancelledBookings();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(LineAwesomeIcons.angle_left)),
          title: Text("Cancelled Bookings", style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),

          ///Future Builder
          child: FutureBuilder<List<CancelledBookingModel>?>(
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
                          // final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(bookingData: snapshot.data![index],)));
                          // if(result == true){
                          //   reloadScreen();
                          //   setState(() {});
                          // }
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

                                      Text(snapshot.data![index].status ?? "",
                                          style: const TextStyle(fontSize: 12.0, color: Colors.redAccent ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)

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


                                if(snapshot.data![index].refunded == '0' || snapshot.data![index].refunded == null)...[
                                  const Center(
                                    child: Text("Awaiting Refund",
                                      style: TextStyle(fontSize: 12.0, color: Colors.amber ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,),
                                  ),

                                ]else if(snapshot.data![index].refunded == '1')...const [
                                  Center(
                                    child: Text("Refunded",
                                      style: TextStyle(fontSize: 12.0, color: Colors.green )),
                                  ),
                                ],

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
        ));  }
}
