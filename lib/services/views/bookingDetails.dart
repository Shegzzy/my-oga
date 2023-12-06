import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/views/ratingScreen.dart';
import 'package:myoga/utils/formatter/formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../repositories/user_repository/user_repository.dart';
import '../controllers/profile_controller.dart';
import '../models/booking_model.dart';
import '../models/driverModel.dart';
import 'Navigation_Screen/navigation_screen.dart';
import 'Order_Status_Screen/order_status.dart';
import '../../../constants/texts_string.dart';


class BookingDetailsScreen extends StatefulWidget {
  final BookingModel bookingData;
  const BookingDetailsScreen({Key? key, required this.bookingData}) : super(key: key);


  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState(bookingData: this.bookingData);
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingModel bookingData;
  _BookingDetailsScreenState({required this.bookingData});

  ProfileController controller = Get.put(ProfileController());
  final userController = Get.put(UserRepository());
  DriverModel? _driverModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(bookingData.driver_id == null){
      return;
    }else{
      userController.getDriverById(bookingData.driver_id!).then((value) =>
      _driverModel = value
      );
    }
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   controller.dispose();
  //   userController.dispose();
  // }

  Future<void>showDriverDialog(BuildContext context) async {
    return await showDialog(context: context, builder: (context){
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          content: Container(
            width: double.infinity,
            height: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Driver", style: Theme.of(context).textTheme.bodyLarge,),
                const SizedBox(height: 20,),
                SizedBox(
                  width: 120.0,
                  height: 120.0,
                  child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(100),
                      child: _driverModel!.profilePic != null
                          ?  Image(
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
                      )
                          : const Icon(LineAwesomeIcons.user_circle, size: 35,)),
                ),
                const SizedBox(width: 2,),
                Text(_driverModel?.fullname ?? " ",
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5,),
                Text(_driverModel?.phoneNo ?? " ",
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5,),
                Text("VN: ${_driverModel?.vehicleNumber ?? ""} ",
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 2,),
                Flexible(
                  child: Text("Current Location: ${_driverModel?.currentAddress ?? ""}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,),
                ),
                const SizedBox(width: 2,),
                Flexible(
                  child: TextButton(
                    child: const Text("View Driver on Map",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,),
                    onPressed: () {
                      Get.to(() => NavigationScreen(double.parse(_driverModel!.currentLat!), double.parse(_driverModel!.currentLong!)));
                    },),
                ),
                const SizedBox(height: 35,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: Theme.of(context).outlinedButtonTheme.style,
                        child: Text("Cancel".toUpperCase()),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final Uri url = Uri(
                            scheme: 'tel',
                            path: _driverModel?.phoneNo,
                          );
                          if(await canLaunchUrl(url)){
                          await launchUrl(url);
                          } else {
                          Get.snackbar("Notice!", "Not Supported yet", snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          colorText: Colors.red);
                          }
                        },
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text("Call".toUpperCase()),
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

  void showStatusModalBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.32,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: OrderStatusScreen(
            bookingData: bookingData,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text("Booking Details", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          width: Get.width,
          padding: const EdgeInsets.all(20.0),
          child:  SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15,),
                                Center(
                                  child: Text("BN: ${bookingData.bookingNumber}",
                                    style: theme.textTheme.bodyLarge,),
                                ),
                                const SizedBox(height: 15,),
                                Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Text(bookingData.customer_name!, style: theme.textTheme.bodyLarge,),
                                    const SizedBox(height: 5,),
                                    Text(bookingData.customer_phone!, style: theme.textTheme.bodyLarge,),
                                    const SizedBox(height: 5,),
                                    ],
                                  ),
                                  const SizedBox(width: 40,),
                                Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(MyOgaFormatter.currencyFormatter(double.parse(bookingData.amount!)), style: theme.textTheme.bodyLarge,),
                        const SizedBox(height: 10,),
                        Text("${bookingData.distance}", style: theme.textTheme.bodyLarge,),
                      ],
                    )
                                ],
                                ),
                                const SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text("Package Type: ${bookingData.packageType}",
                                      style: theme.textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,)),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: Text("Delivery Mode: ",
                                        style: theme.textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                    Flexible(
                                      child: Text(bookingData.deliveryMode ?? "",
                                        style: theme.textTheme.titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text("Payment Mode: ${bookingData.payment_method}",
                                        style: theme.textTheme.titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: Text("Ride Type: ",
                                        style: theme.textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                    Flexible(
                                      child: Text(bookingData.rideType ?? "" ,
                                        style: theme.textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15,),
                                const Divider(
                                  color: Colors.black,
                                  height: 2,
                                  thickness: 1,
                                  indent: 2,
                                  endIndent: 2,
                                ),
                                const SizedBox(height: 15,),
                                Text("Pick Up", style: theme.textTheme.bodyLarge,),
                                const SizedBox(height: 5,),
                                Flexible(child: Text(bookingData.pickup_address??"", style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis,)),
                                const SizedBox(height: 15,),
                                const Divider(
                color: Colors.black,
                height: 2,
                thickness: 1,
                indent: 2,
                endIndent: 2,
              ),
                                const SizedBox(height: 15,),
                                Text("Drop", style: theme.textTheme.bodyLarge,),
                                const SizedBox(height: 5,),
                                Flexible(child: Text(bookingData.dropOff_address??"", style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis,)),
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
                                      child: Text("Date Created: ${bookingData.created_at}",
                                        style: theme.textTheme.titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: bookingData.status == 'completed' ? GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>RatingScreen(
                                            driverID: bookingData.driver_id!,
                                          )));
                                        },
                                        child: Text("RATE DRIVER",
                                          style: theme.textTheme.titleLarge,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,),
                                      ) : Text("Status: ${bookingData.status}",
                                        style: theme.textTheme.headline6,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Flexible(child: Text("Additional Details: ${bookingData.additional_details}", style: theme.textTheme.headline6, maxLines: 3, overflow: TextOverflow.ellipsis,)),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text("Rider Details",
                                        style: theme.textTheme.headline6,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: bookingData.driver_id == null
                                          ?  const Text("No Driver Assigned")
                                          :  TextButton(
                                        child: const Text("View Rider Details",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,),
                                        onPressed: () {
                                          setState(() {
                                            showDriverDialog(context);
                                          });
                                          ///Navigator.push(context, MaterialPageRoute(builder: (contect) => RiderDetailScreen()));
                                        },),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: bookingData.driver_id == null
                                          ? OutlinedButton(
                                              onPressed: (){},
                                                  style: Theme
                                                      .of(context)
                                                      .elevatedButtonTheme
                                                      .style,
                                                  child: Text("Waiting for Driver".toUpperCase()),
                                            )
                                          : OutlinedButton(
                                        onPressed: (){
                                          //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderStatusScreen(bookingData: bookingData,)));
                                          showStatusModalBottomSheet(context);
                                        },
                                        style: Theme
                                            .of(context)
                                            .elevatedButtonTheme
                                            .style,
                                        child: Text("Track Parcel".toUpperCase()),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),
                              ],
                    ),
          ),
        ),
      ),
    );
  }
}