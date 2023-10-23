import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/signup_controller.dart';
import '../../notifi_services.dart';
import '../Forget_Password/Forget_Password_Otp/otp_screen.dart';


class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final controller = Get.put(SignUpController());
  final countryPicker = const FlCountryCodePicker();

  CountryCode countryCode = const CountryCode(name: "Nigeria", code: "NG", dialCode: "+234");

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _formkey = GlobalKey<FormState>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30.0 * 4,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: const AssetImage(moWelcomeLogo), height: size.height * 0.2,),
                  Text(moLoginPhone, style: Theme
                      .of(context)
                      .textTheme
                      .headline4,),
                  Text(moLoginPhoneSubtitle, textAlign: TextAlign.center, style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 3,
                      blurRadius: 3,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          final code = await countryPicker.showPicker(context: context);
                          if(code != null){
                            countryCode = code;
                          }
                          setState(() {

                          });
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: Container(
                                child: countryCode.flagImage,
                              ),
                            ),
                            Text(countryCode.dialCode, style: Theme.of(context).textTheme.bodyText2,),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60.0,
                      color: moAccentColor.withOpacity(0.2),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: controller.phoneNo,
                        decoration: const InputDecoration(
                          label: Text(moPhoneTitle),
                          hintText: moPhoneTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                          SignUpController.instance.phoneAuthentication(countryCode.dialCode+controller.phoneNo.text.trim());
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("Phone", countryCode.dialCode+controller.phoneNo.text.trim());
                          Get.to(() => const OTPScreen());
                      },
                      child: const Text(moNext),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
