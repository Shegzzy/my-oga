import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/repositories/authentication_repository/authentication_repository.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  void initState() {
    super.initState();
    AuthenticationRepository().autoRedirectTimer();
  }

  @override
  void dispose() {
    super.dispose();
    AuthenticationRepository().timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationRepository());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 50,),
              const Center(child: Icon(LineAwesomeIcons.envelope_open, size: 100,)),
              const SizedBox(height: 25,),
              const Text('Verify your email address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black),),
              const SizedBox(height: 25,),
              const Text('A verification mail has been sent to your email address, please check your email for a verification link to verify your email address', textAlign: TextAlign.center,),

              const SizedBox(height: 25,),
              TextButton(
                  onPressed: (){
                    controller.auth.currentUser?.sendEmailVerification();
                    Get.snackbar(
                        "Success", "Link sent",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.white,
                        colorText: Colors.green
                    );
                  },
                  child: const Text('Resend Link')),

              TextButton(
                  onPressed: (){
                    controller.logout();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LineAwesomeIcons.arrow_left),
                      SizedBox(width: 10,),
                      Text('back to Login'),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
