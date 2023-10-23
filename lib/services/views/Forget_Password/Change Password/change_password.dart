import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../constants/texts_string.dart';
import '../../../../repositories/user_repository/user_repository.dart';
import '../../Login/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  bool _isVisible = false;
  var newPassword = "";
  final newPasswordController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final _userRepo = Get.put(UserRepository());

  changePassword() async {
    try{
      await currentUser!.updatePassword(newPassword);
      await _userRepo.updatePassword(newPassword);
      FirebaseAuth.instance.signOut();
      Get.offAll(const LoginScreen());
    } catch (error){
      Get.snackbar("Error", error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _userRepo.dispose();
    newPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title:
        Text(moChangePassword, style: Theme.of(context).textTheme.headline4),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  obscureText: !_isVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outlined),
                    labelText: moNewPassword,
                    hintText: moNewPassword,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off, color: Colors.grey,),
                    ),
                  ),
                  controller: newPasswordController,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0,),
                TextFormField(
                  obscureText: !_isVisible,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outlined),
                    labelText: moRepeatPassword,
                    hintText: moRepeatPassword,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.remove_red_eye_sharp),
                    ),
                  ),
                  validator: (value){
                    if(value != newPasswordController.text.trim())
                    {
                      return "Password not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30,),


                SizedBox(

                  width: double.infinity,
                  child: ElevatedButton(onPressed: (){
                    if(_formkey.currentState!.validate()){
                      setState((){
                        newPassword = newPasswordController.text.trim();
                      });
                      changePassword();
                    }
                  },
                      child:
                      Text("Change Password".toUpperCase(), style: const TextStyle(fontSize: 20.0,),
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
