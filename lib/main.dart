import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myoga/repositories/authentication_repository/authentication_repository.dart';
import 'package:myoga/repositories/user_repository/user_repository.dart';
import 'package:myoga/services/controllers/Data_handler/appData.dart';
import 'package:myoga/services/controllers/getXSwitchStateController.dart';
import 'package:myoga/services/views/Permission_request/permission_request_info.dart';
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
final UserRepository _userRepo = Get.put(UserRepository());
final AuthenticationRepository authRepo = Get.put(AuthenticationRepository());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ///to load on Boarding Screen for the first time only
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  await _userRepo.getStates();
  await _userRepo.getVehicles();
  await _userRepo.getSupportTypes();
  runApp(MyApp());
  _init();
}


_init() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("userID");
  final user = authRepo.auth.currentUser;
  if (token != null) {
    if(user != null) {
      if(user.emailVerified){
        authRepo.checkUserType();
      } else{
        authRepo.logout();
      }
    }
  }
  else {
    _checkSeen();
  }
}

_checkUserType() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  final iD = prefs.getString("aUserID");
  if (iD == null) {
    final iDd = prefs.getString("userID");
    final userDoc = await FirebaseFirestore.instance.collection("Users").doc(iDd).get();
    if (userDoc.exists) {
      if(Platform.isAndroid){
        if(permission == LocationPermission.denied){
          Get.to(()=> const PermissionScreen());
        }else{
          Get.offAll(() => const UserDashboard());
        }
      }else{
        Get.offAll(() => const UserDashboard());
      }

    } else {
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
  if (seen == true) {
    Get.offAll(() => const WelcomeScreen());
  }
  else {
    Get.offAll(() => const OnBoardingScreen());
  }
}

class MyApp extends StatelessWidget {
  final GetXSwitchState getXSwitchState = Get.put(GetXSwitchState());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GetXSwitchState>(builder: (_) {
      return ChangeNotifierProvider(
        create: (context) => AppData(),
        child: GetMaterialApp(
          theme: getXSwitchState.isDarkMode ? MyOgaTheme.darkTheme : MyOgaTheme
              .lightTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.leftToRightWithFade,
          transitionDuration: const Duration(milliseconds: 100),
          home: const Scaffold(body: Center(child: CircularProgressIndicator(
            color: moAccentColor, backgroundColor: Colors.white,),)),
        ),
      );
    });
  }
}
