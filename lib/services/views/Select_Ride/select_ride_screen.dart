import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myoga/services/controllers/Data_handler/appData.dart';
import 'package:myoga/utils/formatter/formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../configMaps.dart';
import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/Assistant/assistanceMethods.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../../controllers/signup_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/address.dart';
import '../../models/booking_model.dart';
import '../../models/delivryModeModel.dart';
import '../../models/directDetails.dart';
import '../../models/orderStatusModel.dart';
import '../../models/user_model.dart';
import '../Dashboard/widget/appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:image/image.dart' as IMG;


import '../Driver_Status/driver_status.dart';
import '../Payment_Methods/payment_page.dart';
import '../User_Dashboard/user_dashboard.dart';
import '../../../repositories/user_repository/user_repository.dart';


class SelectRideScreen extends StatefulWidget {

  const SelectRideScreen({Key? key}) : super(key: key);



  @override
  State<SelectRideScreen> createState() => _SelectRideScreenState();
}



class _SelectRideScreenState extends State<SelectRideScreen> with TickerProviderStateMixin
{
  _SelectRideScreenState() {
    _selectedPaymentVal = _paymentMethodList[0];
    _selectedPackageVal = _packageTypeList[0];
    //getPlaceDirection();
  }
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  final GetXSwitchState getXSwitchState = Get.find();

  late GoogleMapController newGoogleMapController;

  DirectionDetails tripDirectionDetails =  DirectionDetails();
  late String bookingNumber;
  String pickUpLocation = "";
  String dropOffLocation = "";
  final _paymentMethodList = ["Cash on Delivery", "Card"];
  final _packageTypeList = ["Box", "Parcel", "Others"];
  String? _selectedPaymentVal = "";
  String? _selectedPackageVal = "";


  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 420.0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainer = 410.0;
  double requestDriverContainer = 0;
  double ridePriceContainer = 0;

  bool drawerOpen = true;
  late Timer timer;
  bool isTimerRunning = false;

  int counter = 0;
  String? amount;
  late DocumentReference bookingRequestReference;
  late Future<List<DeliveryModeModel>?> modeFuture;
  CollectionReference _ref = FirebaseFirestore.instance.collection("Bookings");
  // CollectionReference _refOrderStatus = FirebaseFirestore.instance.collection("Order_Status");
  UserRepository userRepo = Get.put(UserRepository());
  final controller = Get.put(SignUpController());
  final _addController = TextEditingController();
  ProfileController _pController = Get.put(ProfileController());
  OrderStatusModel? _orderStats;
  BookingModel? bookingModel;
  late StreamSubscription<BookingModel> _bookingStatusSubscription;
  double? pickUpLat;
  double? pickUpLng;
  double? dropOffLat;
  double? dropOffLng;
  String? pickUpAddress;
  String? dropOffAddress;


  String? selectedRide;
   String? selectedDelivery;
   // String? pubKey = pubKey;
   final plugin = PaystackPlugin();
   String message = "";

