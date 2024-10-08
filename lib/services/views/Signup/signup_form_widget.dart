import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/signup_controller.dart';
import '../../models/user_model.dart';
import '../Phone_Number_Screen/phone_number.dart';

class SignupFormWidget extends StatefulWidget {
  const SignupFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SignupFormWidget> createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {
  final controller = Get.put(SignUpController());
  final _formkey = GlobalKey<FormState>();
  bool _isVisible = false;
  bool _isPasswordEightChar = false;
  bool _isPasswordOneNum = false;
  bool _isLoading = false;
  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode = const CountryCode(name: "Nigeria", code: "NG", dialCode: "+234");


  onPasswordChanged(String password){
    final numericRegx = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightChar = false;
      _isPasswordOneNum = false;
      if(password.length  >= 8) {
        _isPasswordEightChar = true;
      }
      if(numericRegx.hasMatch(password)) {
        _isPasswordOneNum = true;
      }
    });
  }

  Future<void> signUP() async{
    final user = UserModel(
      email: controller.email.text.trim(),
      fullname: controller.name.text.trim(),
      phoneNo: '+234${controller.phoneNo.text.trim()}',
      password: controller.password.text.trim(),
      dateCreated: DateTime.now().toString(),
      timeStamp: Timestamp.now(),
    );

    try{
      setState(() {
        _isLoading = true;
      });
      await controller.registerUser(controller.email.text.trim(), controller.password.text.trim());
      await controller.createUser(user);

      // controller.auth.auth.currentUser!.emailVerified ? Get.offAll(() => const PhoneNumberScreen());
    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  void dispose() {
    super.dispose();
    controller.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(moFullName),
                    prefixIcon: Icon(Icons.person_outline_outlined)),
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your full name";
                  }
                  return null;
                },
                controller: controller.name,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(moEmail),
                    prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your email, required!";
                  }
                  if(!value.contains("@")){
                    return ("Please enter a valid email address!");
                  }
                  return null;
                },
                controller: controller.email,
              ),
              const SizedBox(height: 10.0),
        TextFormField(
          controller: controller.phoneNo,
          decoration: InputDecoration(
            label: const Text(moPhoneTitle),
            hintText: moPhoneHintTitle,
            prefixIcon: InkWell(
              onTap: () async {
                final code = await countryPicker.showPicker(context: context);
                if (code != null) {
                  setState(() {
                    countryCode = code;
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Prevents Row overflow
                children: [
                  const SizedBox(width: 10),
                  countryCode.flagImage,
                  const SizedBox(width: 4),
                  Text(
                    countryCode.dialCode,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a mobile number";
            }
            if (value.length != 10) {
              return "Please enter a valid mobile number without 0";
            }
            return null;
          },
        ),
        const SizedBox(height: 10.0),
              TextFormField(
                onChanged: (password) => onPasswordChanged(password),
                obscureText: !_isVisible,
                decoration: InputDecoration(
                    label: const Text(moPassword),
                    prefixIcon: const Icon(Icons.fingerprint_outlined),
                  suffixIcon: IconButton(
                    onPressed: (){
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: _isVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off, color: Colors.grey,),
                  ),
                ),
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your password";
                  }
                  if(_isPasswordEightChar == false){
                    return "Password must be at least 8 character.";
                  }
                  if(_isPasswordOneNum == false){
                    return "Password must contain at least 1 number";
                  }
                  return null;
                },
                controller: controller.password,
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isPasswordEightChar ? Colors.green : Colors.transparent,
                      border: _isPasswordEightChar ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 15,),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Text("Contains at least 8 characters")
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isPasswordOneNum ? Colors.green : Colors.transparent,
                      border: _isPasswordOneNum ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 15,),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Text("Contains at least 1 number")
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                    label: Text(moRepeatPassword),
                    prefixIcon: Icon(Icons.fingerprint_outlined)),
                validator: (value){
                  if(value != controller.password.text.trim())
                  {
                    return "Password not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: _isLoading ? const Center(child: CircularProgressIndicator(),) : ElevatedButton(
                  onPressed: ()  async {
                    if(_formkey.currentState!.validate()){
                      await signUP();
                    }
                  },
                  child: Text(moNext.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
