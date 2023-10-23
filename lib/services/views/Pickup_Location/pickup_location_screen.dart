import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../widgets/progressDialog.dart';
import '../../controllers/Assistant/requestController.dart';
import '../../controllers/Data_handler/appData.dart';
import '../../models/address.dart';
import '../../models/placePrediction.dart';
import '../Dropoff_Location/dropoff_location_screen.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({Key? key}) : super(key: key);

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {

  final TextEditingController pickUpTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pickUpTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;


    String? placeAddress = Provider.of<AppData>(context).pickUpLocation?.placeName;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moPickupSearchTitle, style: Theme.of(context).textTheme.headline5),
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180.0,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              //borderRadius: BorderRadius.circular(1.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (val){
                                  findPlace(val);
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
                                  label: const Text("PickUp"),
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
            (placePredictionList.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0.0),
                      itemBuilder: (context, index){
                        return PredictionTile(placePredictions: placePredictionList[index],);
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(height: 5.0,),
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
            const SizedBox(height: 20.0,),
            SizedBox(
              width: 250.0,
              child: ElevatedButton(onPressed: (){
                Get.to(const DropOffLocationScreen());
              },
                  child: Text(moNext.toUpperCase(), style: const TextStyle(fontSize: 20.0,),)
              ),
            ),
          ],
        ),
      ),
    );
  }
  void findPlace(String placeName) async {

    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyBnh_SIURwYz-4HuEtvm-0B3AlWt0FKPbM&components=country:ng";

      var res = await RequestAssistanceController.getRequest(autoCompleteUrl);

      if(res == "failed"){
        return ;
      }

      if(res["status"] == "OK"){
        var predictions = res["predictions"];

        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();

        setState(() {
          placePredictionList = placesList;
        });
      }

    }

  }

}

class PredictionTile extends StatelessWidget {
  final PlacePredictions? placePredictions;
  const PredictionTile({Key? key, this.placePredictions}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
                    Text(placePredictions!.main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline6,),
                    const SizedBox(height: 2.0,),
                    Text(placePredictions!.secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText2,),
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

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyBnh_SIURwYz-4HuEtvm-0B3AlWt0FKPbM";
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

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(address);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DropOffLocationScreen()),);
    }
  }
}

