import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myoga/constants/colors.dart';
import 'package:myoga/services/controllers/getXSwitchStateController.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/image_strings.dart';
import '../../../../constants/texts_string.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

import '../../../controllers/otp_controller.dart';
import '../../../controllers/signup_controller.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  GetXSwitchState getXSwitchState = Get.find();

  @override
  Widget build(BuildContext context) {
    final otpController = Get.put(OTPController());
    var otp;
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage(moLoginImage),
              ),
              Text(moOtpTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 40.0),
              Text("Enter code sent for verification.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(
                height: 20.0,
              ),
              OtpTextField(
                  numberOfFields: 6,
                  fillColor: Colors.black.withOpacity(0.1),
                  filled: true,
                  onSubmit: (code) async{
                    otp = code;
                    await otpController.verifyOTP(otp);
                  }),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async{
                      await otpController.verifyOTP(otp);
                    },
                    child: otpController.otpVerifying ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ) : const Text(moNext)),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                child: OtpTimerButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final phoneNumber = prefs.getString("Phone");
                    SignUpController.instance.phoneAuthentication(phoneNumber!);
                  },
                  text: Text('Resend OTP', style: TextStyle(
                    color: isDark ? Colors.white : Colors.white
                  ),),
                  duration: 60,
                  backgroundColor: PButtonColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
