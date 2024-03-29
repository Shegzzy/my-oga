import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/configMaps.dart';
import 'package:myoga/services/controllers/getXSwitchStateController.dart';
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
  final GetXSwitchState getXSwitchState = Get.find();
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pickUpTextEditingController.dispose();
  }

  void findPlace(String placeName) async {

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
          placePredictionList = placesList;
        });
      }

    }

  }

  void getPlaceAddressDetails(String placeId, context) async {
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

        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress(address);
        // String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;

        pickUpTextEditingController.text = address.placeName!;

        print(address.placeName);
      }
    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moPickupSearchTitle, style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180.0,
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
                                  label: Text("PickUp", style: TextStyle(
                                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black38
                                  ),),
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

            if(isLoading)
              const ProgressDialog(message: "Setting Location, Please wait....",),

            //tile for prediction
            const SizedBox(height: 10.0,),
            (placePredictionList.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0.0),
                      itemBuilder: (context, index){
                        return TextButton(
                          onPressed: (){
                            getPlaceAddressDetails(placePredictionList[index].place_id ??"", context);
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
                                        Text(placePredictionList[index].main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge,),
                                        const SizedBox(height: 2.0,),
                                        Text(placePredictionList[index].secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium,),
                                        const SizedBox(height: 8.0,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0,),
                            ],
                          ),
                        );;
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


}

// class PredictionTile extends StatelessWidget {
//   final PlacePredictions? placePredictions;
//   const PredictionTile({Key? key, this.placePredictions}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
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
//                     Text(placePredictions!.main_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline6,),
//                     const SizedBox(height: 2.0,),
//                     Text(placePredictions!.secondary_text ?? "", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText2,),
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
//
// }

