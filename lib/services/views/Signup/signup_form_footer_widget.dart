import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:myoga/services/views/Login/login_screen.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';

class SignupFormFooter extends StatelessWidget {
  const SignupFormFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Get.to(()=> const LoginScreen());
          },
          child: Text.rich(
            TextSpan(
                children: [
                  TextSpan(
                    text: moAlreadyHaveAccount,
                    style: Theme.of(context).textTheme.bodyText1),
                  TextSpan(text: moLogin.toUpperCase()),
              ]
            ),
          ),
        ),
      ],
    );
  }
}