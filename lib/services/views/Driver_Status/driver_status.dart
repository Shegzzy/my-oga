import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/views/My_Orders/my_orders_screen.dart';
import 'package:myoga/services/views/Order_Status_Screen/order_status.dart';
import 'package:myoga/services/views/User_Dashboard/user_dashboard.dart';
import 'package:myoga/services/views/bookingDetails.dart';

import '../../../repositories/user_repository/user_repository.dart';
import '../../models/booking_model.dart';
import '../../models/driverModel.dart';
import '../../models/orderStatusModel.dart';
import '../Navigation_Screen/navigation_screen.dart';


class DriverStatusScreen extends StatefulWidget {
  DriverStatusScreen({Key? key, required this.driverID, required this.bookingModel}) : super(key: key);
  String? driverID;
  BookingModel? bookingModel;
  @override
  State<DriverStatusScreen> createState() => _DriverStatusScreenState();
}

class _DriverStatusScreenState extends State<DriverStatusScreen> {


  var Int1, Int2, Int3, Int4, Int5, Int6;
  OrderStatusModel? _orderStats;
  late Future<DriverModel>? _driverModel;
  final _userRepo = Get.put(UserRepository());
  final _db = FirebaseFirestore.instance;
  int counter = 0;
  double rate = 0;
  double _total = 0;
  double _average = 0;
  List<double> ratings = [0.1, 0.3, 0.5, 0.7, 0.9];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _driverModel = getDriver();
    getRatingCount();
  }

  Future<DriverModel> getDriver() async{
    return await _userRepo.getDriverById(widget.driverID!);
  }

  Future<void> getRatingCount() async{
    await _db.collection("Drivers").doc(widget.driverID!).collection("Ratings").get().then((value) {
      for (var element in value.docs) {
        rate = element.data()["rating"];
        setState(() {
          _total = _total + rate;
          counter = counter+1;
        });
      }
    });
    _average = _total/counter;
  }

  @override
  void dispose() {
    // _userRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Stack(
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
        FutureBuilder(
            future: _driverModel,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text("Rider Details", style: Theme.of(context).textTheme.headlineSmall,)),
                        const SizedBox(height: 10.0,),
                        Center(
                          child: SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(100),
                                child: snapshot.data?.profilePic == null
                                    ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                    : Image(
                                  image: NetworkImage(snapshot.data!.profilePic!),
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
                                      Icons.person,
                                      size: 28,
                                      color: Colors.grey,
                                    );
                                  },
                                )),
                          ),
                        ),
                        const SizedBox(height: 10.0,),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Name: ${snapshot.data?.fullname ?? " "}', style: theme.textTheme.titleLarge),
                              Text('Phone: ${snapshot.data?.phoneNo ?? " "}', style: theme.textTheme.titleLarge),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Ratings: ${_average.toStringAsFixed(1)}", style: theme.textTheme.titleLarge,),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: _average < 3.5 ? Colors.redAccent : Colors.green,
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            Text("Vehicle Number: ", style: theme.textTheme.titleLarge),
                            Text(snapshot.data?.vehicleNumber ?? " ", style: theme.textTheme.bodyLarge),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            Text("Vehicle Type: ", style: theme.textTheme.titleLarge),
                            Text(snapshot.data?.vehicleType ?? " ", style: theme.textTheme.bodyLarge),
                          ],
                        ),
                        const SizedBox(height: 10,),

                        Row(
                          children: [
                            Text("Vehicle Color: ", style: theme.textTheme.titleLarge),
                            Text(snapshot.data?.vehicleColor ?? " ", style: theme.textTheme.bodyLarge),
                          ],
                        ),

                        Center(
                          child: TextButton(
                            child: Text("View Rider on Map", style: theme.textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,),
                            onPressed: () {
                              Get.to(() => NavigationScreen(double.parse(snapshot.data!.currentLat!), double.parse(snapshot.data!.currentLong!)));
                            },),
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Get.offAll(const UserDashboard());
                                  // Navigator.pop(context);
                                },
                                style: Theme.of(context).outlinedButtonTheme.style,
                                child: Text("Ok".toUpperCase()),
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                  Get.to(() => BookingDetailsScreen(bookingData: widget.bookingModel!));
                                },
                                style: Theme.of(context).elevatedButtonTheme.style,
                                child: Text("View".toUpperCase()),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                }else if (snapshot.hasError) {
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
            })

      ],
    );
  }
}
