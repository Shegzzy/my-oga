
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../repositories/authentication_repository/authentication_repository.dart';
import '../../../repositories/user_repository/user_repository.dart';
import '../../controllers/Data_handler/appData.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/signup_controller.dart';
import '../../models/booking_address_model.dart';
import '../../models/details_model.dart';
import '../../models/package_details_model.dart';
import '../../models/user_model.dart';
import '../Payment_Methods/payment_methods_screen.dart';
import '../Select_Ride/select_ride_screen.dart';
import '../User_Dashboard/user_dashboard.dart';

 String pickUpLocation = "";
 String dropOffLocation = "";

class ConfirmOrderScreen extends StatelessWidget {
    ConfirmOrderScreen({Key? key, required this.packageModel}) : super(key: key);

    PackageModel packageModel;

   final controller = Get.put(ProfileController());
    UserRepository userRepo = Get.put(UserRepository());
    final signController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    String? placeAddress = Provider.of<AppData>(context, listen: false).pickUpLocation?.placeName;
    pickUpLocation = placeAddress!;
    String? dropPlaceAddress = Provider.of<AppData>(context, listen: false).dropOffLocation?.placeName;
    dropOffLocation = dropPlaceAddress!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: const Text(moConfirmOrderTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
                    children: [
                      const SizedBox(height: 16.0),
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                //borderRadius: BorderRadius.circular(1.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(moPickupHintText,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                //borderRadius: BorderRadius.circular(1.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(pickUpLocation,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                //borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(moDropOffHintText,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                //borderRadius: BorderRadius.circular(1.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(dropOffLocation,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0,),
                      ListTile(
                        contentPadding: const EdgeInsets.all(5.0),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.0, color: Colors.grey.shade300)
                        ),
                        leading: const Image(
                          image: AssetImage(moBox),
                          height: 60.0,
                          width: 60.0,
                        ),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(label: Text(packageModel.paymentType),
                              backgroundColor: Colors.deepPurple,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            Text('Weight: ${packageModel.packageWeight} kg', style: Theme.of(context).textTheme.headlineSmall,),
                            Text('Height: ${packageModel.packageHeight} cm', style: Theme.of(context).textTheme.headlineSmall,),
                            Text('Width: ${packageModel.packageWidth} cm', style: Theme.of(context).textTheme.headlineSmall,),
                            const SizedBox(height: 10.0,),
                            Text(moAddPackageDetails, style: Theme.of(context).textTheme.titleLarge,),
                            const SizedBox(height: 5.0,),
                            Text(packageModel.additionalDetails??"", style: Theme.of(context).textTheme.bodyMedium,),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser!;
                            final email = user.email;
                            if(email == null){
                              final phone = user.phoneNumber;
                              UserModel? userInfo = await userRepo.getUserDetailsWithPhone(phone!);

                              final package = PackageDetails(
                                  packageWeight: packageModel.packageWeight,
                                  packageHeight: packageModel.packageHeight,
                                  packageWidth: packageModel.packageWidth,
                                  paymentType: packageModel.paymentType,
                                  additionalDetails: packageModel.additionalDetails,
                                  customerId: userInfo?.id,
                              );
                              await signController.savePackage(package);
                            }
                            else{
                              UserModel? userInfo = await userRepo.getUserDetailsWithEmail(email);
                              final package = PackageDetails(
                                packageWeight: packageModel.packageWeight,
                                packageHeight: packageModel.packageHeight,
                                packageWidth: packageModel.packageWidth,
                                paymentType: packageModel.paymentType,
                                additionalDetails: packageModel.additionalDetails,
                                customerId: userInfo?.id,
                              );
                              await signController.savePackage(package);
                            }

                            Get.to(const SelectRideScreen());
                          },
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: Text(moProceed.toUpperCase()),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
  }
}
