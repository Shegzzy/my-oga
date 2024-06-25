import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../constants/colors.dart';
import '../../repositories/authentication_repository/authentication_repository.dart';
import '../../repositories/user_repository/user_repository.dart';
import '../models/user_model.dart';

class ProfilePhotoController with ChangeNotifier {

  final _userRepo = Get.put(UserRepository());

  final _ref = FirebaseFirestore.instance.collection("Users");
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage
      .instance;

  final picker = ImagePicker();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  XFile? _image;

  XFile? get image => _image;

  Future pickGalleryImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
      notifyListeners();
    }
  }

  void pickImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120.0,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(
                      LineAwesomeIcons.camera,),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(
                      LineAwesomeIcons.image,),
                    title: const Text("Gallery"),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void uploadImage() async {
    setLoading(true);
    final user = FirebaseAuth.instance.currentUser!;
    final phone = user.phoneNumber;
    final email = user.email;

    if(email != null) {
      UserModel userInfo = await _userRepo.getUserDetailsWithEmail(email);

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/profilepic${userInfo.id}');
      firebase_storage.UploadTask uploadTask = ref.putFile(
          File(image!.path).absolute);
      await Future.value(uploadTask);

      final newUrl = await ref.getDownloadURL();
      _ref.doc(userInfo.id).update({"Profile Photo": newUrl}).then((value){
        Get.snackbar("Success", "Profile Photo Updated",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green
        );
        setLoading(false);
        _image = null;
      }).onError((error, stackTrace) {
        setLoading(false);
        Get.snackbar("Error", error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      });
    }
    else {
      UserModel userInfo = await _userRepo.getUserDetailsWithPhone(phone!);

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/profilepic${userInfo.id}');
      firebase_storage.UploadTask uploadTask = ref.putFile(
          File(image!.path).absolute);
      await Future.value(uploadTask);

      final newUrl = await ref.getDownloadURL();
      _ref.doc(userInfo.id).update({"Profile Photo": newUrl}).then((value){
        Get.snackbar("Success", "Profile Photo Updated",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green
        );
        setLoading(false);
        _image = null;
      }).onError((error, stackTrace) {
        setLoading(false);
        Get.snackbar("Error", error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      });
    }
  }
}