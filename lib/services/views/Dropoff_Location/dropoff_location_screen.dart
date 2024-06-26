import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/configMaps.dart';
import 'package:myoga/repositories/user_repository/user_repository.dart';
import 'package:myoga/services/views/User_Dashboard/user_dashboard.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../widgets/progressDialog.dart';
import '../../controllers/Assistant/requestController.dart';
import '../../controllers/Data_handler/appData.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../../models/address.dart';
import '../../models/booking_address_model.dart';
import '../../models/placePrediction.dart';
import '../Package_Type/package_type_screen.dart';
import '../Pickup_Location/pickup_location_screen.dart';
import '../Select_Ride/select_ride_screen.dart';

class DropOffLocationScreen extends StatefulWidget {
  const DropOffLocationScreen({Key? key}) : super(key: key);

  @override
  State<DropOffLocationScreen> createState() => _DropOffLocationScreenState();
}

class _DropOffLocationScreenState extends State<DropOffLocationScreen> {
  final UserRepository userRepository = Get.find();

  TextEditingController dropOffTextEditingController = TextEditingController();
  TextEditingController pickUpTextEditingController = TextEditingController();
  List<PlacePredictions> dropOffPlacePredictionList = [];
  List<PlacePredictions> pickUpPlacePredictionList = [];
  String? placeAddress;
  bool dropOffPrediction = false;
  bool pickUpPrediction = false;
  bool notWithinRegion = false;

  double? pickUpLat;
  double? pickUpLng;
  double? dropOffLat;
  double? dropOffLng;


  final GetXSwitchState getXSwitchState = Get.find();
  bool isLoading = false;

  TextEditingController userInputTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
    pickUpLat = Provider.of<AppData>(context, listen: false).pickUpLocation?.latitude;
    pickUpLng = Provider.of<AppData>(context, listen: false).pickUpLocation?.longitude;
    pickUpTextEditingController.text = placeAddress ?? "";
  }

