import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myoga/configMaps.dart';
import 'package:myoga/services/controllers/Assistant/requestController.dart';
import 'package:myoga/services/models/allUsers.dart';
import 'package:myoga/utils/formatter/formatter.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/directDetails.dart';
import '../Data_handler/appData.dart';

class AssistanceMethods {

  static Future<String> searchCoordinateAddress(Position position, context) async {
    String streetAddress = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKay";

    var response = await RequestAssistanceController.getRequest(url);

    if(response != "failed"){
      streetAddress = response["results"][0]["formatted_address"];

      Address userPickUpAddress = Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = streetAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return streetAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=AIzaSyBnh_SIURwYz-4HuEtvm-0B3AlWt0FKPbM";

    var res = await RequestAssistanceController.getRequest(directionUrl);
    print("Direction Response: $res");

    if(res == "failed"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static String calculateFares(DirectionDetails directionDetails, String? rate, String? minimumPrice, String? startPrice){
    double? intRate = double.tryParse(rate!);
    double? intMinimumPrice = double.tryParse(minimumPrice!);
    double? intStartPrice = double.tryParse(startPrice!);
    // double timeTravelledFares = (directionDetails.durationValue! / 60) * intRate!;
    double distanceTravelledFares = (directionDetails.distanceValue!/1000) * intRate!;
    double totalFare = intMinimumPrice! + distanceTravelledFares + intStartPrice!;
    double percentageToAdd = 0.35 * totalFare;

    double totalTripFare = totalFare + percentageToAdd;

    //convert to naira
    //double totalNaira = totalFare * 740;
    int roundedTotal = totalTripFare.round();

    return MyOgaFormatter.currencyFormatter(double.parse(roundedTotal.truncate().toString()));
  }

  //static void getCurrentOnlineUserInfo() async {
  //  firebaseUser = await FirebaseAuth.instance.currentUser!;
  //  String userId = firebaseUser.uid;
  //  DatabaseReference reference = FirebaseDatabase.instance.ref().child("users").child(userId);
//
   // reference.once().then((event){
   //   final dataSnapShot = event.snapshot;
   //   if(dataSnapShot.value != null){
   //     userCurrentInfo = Users.fromSnapshot(dataSnapShot);
   //   }
   // });
 // }

}