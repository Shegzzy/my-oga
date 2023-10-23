import 'package:flutter/material.dart';
import 'package:myoga/constants/image_strings.dart';
import 'package:myoga/constants/texts_string.dart';
import 'package:myoga/services/views/Signup/signup_form_footer_widget.dart';
import 'package:myoga/services/views/Signup/signup_form_widget.dart';

import '../../../constants/colors.dart';
import '../../../widgets/form_header_widget.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: const [
                FormHeaderWidget(
                  image: moLoginImage,
                  title: moSignupTitle,
                  subtitle: moSignupSubtitle,
                ),
                SignupFormWidget(),
                SignupFormFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

