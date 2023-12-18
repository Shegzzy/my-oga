import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/services/models/user_model.dart';
import 'package:myoga/services/views/Profile/profile_screen.dart';
import 'package:myoga/utils/formatter/formatter.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/profile_photo_controller.dart';
import '../welcome_screen/welcome_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late Future userFuture;
  final dob = TextEditingController();
  ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    userFuture = _getUser();
  }

  _getUser() async {
    return await controller.getUserData();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   controller.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(LineAwesomeIcons.angle_left)),
          title: Text(moEditProfile, style: Theme.of(context).textTheme.headlineMedium),
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
                    child: FutureBuilder(
                      future: userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            UserModel userData = snapshot.data as UserModel;

                            //Controllers
                            final email = TextEditingController(text: userData.email);
                            final fullname = TextEditingController(text: userData.fullname);
                            final phone = TextEditingController(text: userData.phoneNo);
                            final address = TextEditingController(text: userData.address);
                            final password = TextEditingController(text: userData.password);
                            final profilePic = TextEditingController(text: userData.profilePic);
                            final dob = TextEditingController(text: userData.dateOfBirth);
                            final gender = TextEditingController(text: userData.gender);

                            return Column(
                              ///Wrap this widget with future builder
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        width: 120.0,
                                        height: 120.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: userData.profilePic == "" || userData.profilePic == null ? const Icon(LineAwesomeIcons.user_circle, size: 50,) : Image.network((userData.profilePic!),
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress){
                                                  if(loadingProgress == null) return child;
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                errorBuilder: (context, object, stack){
                                                  return const Icon(Icons.error_outline, color: Colors.red, size: 50.0,);
                                                },
                                              ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          provider.pickImage(context);
                                        },
                                        child: Container(
                                            width: 35.0,
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(100),
                                                color: moSecondarColor),
                                            child: const Icon(LineAwesomeIcons.camera,
                                                size: 20.0, color: Colors.black, )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40.0),
                                  Form(
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: fullname,
                                            decoration: const InputDecoration(
                                                label: Text(moFullName),
                                                prefixIcon: Icon(LineAwesomeIcons.user)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: email,
                                            decoration: const InputDecoration(
                                                label: Text(moEmail),
                                                prefixIcon:
                                                Icon(LineAwesomeIcons.envelope)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: phone,
                                            decoration: const InputDecoration(
                                                label: Text(moPhone),
                                                prefixIcon: Icon(LineAwesomeIcons.phone)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: address,
                                            decoration: const InputDecoration(
                                                label: Text(moAddress),
                                                prefixIcon:
                                                Icon(LineAwesomeIcons.address_card)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: dob,
                                            decoration: const InputDecoration(
                                                label: Text("Date of Birth"),
                                                prefixIcon:
                                                Icon(LineAwesomeIcons.calendar)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: gender,
                                            decoration: const InputDecoration(
                                                label: Text("Gender"),
                                                prefixIcon:
                                                Icon(LineAwesomeIcons.user)),
                                          ),
                                          const SizedBox(height: 10.0),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                final userData = UserModel (
                                                  email: email.text.trim(),
                                                  fullname: fullname.text.trim(),
                                                  phoneNo: phone.text.trim(),
                                                  address: address.text.trim(),
                                                  password: password.text.trim(),
                                                  profilePic: profilePic.text.trim(),
                                                  gender: gender.text.trim(),
                                                  dateOfBirth: dob.text.trim(),
                                                );
                                                await controller.updateRecord(userData);
                                                Get.off(() => const ProfileScreen());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: PButtonColor,
                                                  side: BorderSide.none,
                                                  shape: const StadiumBorder()),
                                              child: const Text(moUpdate,
                                                  style: TextStyle(color: PWhiteColor)),
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text.rich(
                                                  TextSpan(
                                                  text: moJoined,
                                                  style: const TextStyle(fontSize: 12),
                                                  children: [
                                                    TextSpan(
                                                        text: MyOgaFormatter.dateFormatter(DateTime.parse(userData.dateCreated ?? "")),
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12))
                                                  ])),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseAuth.instance.currentUser?.delete();
                                                    Get.offAll(const WelcomeScreen());
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                      Colors.redAccent.withOpacity(0.1),
                                                      elevation: 0,
                                                      foregroundColor: Colors.red,
                                                      shape: const StadiumBorder(),
                                                      side: BorderSide.none),
                                                  child: const Text(moDelete))
                                            ],
                                          )
                                        ],
                                      ))
                                ]);
                          }
                          else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          }
                          else {
                            return const Center(
                              child: Text("Something went wrong"),
                            );
                          }
                        }
                        else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                );
              }
          ),
        )
    );
  }
}
