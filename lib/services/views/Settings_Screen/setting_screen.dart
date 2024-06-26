import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/views/Settings_Screen/about_us_screen.dart';
import 'package:myoga/services/views/Settings_Screen/privacy_policy.dart';
import 'package:myoga/services/views/Settings_Screen/terms_and_condition_screen.dart';

import '../../../constants/texts_string.dart';
import '../../controllers/getXSwitchStateController.dart';
import '../Support_Screen/support_screen.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GetXSwitchState getController = Get.find();
  bool isSwitched = false;
  final _auth = FirebaseAuth.instance.currentUser;

  deleteAccount() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moSetting, style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(moPushNotification, style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(width: 30.0,),
                Switch(
                  value: getController.isNotify.value,
                  activeColor: Colors.green,
                  onChanged: (newValue){
                    setState(() {
                      getController.changeNotifyState(newValue);
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22.0,),
            InkWell(
                onTap: (){
                  Get.to(() => const PrivacyPolicyScreen());
                },
                child: Text(moPrivacy, style: Theme.of(context).textTheme.headlineMedium,)),

            const SizedBox(height: 22.0,),
            InkWell(
                onTap: (){
                  Get.to(() => const TermsAndConditionScreen());
                },
                child: Text(moTerms, style: Theme.of(context).textTheme.headlineMedium,)),

            const SizedBox(height: 22.0,),
            InkWell(
                onTap: (){
                  Get.to(() => const AboutUsScreen());
                },
                child: Text(moAbout, style: Theme.of(context).textTheme.headlineMedium,)),

            const SizedBox(height: 22.0,),
            InkWell(
              onTap: (){
                Get.to(() => const SupportScreen());
              },
                child: Text("Support", style: Theme.of(context).textTheme.headlineMedium,)
            ),

            const SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(width: 30.0,),
                Switch(
                  value: getController.isDarkMode,
                  activeColor: Colors.green,
                  onChanged: (newValue){
                    setState(() {
                      getController.changeThemeMode(newValue);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