  //  Delivery mode
  Widget SelectDeveryMode(IconData icon, String? index, String? title, String? subtitle, String price, String distance,){

    var isDark = getXSwitchState.isDarkMode;
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedDelivery = index!;
          amount = price;
          print(amount);
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? (selectedDelivery == index) ? Colors.purple : Colors.black12.withOpacity(0.5) : (selectedDelivery == index) ? Colors.greenAccent : Colors.grey[100],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 50.0, color: selectedDelivery == index ? Colors.white : Colors.grey,),
                  const SizedBox(width: 16.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? "", style: Theme.of(context).textTheme.headlineMedium,),
                      Text("$subtitle hours" ?? "", style: Theme.of(context).textTheme.bodyMedium,),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(MyOgaFormatter.currencyFormatter(double.parse(price)), style: Theme.of(context).textTheme.headlineMedium,),
                  Text(distance, style: Theme.of(context).textTheme.bodyMedium,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Select ride type
  Widget SelectRide(IconData icon, String index, String text){
    var isDark = getXSwitchState.isDarkMode;
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedRide = index;
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? (selectedRide == index) ? Colors.purple : Colors.black12.withOpacity(0.5) : (selectedRide == index) ? Colors.greenAccent : Colors.grey[100],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, size: 50.0, color: (selectedRide == index) ? Colors.white : Colors.grey,),
              const SizedBox(width: 16.0,),
              Text(text, style: Theme.of(context).textTheme.headlineMedium,),
            ],
          ),
        ),
      ),
    );
  }

  // Method for canceling booking
  Future<void> cancelBookingRequest(String bookingNumber)async {

    BookingModel bookingInfo = await userRepo.getBookingDetails(bookingNumber);
    _ref.doc(bookingInfo.id.toString()).delete();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email;
    final BookingModel booking;

    if(bookingModel?.payment_method == "Card"){
      if (email == null) {
        final phone = user.phoneNumber;
        UserModel? userInfo = await userRepo.getUserDetailsWithPhone(phone!);
        booking = BookingModel(
          payment_method: _selectedPaymentVal,
          additional_details: _addController.text.trim(),
          dropOff_latitude: dropOffLat.toString(),
          dropOff_longitude: dropOffLng.toString(),
          pickUp_latitude: pickUpLat.toString(),
          pickUp_longitude: pickUpLng.toString(),
          created_at: DateTime.now().toString(),
          customer_name: userInfo?.fullname.toString(),
          customer_phone: userInfo?.phoneNo.toString(),
          customer_id: userInfo?.id,
          pickup_address: pickUpAddress,
          dropOff_address: dropOffAddress,
          status: "cancelled",
          amount: amount,
          distance: tripDirectionDetails.distanceText!,
          bookingNumber: bookingNumber,
          deliveryMode: selectedDelivery.toString(),
          rideType: selectedRide.toString(),
          rated: "0",
          packageType: _selectedPackageVal,
          timeStamp: Timestamp.now(),
        );
        await controller.saveCancelledBookings(booking);
      }
      else {
        UserModel? userInfo = await userRepo.getUserDetailsWithEmail(email);
        booking = BookingModel(
          payment_method: _selectedPaymentVal,
          additional_details: _addController.text.trim(),
          dropOff_latitude: dropOffLat.toString(),
          dropOff_longitude: dropOffLng.toString(),
          pickUp_latitude: pickUpLat.toString(),
          pickUp_longitude: pickUpLng.toString(),
          created_at: DateTime.now().toString(),
          customer_name: userInfo?.fullname.toString(),
          customer_phone: userInfo?.phoneNo.toString(),
          customer_id: userInfo?.id,
          pickup_address: pickUpAddress,
          dropOff_address: dropOffAddress,
          status: "cancelled",
          amount: amount,
          distance: tripDirectionDetails.distanceText!,
          bookingNumber: bookingNumber,
          deliveryMode: selectedDelivery.toString(),
          rideType: selectedRide.toString(),
          rated: "0",
          packageType: _selectedPackageVal,
          timeStamp: Timestamp.now(),
        );
        await controller.saveCancelledBookings(booking);
      }
    }
    timer.cancel();
    Get.snackbar('Success', 'Booking $bookingNumber have been canceled');
  }

  Future<void> saveBookings(BookingModel booking) async {
    await controller.saveBooking(
        booking);
  }

  void displayRequestDriverContainer( String bookingNumber) {
    setState(() {
      requestDriverContainer = 420.0;
      ridePriceContainer = 0;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 380.0;
      drawerOpen = false;
      if(mounted){
        timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          setState(() {
            isTimerRunning = true;
          });
          await checkOrderStatus(bookingNumber);
          counter++;
          print(counter);
        });
      }
    });
  }

  Future<void> checkOrderStatus(String bookingNumber) async {
    if(mounted){
      // userRepo.getOrderStatusData(bookingNumber).listen((event) {
      //   setState(() {
      //     _orderStats = event;
      //   });
      // });
      _bookingStatusSubscription = userRepo.getBookingStatusData(bookingNumber).listen((event) {
        setState(() {
          bookingModel = event;
        });
      });

      if(!mounted) {
        return;
      }

      if(bookingModel?.status == 'active'){
        showDriverModal(context);
        timer.cancel();
        setState(() {
          isTimerRunning = false;
        });
      } else if(counter >= 20){
        if(!mounted){return;}
        timer.cancel();
        setState(() {
          isTimerRunning = false;
        });
        resetApp();
        showNoDriverAlert(context);
      }
    } else{
      return;
    }
  }

  void showDriverModal(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => SizedBox(
        height: 380,
          child: SingleChildScrollView(child: DriverStatusScreen(driverID: bookingModel?.driver_id, bookingModel: bookingModel,)),
        ),
    );
  }

  Future<void>showNoDriverAlert(BuildContext context) async {
    return await showDialog(context: context, builder: (context){
      return StatefulBuilder(builder: (context, setState){
        var isDark = getXSwitchState.isDarkMode;
        return AlertDialog(
          title: Center(child: Text("Notice!", style: Theme.of(context).textTheme.titleLarge,)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("No Driver Found ",
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text("if assigned",
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text("you will be notified",
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 35,),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Center(child: Text("Yes Notify Me".toUpperCase())),
                  ),
                  const SizedBox(height: 10.0,),
                  OutlinedButton(
                    onPressed: () async{
                      await cancelBookingRequest(bookingNumber);
                      if(mounted){
                        Navigator.pop(context);
                      }
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Center(child: Text("Cancel Booking".toUpperCase())),
                  ),

                ],
              ),
            ],
          ),
        );
      });
    });
  }

  resetApp(){
    setState(() {
      drawerOpen = true;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
      // userRepo.dispose();
      Get.offAll(() => const UserDashboard());
    });
  }

  void displayRideDetailsContainer() async {
   modeFuture = _getAllModes();
   setState(() {
    rideDetailsContainer = 0;
    ridePriceContainer = 400.0;
    bottomPaddingOfMap = 400.0;
    drawerOpen = false;
   });
 }

 void cardPayment() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   final userEmail = prefs.getString("userEmail");
   int? price = int.tryParse(amount??"")! * 100;
   final bookingNum = MyOgaFormatter.generateBookingNumber();
   final user = FirebaseAuth.instance.currentUser!;
   bookingNumber = bookingNum;
   var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
   var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;
   final email = user.email;
   final BookingModel booking;
   if (email == null) {
     final phone = user.phoneNumber;
     UserModel? userInfo = await userRepo.getUserDetailsWithPhone(phone!);
     booking = BookingModel(
       payment_method: _selectedPaymentVal,
       additional_details: _addController.text.trim(),
       dropOff_latitude: dropOff?.latitude.toString(),
       dropOff_longitude: dropOff?.longitude.toString(),
       pickUp_latitude: pickUp?.latitude.toString(),
       pickUp_longitude: pickUp?.longitude.toString(),
       created_at: DateTime.now().toString(),
       customer_name: userInfo?.fullname.toString(),
       customer_phone: userInfo?.phoneNo.toString(),
       customer_id: userInfo?.id,
       pickup_address: pickUp?.placeName.toString(),
       dropOff_address: dropOff?.placeName.toString(),
       status: "pending",
       amount: amount,
       distance: tripDirectionDetails.distanceText!,
       bookingNumber: bookingNum,
       deliveryMode: selectedDelivery.toString(),
       rideType: selectedRide.toString(),
       rated: "0",
       packageType: _selectedPackageVal,
       timeStamp: Timestamp.now(),
     );
   }
   else {
     UserModel? userInfo = await userRepo.getUserDetailsWithEmail(email!);
     booking = BookingModel(
       payment_method: _selectedPaymentVal,
       additional_details: _addController.text.trim(),
       dropOff_latitude: dropOff?.latitude.toString(),
       dropOff_longitude: dropOff?.longitude.toString(),
       pickUp_latitude: pickUp?.latitude.toString(),
       pickUp_longitude: pickUp?.longitude.toString(),
       created_at: DateTime.now().toString(),
       customer_name: userInfo?.fullname.toString(),
       customer_phone: userInfo?.phoneNo.toString(),
       customer_id: userInfo?.id,
       pickup_address: pickUp?.placeName.toString(),
       dropOff_address: dropOff?.placeName.toString(),
       status: "pending",
       amount: amount,
       distance: tripDirectionDetails.distanceText!,
       bookingNumber: bookingNum,
       deliveryMode: selectedDelivery.toString(),
       rideType: selectedRide.toString(),
       rated: "0",
       packageType: _selectedPackageVal,
       timeStamp: Timestamp.now(),
     );
   }
   Charge charge = Charge()
     ..amount = price
     ..reference = 'ref ${DateTime.now()}'
     ..email = userEmail
     ..currency = 'NGN';

   CheckoutResponse response = await plugin.checkout(
     context,
     charge: charge,
     method: CheckoutMethod.card
   );

   if(response.status == true){
     saveBookings(booking);
     message = "Payment was successful. Ref: ${response.reference}";
     Get.snackbar("Success", message,
         snackPosition: SnackPosition.TOP,
         backgroundColor: Colors.white,
         colorText: Colors.green);
     displayRequestDriverContainer(bookingNum);
     if(mounted){}
   } else {
     Get.snackbar("Error", response.message,
         snackPosition: SnackPosition.BOTTOM,
         backgroundColor: Colors.blueGrey.withOpacity(0.1),
         colorText: Colors.red);
   }
 }

  Future<List<DeliveryModeModel>?>_getAllModes() async {
    return await _pController.getAllMode();
  }

  void locatePosition() async {
    ///Asking Users Permission
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    // CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 16);
    // newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  }


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(9.072264, 7.491302),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    getPlaceDirection();
    modeFuture = _getAllModes();
    pickUpLat = Provider.of<AppData>(context, listen: false).pickUpLocation?.latitude;
    pickUpLng = Provider.of<AppData>(context, listen: false).pickUpLocation?.longitude;
    dropOffLat = Provider.of<AppData>(context, listen: false).dropOffLocation?.latitude;
    dropOffLng = Provider.of<AppData>(context, listen: false).dropOffLocation?.longitude;
    pickUpAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
    dropOffAddress = Provider.of<AppData>(context, listen: false).dropOffLocation?.placeName;
    // plugin.initialize(publicKey: 'pk_test_51c4b33f9510df51a4822f59bbbd555cdc0f3748');
    plugin.initialize(publicKey: '${dotenv.env['pubKey']}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _pController.dispose();
    //controller.dispose();
    //_addController.dispose();
    // userRepo.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
    pickUpLocation = placeAddress ?? "";
    String? dropPlaceAddress = Provider.of<AppData>(context, listen: false).dropOffLocation?.placeName;
    dropOffLocation = dropPlaceAddress ?? "";
    return Scaffold(
      appBar: DashboardAppBar(),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locatePosition();

            },
          ),
          //Hamburger Drawer

          ///Ride Container Details
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              // ignore: deprecated_member_use
              // vsync: this,
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainer,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87 : Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16.0), topLeft: Radius.circular(16.0),),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Select Ride", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center,),
                          const SizedBox(height: 10.0,),
                          SelectRide(
                            LineAwesomeIcons.truck_side,
                            "Truck",
                            moRideTruck,
                          ),
                          const SizedBox(height: 20.0,),
                          SelectRide(
                              LineAwesomeIcons.motorcycle,
                              "Motorcycle",
                              moRideMotorcycle,
                          ),
                          const SizedBox(height: 20.0,),
                          TextFormField(
                            controller: _addController,
                            decoration: const InputDecoration(
                              label: Text(moAddPackageDetails),
                              border: OutlineInputBorder(),
                            ),
                            minLines: 3, // any number you need (It works as the rows for the textarea)
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                          const SizedBox(height: 20.0,),
                          DropdownButtonFormField(
                            value: _selectedPackageVal,
                            items: _packageTypeList
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedPackageVal = val as String;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colors.deepPurple,
                            ),
                            dropdownColor: isDark ? Colors.grey.shade900 : Colors.deepPurple.shade100,
                            decoration: const InputDecoration(
                              labelText: "Select Package Type",
                              prefixIcon: Icon(
                                Icons.wallet,
                                color: Colors.deepPurple,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10.0,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (){
                                  if(selectedRide == null){
                                    Get.snackbar(
                                        "Notice", "Your need to select a ride type.",
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.white,
                                        colorText: Colors.red);
                                  } else {
                                    displayRideDetailsContainer();
                                  }
                                  },
                                child: Text(moProceed.toUpperCase()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          ///Price Container Details
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              // ignore: deprecated_member_use
              // vsync: this,
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: ridePriceContainer,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87.withOpacity(0.9) : Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16.0), topLeft: Radius.circular(16.0),),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Text("Select Delivery Mode", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center,),
                      const SizedBox(height: 10.0,),
                      Flexible(
                        child: FutureBuilder<List<DeliveryModeModel>?>(
                          future: modeFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                //Controllers
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (c, index){
                                    return SelectDeveryMode(
                                        LineAwesomeIcons.car_side,
                                        snapshot.data![index].name,
                                        snapshot.data![index].name,
                                        snapshot.data![index].duration,
                                        AssistanceMethods.calculateFares(tripDirectionDetails,
                                          snapshot.data![index].rate!,
                                          snapshot.data![index].minimumPrice!,
                                          snapshot.data![index].startPrice
                                        ),
                                        tripDirectionDetails.distanceText!
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
                      //SelectDeveryMode(
                      //    LineAwesomeIcons.car_side,
                      //    1,
                      //    moExpress,
                      //    moExpressDays,
                      //    ((tripDirectionDetails != null) ? "\N${AssistanceMethods.calculateFares(tripDirectionDetails)}" : "" ),
                      //    tripDirectionDetails.distanceText!
                      //),
                      const SizedBox(height: 20.0,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          value: _selectedPaymentVal,
                          items: _paymentMethodList
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPaymentVal = val as String;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.deepPurple,
                          ),
                          dropdownColor: Colors.deepPurple.shade50,
                          decoration: const InputDecoration(
                            labelText: "Select Payment Method",
                            prefixIcon: Icon(
                              Icons.wallet,
                              color: Colors.deepPurple,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(selectedDelivery == null){
                                Get.snackbar(
                                    "Notice", "Your need to select a delivery mode.",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.white,
                                    colorText: Colors.red);
                              } else {
                                final bookingNum = MyOgaFormatter.generateBookingNumber();
                                final user = FirebaseAuth.instance.currentUser!;
                                bookingNumber = bookingNum;
                                var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
                                var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;
                                final email = user.email;
                                    if(_selectedPaymentVal == "Card"){
                                      cardPayment();
                                    }
                                    else {
                                      if (email == null) {
                                        final phone = user.phoneNumber;
                                        UserModel? userInfo = await userRepo.getUserDetailsWithPhone(phone!);
                                        final booking = BookingModel(
                                          payment_method: _selectedPaymentVal,
                                          additional_details: _addController.text
                                              .trim(),
                                          dropOff_latitude: dropOff?.latitude
                                              .toString(),
                                          dropOff_longitude: dropOff?.longitude
                                              .toString(),
                                          pickUp_latitude: pickUp?.latitude
                                              .toString(),
                                          pickUp_longitude: pickUp?.longitude
                                              .toString(),
                                          created_at: DateTime.now().toString(),
                                          customer_name: userInfo?.fullname
                                              .toString(),
                                          customer_phone: userInfo?.phoneNo
                                              .toString(),
                                          customer_id: userInfo?.id,
                                          pickup_address: pickUp?.placeName
                                              .toString(),
                                          dropOff_address: dropOff?.placeName
                                              .toString(),
                                          status: "pending",
                                          amount: amount,
                                          distance: tripDirectionDetails
                                              .distanceText!,
                                          bookingNumber: bookingNum,
                                          deliveryMode: selectedDelivery.toString(),
                                          rideType: selectedRide.toString(),
                                          packageType: _selectedPackageVal,
                                          timeStamp: Timestamp.now(),
                                        );
                                        await SignUpController.instance.saveBooking(booking);
                                        displayRequestDriverContainer(bookingNum);
                                      }
                                      else {
                                        UserModel? userInfo = await userRepo.getUserDetailsWithEmail(email!);
                                        final booking = BookingModel(
                                          payment_method: _selectedPaymentVal,
                                          additional_details: _addController.text.trim(),
                                          dropOff_latitude: dropOff?.latitude.toString(),
                                          dropOff_longitude: dropOff?.longitude.toString(),
                                          pickUp_latitude: pickUp?.latitude.toString(),
                                          pickUp_longitude: pickUp?.longitude.toString(),
                                          created_at: DateTime.now().toString(),
                                          customer_name: userInfo?.fullname.toString(),
                                          customer_phone: userInfo?.phoneNo.toString(),
                                          customer_id: userInfo?.id,
                                          pickup_address: pickUp?.placeName.toString(),
                                          dropOff_address: dropOff?.placeName.toString(),
                                          status: "pending",
                                          amount: amount,
                                          distance: tripDirectionDetails.distanceText!,
                                          bookingNumber: bookingNum,
                                          deliveryMode: selectedDelivery.toString(),
                                          rideType: selectedRide.toString(),
                                          packageType: _selectedPackageVal,
                                          timeStamp: Timestamp.now(),
                                        );
                                        await SignUpController.instance.saveBooking(booking);
                                        displayRequestDriverContainer(bookingNum);
                                      }
                                  }
                              }
                              //PackageDetails packageData = await userRepo.getPackageDetails(userInfo.id!)
                            },

                            child: Text(moProceed.toUpperCase()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ///Booking Processing / Looking for rider sheet
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                  color: isDark ? Colors.black87 : Colors.white,
                ),
                height: requestDriverContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text("Order Placed", style: Theme.of(context).textTheme.headlineSmall,),
                      const SizedBox(height: 12.0,),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Booking Request Processing....',
                              textStyle: colorizeTextStyle, textAlign: TextAlign.center,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Please Wait....',
                              textStyle: colorizeTextStyle, textAlign: TextAlign.center,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Looking for your rider..',
                              textStyle: colorizeTextStyle, textAlign: TextAlign.center,
                              colors: colorizeColors,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {},

                        ),
                      ),
                      const SizedBox(height: 12.0,),
                      Row(
                        children: [
                          const Image(
                            image: AssetImage(moPickupPic),
                            height: 16.0,
                            width: 16.0,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(moPickupHintText,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(pickUpLocation,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      Row(
                        children: [
                          const Image(
                            image: AssetImage(moPickupPic ),
                            height: 16.0,
                            width: 16.0,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(moDropOffHintText,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(dropOffLocation,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0,),
                      Text("Distance: ${tripDirectionDetails.distanceText}", style: Theme.of(context).textTheme.bodyMedium,),
                      Text("Duration: ${tripDirectionDetails.durationText}", style: Theme.of(context).textTheme.bodyMedium,),
                      const SizedBox(height: 12.0,),
                      GestureDetector(
                        onTap: () async {
                          await cancelBookingRequest(bookingNumber);
                          setState(() {
                            isTimerRunning = false;
                          });
                          resetApp();
                        },
                        child: Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(width: 2.0, color: Colors.purple.shade50,)
                          ),
                          child: const Icon(Icons.close, size: 20.0,),
                        ),
                      ),
                      const SizedBox(height: 5.0,),
                      SizedBox(
                        width: double.infinity,
                        child: Text("Cancel Booking", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,),
                      ),
                      const SizedBox(height: 15.0,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: DraggableFab(
          child: FloatingActionButton(
            onPressed: () {
              if(isTimerRunning){
                timer.cancel();
                setState(() {
                  isTimerRunning = false;
                });
                resetApp();
              }else{
                resetApp();
              }
            },
        backgroundColor: PButtonColor,
        elevation: 10.0,
        child: const Icon(LineAwesomeIcons.times,
            color: Colors.white,
            size: 28.0),
      )),
    );
  }

  Future<void> getPlaceDirection() async {

    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatlng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatlng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    var details = await AssistanceMethods.obtainPlaceDirectionDetails(pickUpLatlng, dropOffLatlng);
    tripDirectionDetails = details!;
    // if(mounted){
    //   setState(() {
    //
    //   });
    // }

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details?.encodedPoints ?? "");

    pLineCoordinates.clear();

    if(decodedPolylinePointsResult.isNotEmpty){
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.cast();

    if(mounted){
      setState(() {
        Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
      });
    }

    LatLngBounds latLngBounds;
    if(pickUpLatlng.latitude > dropOffLatlng.latitude && pickUpLatlng.longitude > dropOffLatlng.longitude){
      latLngBounds = LatLngBounds(southwest: dropOffLatlng, northeast: pickUpLatlng);
    }
    else if(pickUpLatlng.longitude > dropOffLatlng.longitude){
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatlng.latitude, dropOffLatlng.longitude), northeast: LatLng(dropOffLatlng.latitude, pickUpLatlng.longitude));
    }
    else if(pickUpLatlng.latitude > dropOffLatlng.latitude){
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatlng.latitude, pickUpLatlng.longitude), northeast: LatLng(pickUpLatlng.latitude, dropOffLatlng.longitude));
    }
    else {
      latLngBounds = LatLngBounds(southwest: pickUpLatlng, northeast: dropOffLatlng);
    }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Uint8List? resizeImage(Uint8List data, width, height) {
      Uint8List? resizedData = data;
      IMG.Image? img = IMG.decodeImage(data);
      IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
      resizedData = Uint8List.fromList(IMG.encodePng(resized));
      return resizedData;
    }

    String imgUrl = "https://cdn-icons-png.freepik.com/256/7193/7193391.png?ga=GA1.1.1645371941.1706954763&semt=ais";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgUrl))
        .load(imgUrl))
        .buffer
        .asUint8List();

    Uint8List? myPosition = resizeImage(bytes, 70, 70);

    String parcelUrl = "https://cdn-icons-png.freepik.com/256/5161/5161266.png?ga=GA1.1.1645371941.1706954763&semt=ais";

    Uint8List dropOffBytes = (await NetworkAssetBundle(Uri.parse(parcelUrl))
        .load(parcelUrl))
        .buffer
        .asUint8List();

    Uint8List? dropOffPosition = resizeImage(dropOffBytes, 70, 70);



    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.fromBytes(myPosition!),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatlng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.fromBytes(dropOffPosition!),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatlng,
      markerId: const MarkerId("dropOffId"),
    );

    if(mounted){
      setState(() {
        markersSet.add(pickUpLocMarker);
        markersSet.add(dropOffLocMarker);
      });
    }

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatlng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: const CircleId("pickUpId"),

    );
    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatlng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: const CircleId("dropOffId"),
    );

    if(mounted){
      setState(() {
        circlesSet.add(pickUpLocCircle);
        circlesSet.add(dropOffLocCircle);
      });
    }
  }
}
