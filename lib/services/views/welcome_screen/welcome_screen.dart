import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../utils/themes/widget_themes/elevated_button_theme.dart';
import '../Login/login_screen.dart';
import '../Signup/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? PDarkColor : moPrimaryColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                image: const AssetImage(moWelcomeLogo),
                height: height * 0.6,
              ),
              Column(
                children: [
                  Text(
                    moWelcomeTitle,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    moWelcomeSubtitle,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 50.0,),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      style: Theme.of(context).outlinedButtonTheme.style,
                      child: Text(moLogin.toUpperCase()),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => const SignUpScreen()),
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Text(moSignup.toUpperCase()),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
