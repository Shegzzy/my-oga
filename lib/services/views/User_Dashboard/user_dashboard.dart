import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myoga/services/controllers/Data_handler/appData.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../../repositories/user_repository/user_repository.dart';
import '../../../widgets/progressDialog.dart';
import '../../controllers/Assistant/assistanceMethods.dart';
import 'package:myoga/services/models/user_model.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../../controllers/profile_controller.dart';
import '../../notifi_services.dart';
import '../Dashboard/widget/appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Dropoff_Location/dropoff_location_screen.dart';
import '../Profile/profile_screen.dart';


class UserDashboard extends StatefulWidget {


  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}



class _UserDashboardState extends State<UserDashboard> with TickerProviderStateMixin
{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;
  UserRepository _userRepo = Get.put(UserRepository());
  var myUserDetail = UserModel().obs;
  ProfileController _controller = Get.put(ProfileController());
  final _db = FirebaseFirestore.instance;
  late StreamSubscription<UserModel> _subscription;
  final GetXSwitchState getXSwitchState = Get.find();



  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String? _userID, userPic, userName, userEmail, _token;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isLoading = false;

  Future<void> locatePosition() async {
    ///Asking Users Permission
    try{
      setState(() {
        isLoading = true;
      });
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

      CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String address = await AssistanceMethods.searchCoordinateAddress(position, context);

    }catch (e){
      print('Error $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    NotificationService().requestNotificationPermission();
    NotificationService().firebaseInit(context);
    NotificationService().setUpInteractMessage(context);
    //NotificationService().isTokenRefresh();
    getToken();
    _subscription = _controller.getUserDataStream().listen((event) {
      setState(() {
        myUserDetail.value = event;
        savePref();
      });
    });
    /// Stop Progress Bar
    // ignore: use_build_context_synchronously
  }




  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString("token");
    await NotificationService().getDeviceToken().then((token) {
      if (kDebugMode) {
        print(" YOUR TOKEN IS: $token");
        print(" YOUR Pref TOKEN IS: $savedToken");
      }
      setState(() {
        _token = token;
      });
      if(_token != savedToken || savedToken == null){
        updateToken();
        }
      }
    );
  }

  void updateToken () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userID = prefs.getString("aUserID");
    final userIDd = prefs.getString("userID");
    if(_userID != null){
      await _db.collection("Users").doc(userIDd).update({
        "Token": _token
      });
      prefs.setString("token", _token!);
    } else {
      await _db.collection("Users").doc(userIDd).update({
        "Token": _token
      });
      prefs.setString("token", _token!);
    }
  }


  void savePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", myUserDetail.value.fullname ?? "");
    prefs.setString("userEmail", myUserDetail.value.email ?? "");
    prefs.setString("userPic", myUserDetail.value.profilePic ?? "");
  }

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      userName = prefs.getString("userName");
      userPic = prefs.getString("userPic");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //timer.cancel();
    _controller.dispose();
    _userRepo.dispose();
    _subscription.cancel();
    newGoogleMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getPref();
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
      appBar: const DashboardAppBar(),
      body: Stack(
        children: [
          if (isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            async{
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 280.0;
              });
              locatePosition();
            },
          ),
          
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 280.0,
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Hi, ", style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                const SizedBox(width: 8.0,),
                                GestureDetector(
                                    child: Text(myUserDetail.value.fullname ?? userName ?? "", style: const TextStyle(fontSize: 18.0, color: Colors.blueAccent), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                    onTap: (){
                                    Get.to( const ProfileScreen());
                                    },
                                ),
                              ],
                            ),
                            Text("Got any deliveries?", style: Theme.of(context).textTheme.headlineMedium, maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        GestureDetector(
                          onTap: (){
                            Get.to( const ProfileScreen());
                          },
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(100),
                                child: myUserDetail.value.profilePic == null || myUserDetail.value.profilePic == ""
                                    ? Icon(Icons.person, color: isDark ? Colors.white : Colors.grey,):
                                Image(image: NetworkImage(userPic ?? ""), fit: BoxFit.cover, loadingBuilder: (context,
                                        child, loadingProgress) {if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                          (context, object, stack) {
                                        return Icon(Icons.person, color: isDark ? Colors.white : Colors.grey,);
                                        },
                                      )
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0,),
                    GestureDetector(
                      onTap: (){
                        Get.to(() => const DropOffLocationScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87.withOpacity(0.001) : Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 1.0,
                              spreadRadius: 0.01,
                              offset: Offset(0.7, 0.7)
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(LineAwesomeIcons.search, color: moSecondarColor,),
                              const SizedBox(width: 10.0,),
                              Text("Search Location", style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    Row(
                      children: [
                        const Icon(LineAwesomeIcons.location_arrow, color: moSecondarColor,),
                        const SizedBox(width: 12.0,),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text( Provider.of<AppData>(context).pickUpLocation != null
                                    ? Provider.of<AppData>(context).pickUpLocation!.placeName!
                                    : "Your Address", style: Theme.of(context).textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                ),
                                const SizedBox(height: 4.0,),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text("current location address", style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0,),
                      ],
                    ),
                    const SizedBox(height: 5.0,),
                    const Divider(
                      height: 1.0,
                      color: moSecondarColor,
                      thickness: 1.0,
                    ),
                    const SizedBox(height: 16.0,),
                    //Row(
                    //  children: [
                    //    const Icon(LineAwesomeIcons.location_arrow, color: moSecondarColor,),
                    //    const SizedBox(width: 12.0,),
                    //    GestureDetector(
                    //      onTap: (){ Get.to( const DropOffLocationScreen()); },
                    //      child: Column(
                    //        crossAxisAlignment: CrossAxisAlignment.start,
                    //        children: [
                    //          Text("Add Drop Address", style: Theme.of(context).textTheme.headline6, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    //          const SizedBox(height: 4.0,),
                    //          Text("Your drop-off location address", style: Theme.of(context).textTheme.bodyText1, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    //        ],
                    //      ),
                    //    ),
                    //  ],
                    //),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const DropOffLocationScreen());
        },
        backgroundColor: PButtonColor,
        elevation: 10.0,
          child: const Icon(LineAwesomeIcons.plus,
            color: Colors.white,
            size: 30.0),
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatlng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatlng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => const ProgressDialog(message: "Please wait...",)
    );

    var details = await AssistanceMethods.obtainPlaceDirectionDetails(pickUpLatlng, dropOffLatlng);

    Navigator.pop(context);

    if (kDebugMode) {
      print("THIS IS THE ENCODED POINTS");
      print(details!.encodedPoints);
    }


    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details?.encodedPoints ?? "");

    pLineCoordinates.clear();

    if(decodedPolylinePointsResult.isNotEmpty){
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.cast();

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

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatlng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatlng,
      markerId: const MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

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

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
