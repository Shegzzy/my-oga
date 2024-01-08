import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/configMaps.dart';
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

  TextEditingController dropOffTextEditingController = TextEditingController();
  TextEditingController pickUpTextEditingController = TextEditingController();
  List<PlacePredictions> dropOffPlacePredictionList = [];
  final GetXSwitchState getXSwitchState = Get.find();

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dropOffTextEditingController.dispose();
    pickUpTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    String? placeAddress = Provider.of<AppData>(context).pickUpLocation?.placeName;
    pickUpTextEditingController.text = placeAddress ??"";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
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
                                onChanged: (val){
                                  Get.to(const PickupLocationScreen());
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

            //tile for prediction
            const SizedBox(height: 10.0,),
            (dropOffPlacePredictionList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (context, index){
                  return DropOffPredictionTile(placePredictions: dropOffPlacePredictionList[index],);
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 5.0,),
                itemCount:dropOffPlacePredictionList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),
            const SizedBox(height: 20.0,),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(onPressed: (){
                BookingAddress bookingAddress = BookingAddress();
                bookingAddress.pickUpLocation = pickUpTextEditingController.text;
                bookingAddress.dropOffLocation = dropOffTextEditingController.text;
                Navigator.pop(context);
                Get.to(() => const SelectRideScreen());
              },
                  child: Text(moNext.toUpperCase(), style: const TextStyle(fontSize: 20.0,),)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void findDropPlace(String placeName) async {

    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKay&components=country:ng";

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
}

class DropOffPredictionTile extends StatelessWidget {
  final PlacePredictions? placePredictions;
  DropOffPredictionTile({Key? key, this.placePredictions}) : super(key: key);

  TextEditingController dropOffTextEditingController = TextEditingController();
  TextEditingController pickUpTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
    pickUpTextEditingController.text = placeAddress!;

    return TextButton(
      onPressed: (){
        getPlaceAddressDetails(placePredictions!.place_id ??"", context);
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
                    Text(placePredictions!.main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge,),
                    const SizedBox(height: 2.0,),
                    Text(placePredictions!.secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium,),
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
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => const ProgressDialog(message: "Setting Location, Please wait....",)
    );

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKay";
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
      Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);

      String? dropPlaceAddress = Provider.of<AppData>(context, listen: false).dropOffLocation?.placeName;
      dropOffTextEditingController.text = dropPlaceAddress!;

      BookingAddress bookingAddress = BookingAddress();
      bookingAddress.pickUpLocation = pickUpTextEditingController.text;
      bookingAddress.dropOffLocation = dropOffTextEditingController.text;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectRideScreen()),);
    }
  }
}

