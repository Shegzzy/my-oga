

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/views/Profile/profile_info_screen.dart';
import 'package:myoga/services/views/Profile/update_profile_screen.dart';
import 'package:myoga/services/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../repositories/authentication_repository/authentication_repository.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/profile_photo_controller.dart';
import '../../notifi_services.dart';
import '../My_Orders/my_orders_screen.dart';
import '../Settings_Screen/setting_screen.dart';
import '../Wallet_Screen/wallet_screen.dart';
import 'widgets/profile_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //late Stream userStream;
  //late var timer;
  //String? _docId;
  String? userPic, userName, userEmail;
  //final _user = FirebaseAuth.instance.currentUser;
  var myUserDetail = const UserModel().obs;
  final AuthenticationRepository _authController = Get.put(AuthenticationRepository());

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName");
      userPic = prefs.getString("userPic");
      userEmail = prefs.getString("userEmail");
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //timer.cancel();
    _authController.onClose();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    getPrefs();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moProfile, style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ChangeNotifierProvider(
        create: (_) => ProfilePhotoController(),
        child: Consumer<ProfilePhotoController>(
          builder: (context, provider, child){
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30.0),

                ///Future Builder
                child: Column(
                  children: [
                    Column(
                    children: [
                    Stack(
                      children: [
                        SizedBox(
                        width: 120.0,
                        height: 120.0,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: userPic == null || userPic == ""
                                ? const Icon(LineAwesomeIcons.user_circle, size: 50,)
                                : Image(image: NetworkImage(userPic ?? ""), fit: BoxFit.cover,loadingBuilder: (context,
                                child, loadingProgress) {if (loadingProgress == null) {
                              return child;
                            }
                            return const Center(child: CircularProgressIndicator());
                            },
                              errorBuilder:
                                  (context, object, stack) {
                                return Icon(Icons.person, color: isDark ? Colors.white : Colors.grey, size: 50.0,);
                              },),
                            // child: myUserDetail.value.profilePic == null || myUserDetail.value.profilePic == "" ?  const Icon(LineAwesomeIcons.user_circle, size: 50,):
                          // Image(image: NetworkImage(userPic??"Me"), fit: BoxFit.cover, loadingBuilder: (context,
                          //       child, loadingProgress) {if (loadingProgress == null) {
                          //     return child;
                          //   }
                          //   return const Center(child: CircularProgressIndicator());
                          //   },
                          //     errorBuilder:
                          //         (context, object, stack) {
                          //       return Icon(Icons.person, color: isDark ? Colors.white : Colors.grey,);
                          //     },
                            // )
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.pickImage(context);
                        },
                        child: Container(
                            width: 35.0,
                            height: 35.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(100),
                                color: moSecondarColor),
                            child: const Icon(
                                LineAwesomeIcons.alternate_pencil,
                                size: 20.0,
                                color: Colors.black)),
                      ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Text(myUserDetail.value.fullname ?? userName ??"Hey There",
                        style:
                        Theme.of(context).textTheme.headlineMedium),
                    Text(myUserDetail.value.email ?? userEmail ??"My Oga", style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      width: 200.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const UpdateProfileScreen());
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: PButtonColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text(moEditProfile,
                            style: TextStyle(color: PWhiteColor)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    const Divider(),
                    const SizedBox(height: 10.0),
                    //Menu
                    ProfileMenuWidget(
                        title: moMenu1,
                        icon: LineAwesomeIcons.user,
                        onPress: () {
                          Get.to(() => const ProfileInformation());
                        }),
                    ProfileMenuWidget(
                        title: moMenu2,
                        icon: LineAwesomeIcons.receipt,
                        onPress: () {
                          Get.to(() => MyOrdersScreen());
                        }),
                    ProfileMenuWidget(
                        title: 'My Ratings',
                        icon: LineAwesomeIcons.star,
                        onPress: () {
                          Get.to(() => MyOrdersScreen());
                        }),
                    ProfileMenuWidget(
                        title: moMenu3,
                        icon: LineAwesomeIcons.cog,
                        onPress: () {
                          Get.to(() => SettingScreen());
                        }
                    ),
                    const Divider(),
                    const SizedBox(height: 10.0),
                    ProfileMenuWidget(
                      title: moMenu4,
                      icon: LineAwesomeIcons.alternate_sign_out,
                      textColor: Colors.red,
                      endIcon: false,
                      onPress: () {
                        _authController.logout();
                      },
                    ),
                  ],
                ),
              ),
            );
            },
        ),
      ),
    );
  }
}


