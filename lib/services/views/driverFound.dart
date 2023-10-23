import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repositories/user_repository/user_repository.dart';
import '../models/booking_model.dart';
import '../models/driverModel.dart';
import 'Navigation_Screen/navigation_screen.dart';
import 'Order_Status_Screen/order_status.dart';

class DriverFoundScreen extends StatefulWidget {
  final String dId;
  final String bNum;
  const DriverFoundScreen({Key? key, required this.dId, required this.bNum}) : super(key: key);

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {
  _DriverFoundScreenState(){
    driverID = widget.dId;
    bookNum = widget.bNum;
  }
  DriverModel? _driverModel;
  BookingModel? bookingData;
  String driverID = "";
  String bookNum = "";
  final userController = Get.put(UserRepository());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      userController.getDriverById(driverID).then((value) =>
        _driverModel = value
      );
      userController.getBookingDetails(bookNum).then((booking) =>
          bookingData = booking
      );
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userController.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Rider Found"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          width: double.infinity,
          height: 520,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Driver", style: Theme.of(context).textTheme.bodyText1,),
              const SizedBox(height: 20,),
              SizedBox(
                width: 120.0,
                height: 120.0,
                child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(100),
                    child: _driverModel!.profilePic == null
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
              const SizedBox(width: 2,),
              Text(_driverModel?.fullname ?? " ",
                style: Theme.of(context).textTheme.headline4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text(_driverModel?.phoneNo ?? " ",
                style: Theme.of(context).textTheme.headline4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text("VN: ${_driverModel?.vehicleNumber ?? ""} ",
                style: Theme.of(context).textTheme.headline4,
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
                    Get.to(() => NavigationScreen(double.parse(_driverModel?.currentLat ?? ""), double.parse(_driverModel?.currentLong ?? "")));
                  },),
              ),
              const SizedBox(height: 35,),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                       Get.back();
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
                          path: _driverModel?.phoneNo ?? "",
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
      ),
    );
  }
}
