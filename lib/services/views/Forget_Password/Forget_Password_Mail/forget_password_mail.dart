import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myoga/constants/texts_string.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../constants/image_strings.dart';
import '../../../../widgets/form_header_widget.dart';
import '../../Login/login_screen.dart';
import '../Forget_Password_Otp/otp_screen.dart';

class ForgetPasswordMailScreen extends StatefulWidget {
  const ForgetPasswordMailScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordMailScreen> createState() => _ForgetPasswordMailScreenState();
}

class _ForgetPasswordMailScreenState extends State<ForgetPasswordMailScreen> {

  TextEditingController forgetPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30.0 * 4,
              ),
              const FormHeaderWidget(
                image: moSplashImage,
                title: moForgetPassword,
                subtitle: moForgetEmailSubtitle,
                crossAxisAlignment: CrossAxisAlignment.center,
                heightBetween: 30.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text(moEmail),
                        hintText: moEmail,
                        prefixIcon: Icon(Icons.mail_outline_outlined),
                      ),
                      controller: forgetPasswordController,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          var forgetMail = forgetPasswordController.text.trim();

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: forgetMail).
                            then((value) => Get.snackbar(
                                "Success", "Password reset link sent.",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green.withOpacity(0.1),
                                colorText: Colors.green),);
                            Get.to(() => const LoginScreen());
                          } on FirebaseAuthException catch(e){
                            Get.snackbar("Error", e.toString());
                          }
                          },
                        child: const Text(moProceed),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