@override
  void dispose() {
    super.dispose();
    dropOffTextEditingController.dispose();
    pickUpTextEditingController.dispose();
  }

  bool checkingRegion = false;

  bool isStatePresent(String? stateName) {
    if (stateName == null) return false;
    return userRepository.stateModel.any((state) => state.name == stateName);
  }

  // checking the service available states
  Future<void> regionCheck() async {
    setState(() {
      checkingRegion = true;
    });

    List<Placemark>? pickUpPlaceMark = await placemarkFromCoordinates(pickUpLat!, pickUpLng!);
    List<Placemark>? dropOffPlaceMark = await placemarkFromCoordinates(dropOffLat!, dropOffLng!);
    // print(pickUpPlaceMark.first.administrativeArea);
    // print(dropOffPlaceMark.first.administrativeArea);
    // if(pickUpPlaceMark.first.administrativeArea == dropOffPlaceMark.first.administrativeArea && isStatePresent(dropOffPlaceMark.first.administrativeArea)){
    //   print('true');
    // } else {
    //   print('false');
    // }

    try{
      if(pickUpPlaceMark.first.administrativeArea == dropOffPlaceMark.first.administrativeArea && isStatePresent(dropOffPlaceMark.first.administrativeArea)){
        setState(() {
          notWithinRegion = false;
        });
        if(mounted){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectRideScreen()),);
        }
      } else if(pickUpPlaceMark.first.administrativeArea != dropOffPlaceMark.first.administrativeArea){
        Get.snackbar(
            "Notice", "MyOga services are not interstate",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
        setState(() {
          notWithinRegion = true;
        });
      }
      else{
        setState(() {
          notWithinRegion = true;
        });
      }
    } catch (e){
      throw e.toString();
    } finally{
      setState(() {
        checkingRegion = false;
      });
    }
  }

  // Drop off place address
  Future<void> getDropOffPlaceAddressDetails(String placeId, context) async {

    try{
      setState(() {
        isLoading = true;
      });

      String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${dotenv.env['mapKey']}";
      var res = await RequestAssistanceController.getRequest(placeDetailsUrl);
      if(res == "failed"){
        return;
      }
      if(res["status"] == "OK"){
        Address address = Address();
        address.placeName = res["result"]["name"];
        address.placeId = placeId;
        address.latitude = res["result"]["geometry"]["location"]["lat"];
        address.longitude = res["result"]["geometry"]["location"]["lng"];

        setState(() {
          dropOffLat = address.latitude;
          dropOffLng = address.longitude;
        });

        Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);

        String? dropPlaceAddress = Provider.of<AppData>(context, listen: false).dropOffLocation?.placeName;
        dropOffTextEditingController.text = dropPlaceAddress!;

        BookingAddress bookingAddress = BookingAddress();
        bookingAddress.pickUpLocation = pickUpTextEditingController.text;
        bookingAddress.dropOffLocation = dropOffTextEditingController.text;

        if(pickUpTextEditingController.text.isNotEmpty){
          regionCheck();
        }else{
          return;
        }
      }
    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        isLoading = false;
      });
    }


  }

  // Pick up place address
  Future<void> getPickUpPlaceAddressDetails(String placeId, context) async {
    // print(placeId);

    try{
      setState(() {
        isLoading = true;
      });

      String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${dotenv.env['mapKey']}";
      var res = await RequestAssistanceController.getRequest(placeDetailsUrl);
      if(res == "failed"){
        return;
      }
      if(res["status"] == "OK") {
        Address address = Address();
        address.placeName = res["result"]["name"];
        address.placeId = placeId;
        address.latitude = res["result"]["geometry"]["location"]["lat"];
        address.longitude = res["result"]["geometry"]["location"]["lng"];

        setState(() {
          pickUpLat = address.latitude;
          pickUpLng = address.longitude;
        });

        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress(address);
        // String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;

        pickUpTextEditingController.text = address.placeName!;
        if(dropOffTextEditingController.text.isNotEmpty){
          regionCheck();
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectRideScreen()),);
        }else{
          return;
        }

      }
    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  // Drop off function
  void findDropPlace(String placeName) async {

    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${dotenv.env['mapKey']}&components=country:ng";

      var res = await RequestAssistanceController.getRequest(autoCompleteUrl);

      if(res == "failed"){
        return ;
      }

      if(res["status"] == "OK"){
        var predictions = res["predictions"];

        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();

        setState(() {
          dropOffPlacePredictionList = placesList;
        });
      }

    }

  }

  // Pick up function
  void findPickUpPlace(String placeName) async {

    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${dotenv.env['mapKey']}&components=country:ng";

      var res = await RequestAssistanceController.getRequest(autoCompleteUrl);

      if(res == "failed"){
        return ;
      }

      if(res["status"] == "OK"){
        var predictions = res["predictions"];

        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();

        setState(() {
          pickUpPlacePredictionList = placesList;
        });
      }

    }

  }



  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    // placeAddress = Provider.of<AppData>(context).pickUpLocation?.placeName;
    // pickUpTextEditingController.text = placeAddress ?? "";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.offAll( ()=> const UserDashboard()), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moDropOffSearchTitle, style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: isDark ? Colors.black87.withOpacity(0.001) : Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Image(
                          image: AssetImage(moPickupPic ),
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              //borderRadius: BorderRadius.circular(1.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onTap: () {
                                  // Switch to the user input controller
                                  setState(() {
                                    userInputTextEditingController.text = pickUpTextEditingController.text;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    userInputTextEditingController.text = val;
                                  });
                                  findPickUpPlace(val);
                                },
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: moPickupHintText,
                                  fillColor: Colors.grey[400],
                                  //filled: true,
                                  border: InputBorder.none,
                                  floatingLabelStyle: const TextStyle(color: PDarkColor),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.0, color: PButtonColor),
                                  ),
                                  label: Text("PickUp", style: TextStyle(
                                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black38
                                  )),
                                  contentPadding: const EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                  suffixIcon: pickUpTextEditingController.text.isNotEmpty ?
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        pickUpTextEditingController.clear();
                                        pickUpPlacePredictionList.clear();
                                      });
                                    },
                                      child: const Icon(Icons.highlight_remove)) : null
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        const Image(
                          image: AssetImage(moPickupPic ),
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              //borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (val){
                                  findDropPlace(val);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                  hintText: moDropOffHintText,
                                  fillColor: Colors.grey[400],
                                  //filled: true,
                                  border: InputBorder.none,
                                  floatingLabelStyle: const TextStyle(color: PButtonColor),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.0, color: PButtonColor),
                                  ),
                                  label: Text("Drop-Off", style: TextStyle(
                                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black38
                                  )),
                                  contentPadding: const EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                    suffixIcon: dropOffTextEditingController.text.isNotEmpty ?
                                    InkWell(
                                        onTap: (){
                                          setState(() {
                                            dropOffTextEditingController.clear();
                                            dropOffPlacePredictionList.clear();
                                          });
                                        },
                                        child: const Icon(Icons.highlight_remove)) : null
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if(isLoading)
              const ProgressDialog(message: "Setting Location, Please wait....",),

            //tile for drop off prediction
            const SizedBox(height: 10.0,),
            (dropOffPlacePredictionList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (context, index){
                  return TextButton(
                    onPressed: () async{
                      await getDropOffPlaceAddressDetails(dropOffPlacePredictionList[index].place_id ??"", context);
                      dropOffPlacePredictionList.clear();
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0,),
                        Row(
                          children: [
                            const Icon(Icons.add_location),
                            const SizedBox(height: 14.0,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0,),
                                  Text(dropOffPlacePredictionList[index].main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge,),
                                  const SizedBox(height: 2.0,),
                                  Text(dropOffPlacePredictionList[index].secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium,),
                                  const SizedBox(height: 8.0,),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0,),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 5.0,),
                itemCount:dropOffPlacePredictionList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),

            //tile for pick up prediction
            const SizedBox(height: 10.0,),
            (pickUpPlacePredictionList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (context, index){
                  return TextButton(
                    onPressed: () async{
                      await getPickUpPlaceAddressDetails(pickUpPlacePredictionList[index].place_id ??"", context);
                      print(pickUpPlacePredictionList[index].place_id);
                      pickUpPlacePredictionList.clear();
                    },
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0,),
                        Row(
                          children: [
                            const Icon(Icons.add_location),
                            const SizedBox(height: 14.0,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0,),
                                  Text(pickUpPlacePredictionList[index].main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge,),
                                  const SizedBox(height: 2.0,),
                                  Text(pickUpPlacePredictionList[index].secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium,),
                                  const SizedBox(height: 8.0,),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0,),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 5.0,),
                itemCount: pickUpPlacePredictionList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),


            const SizedBox(height: 20.0,),

            SizedBox(
              // width: 250.0,
              child: checkingRegion ? const SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator()) : Visibility(
                visible: notWithinRegion ? true : false,
                child: const ElevatedButton(
                  onPressed: null,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text("MyOga service is currently unavailable in this state", style: TextStyle(fontSize: 11.0,),),
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// class DropOffPredictionTile extends StatelessWidget {
//   final PlacePredictions? placePredictions;
//   DropOffPredictionTile({Key? key, this.placePredictions}) : super(key: key);
//
//   TextEditingController dropOffTextEditingController = TextEditingController();
//   TextEditingController pickUpTextEditingController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
//     pickUpTextEditingController.text = placeAddress!;
//
//     return TextButton(
//       onPressed: (){
//         // getPlaceAddressDetails(placePredictions!.place_id ??"", context);
//       },
//       child: Column(
//         children: [
//           const SizedBox(height: 8.0,),
//           Row(
//             children: [
//               const Icon(Icons.add_location),
//               const SizedBox(height: 14.0,),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 8.0,),
//                     Text(placePredictions!.main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge,),
//                     const SizedBox(height: 2.0,),
//                     Text(placePredictions!.secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium,),
//                     const SizedBox(height: 8.0,),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0,),
//         ],
//       ),
//     );
//   }
//
// }

