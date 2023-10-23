import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/signup_controller.dart';
import '../../models/user_model.dart';
import '../Forget_Password/Forget_Password_Otp/otp_screen.dart';
import '../Login/login_screen.dart';

class PhoneNumberFormWidget extends StatefulWidget {
  const PhoneNumberFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PhoneNumberFormWidget> createState() => _PhoneNumberFormWidgetState();
}

class _PhoneNumberFormWidgetState extends State<PhoneNumberFormWidget> {
  final controller = Get.put(SignUpController());
  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode = CountryCode(name: "Nigeria", code: "NG", dialCode: "+234");

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final _formkey = GlobalKey<FormState>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 60.0,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.1) : Colors.white,
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
                        hintText: moPhoneHintTitle,
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty)
                        {
                          return "Please enter a mobile number";
                        }
                        if(value.length > 10 || value.length < 10){
                          return "Please enter a valid mobile number without 0";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    if(_formkey.currentState!.validate()) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("Phone", countryCode.dialCode+controller.phoneNo.text.trim());
                      SignUpController.instance.phoneAuthentication(countryCode.dialCode+controller.phoneNo.text.trim());
                      Get.to(() => const OTPScreen());
                    }
                  },
                  child: Text(moSignup.toUpperCase()),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
