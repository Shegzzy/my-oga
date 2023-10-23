import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../repositories/user_repository/user_repository.dart';
import '../../models/booking_model.dart';
import '../../models/driverModel.dart';
import '../../models/orderStatusModel.dart';
import '../Navigation_Screen/navigation_screen.dart';


class DriverStatusScreen extends StatefulWidget {
  DriverStatusScreen({Key? key, required this.driverID}) : super(key: key);
  String? driverID;
  @override
  State<DriverStatusScreen> createState() => _DriverStatusScreenState();
}

class _DriverStatusScreenState extends State<DriverStatusScreen> {


  var Int1, Int2, Int3, Int4, Int5, Int6;
  OrderStatusModel? _orderStats;
  DriverModel? _driverModel;
  final _userRepo = Get.put(UserRepository());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userRepo.getDriverById(widget.driverID!).then((value) {
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
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6.0,),
              Text("Driver Detail", style: Theme.of(context).textTheme.headline6,),
              const SizedBox(height: 15,),
              SizedBox(
                width: 80.0,
                height: 80.0,
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
                        if (loadingProgress == null)
                          return child;
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
              Text(_driverModel!.fullname ?? " ", style: theme.textTheme.headline6),
              Text(_driverModel!.phoneNo ?? " ", style: theme.textTheme.bodyText1),
              const SizedBox(width: 20,),
              const Icon(Icons.phone, color: Colors.purple,),
              const SizedBox(height: 20,),
              Text("Vehicle Number", style: theme.textTheme.headline6),
              const SizedBox(width: 5,),
              Text(_driverModel!.vehicleNumber ?? " ", style: theme.textTheme.bodyText1),
              const SizedBox(width: 10,),
              Text("Vehicle Type", style: theme.textTheme.headline6),
              const SizedBox(width: 5,),
              Text(_driverModel!.vehicleType ?? " ", style: theme.textTheme.bodyText1),
              const SizedBox(width: 10,),
              Text("Vehicle Color", style: theme.textTheme.headline6),
              const SizedBox(width: 5,),
              Text(_driverModel!.vehicleColor ?? " ", style: theme.textTheme.bodyText1),
              const SizedBox(width: 10,),
              TextButton(
                child: Text("View Driver on Map", style: theme.textTheme.headline6,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,),
                onPressed: () {
                  Get.to(() => NavigationScreen(double.parse(_driverModel!.currentLat!), double.parse(_driverModel!.currentLong!)));
                },),
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
                      onPressed: () {
                        ///showAcceptModalBottomSheet(context);
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
      ],
    );
  }
}
