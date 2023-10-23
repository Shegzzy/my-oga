
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myoga/services/controllers/Data_handler/appData.dart';
import 'package:myoga/services/views/User_Dashboard/user_dashboard.dart';
import 'package:myoga/services/views/onboarding_screen/onboarding_screen.dart';
import 'package:myoga/services/views/welcome_screen/welcome_screen.dart';
import 'package:myoga/utils/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/colors.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(message.notification?.title.toString());
    print(message.notification?.body.toString());
    print(message.data.toString());
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ///to load on Boarding Screen for the first time only
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  runApp(const MyApp());
  _init();
}


_init()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("userID");
  if(token != null){
    _checkUserType();
  }
  else {
    _checkSeen();
  }
}

_checkUserType() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final iD = prefs.getString("aUserID");
  if(iD == null){
    final iDd = prefs.getString("userID");
    final userDoc = await FirebaseFirestore.instance.collection("Users").doc(iDd).get();
    if(userDoc.exists){
      Get.offAll(() => const UserDashboard());
    } else{
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      Get.offAll(() => const WelcomeScreen());
    }
  } else {
    final userDoc = await FirebaseFirestore.instance.collection("Users")
        .doc(iD)
        .get();
    if (userDoc.exists) {
      Get.offAll(() => const UserDashboard());
    } else {
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      Get.offAll(() => const WelcomeScreen());
    }
  }
}

_checkSeen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seenOnboard');
  if(seen == true){
    Get.offAll(() => const WelcomeScreen());
  }
  else {
    Get.offAll(() => const OnBoardingScreen());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: GetMaterialApp(
        theme: MyOgaTheme.lightTheme,
        darkTheme: MyOgaTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 100),
        home: const Scaffold(body: Center(child: CircularProgressIndicator(color: moAccentColor,backgroundColor: Colors.white,),)),
      ),
    );
  }
}
