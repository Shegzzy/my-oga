import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/repositories/user_repository/user_repository.dart';
import 'package:myoga/services/models/user_model.dart';
import 'package:myoga/utils/formatter/formatter.dart';

import '../../../constants/colors.dart';
import '../../../constants/texts_string.dart';
import '../../controllers/profile_controller.dart';
import '../welcome_screen/welcome_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late Future<UserModel> userFuture;
  String? imageSource;
  final dob = TextEditingController();
  var isUploading = false.obs;
  bool _isDataLoaded = false;

  ProfileController controller = Get.put(ProfileController());
  UserRepository userRepository = Get.put(UserRepository());

  final _ref = FirebaseFirestore.instance.collection("Users");
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final picker = ImagePicker();

  XFile? _image;

  late TextEditingController fullNameController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController genderController = TextEditingController();
  late TextEditingController dobController = TextEditingController();
  late TextEditingController picController = TextEditingController();
  late TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!_isDataLoaded) {
      _isDataLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _getUser();
        controllers();
        setState(() {});  // Ensure UI rebuilds after initialization
      });
    }
  }

  Future<void> _getUser() async {
    await controller.fetchUserData();
  }

  void controllers() {
    fullNameController = TextEditingController(text: userRepository.userModel.fullname);
    phoneController = TextEditingController(text: userRepository.userModel.phoneNo);
    addressController = TextEditingController(text: userRepository.userModel.address);
    genderController = TextEditingController(text: userRepository.userModel.gender);
    dobController = TextEditingController(text: userRepository.userModel.dateOfBirth);
    picController = TextEditingController(text: userRepository.userModel.profilePic);
    dateController = TextEditingController(text: userRepository.userModel.dateCreated);
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 100);

    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
        imageSource = _image?.path;
      });
    }
  }

  void showImagePickerDialog(BuildContext context) {
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
                      pickImage(context, ImageSource.camera);
                      Navigator.pop(context);
                    },
                    leading: const Icon(LineAwesomeIcons.camera),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                      pickImage(context, ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    leading: const Icon(LineAwesomeIcons.image),
                    title: const Text("Gallery"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/profilepic${userRepository.userModel.id}');
      firebase_storage.UploadTask uploadTask = ref.putFile(File(_image!.path).absolute);
      await uploadTask;

      final newUrl = await ref.getDownloadURL();
      await _ref.doc(userRepository.userModel.id).update({"Profile Photo": newUrl});

      Get.snackbar("Success", "Profile Photo Updated",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green);

      setState(() {
        _image = null;
      });
    } catch (error) {
      Get.snackbar("Error", error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moEditProfile, style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<UserRepository>(builder: (userRepo) {
        return userRepo.loadingEditProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 40.0),
                _buildProfileForm(),
                const SizedBox(height: 20.0),
                _buildUpdateButton(),
                const SizedBox(height: 20.0),
                _buildDeleteButton()
              ],
            ),
          ),
        );
      }),
    );
  }

  // profile pic section
  Widget _buildProfileImage() {
    return Stack(
      children: [
        SizedBox(
          width: 120.0,
          height: 120.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: imageSource != null
                ? Image.file(File(imageSource!))
                : userRepository.userModel.profilePic == null || userRepository.userModel.profilePic!.isEmpty
                ? const Icon(LineAwesomeIcons.user_circle, size: 50)
                : Image.network(
              userRepository.userModel.profilePic!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, color: Colors.red, size: 50.0);
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              showImagePickerDialog(context);
            },
            child: Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100), color: moSecondarColor),
              child: const Icon(LineAwesomeIcons.camera, size: 20.0, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // form section
  Widget _buildProfileForm() {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(label: Text(moFullName), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(label: Text(moPhone), prefixIcon: Icon(LineAwesomeIcons.phone)),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(label: Text(moAddress), prefixIcon: Icon(LineAwesomeIcons.address_card)),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: dobController,
            decoration: const InputDecoration(label: Text("Date of Birth"), prefixIcon: Icon(LineAwesomeIcons.calendar)),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: genderController,
            decoration: const InputDecoration(label: Text("Gender"), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
        ],
      ),
    );
  }

  // update section
  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        return isUploading.value
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: () async {
            isUploading(true);
            if (imageSource != null) {
              await uploadImage();
            }

            final userData = UserModel(
              fullname: fullNameController.text.trim(),
              phoneNo: phoneController.text.trim(),
              address: addressController.text.trim(),
              gender: genderController.text.trim(),
              dateOfBirth: dobController.text.trim(),
            );
            await controller.updateRecord(userData);
            if (mounted) {
              Navigator.pop(context);
            }
            isUploading(false);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: PButtonColor, side: BorderSide.none, shape: const StadiumBorder()),
          child: const Text(moUpdate, style: TextStyle(color: PWhiteColor)),
        );
      }),
    );
  }

  // delete section
  Widget _buildDeleteButton() {
    DateTime? dateCreated;
    try {
      dateCreated = DateTime.parse(userRepository.userModel.dateCreated ?? '');
    } catch (e) {
      dateCreated = null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(
            text: moJoined,
            style: const TextStyle(fontSize: 12),
            children: [
              TextSpan(
                  text: dateCreated != null ? MyOgaFormatter.dateFormatter(dateCreated) : 'Invalid date',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
            ])),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.currentUser?.delete();
            Get.offAll(const WelcomeScreen());
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              elevation: 0,
              foregroundColor: Colors.red,
              shape: const StadiumBorder(),
              side: BorderSide.none),
          child: const Text(moDelete),
        ),
      ],
    );
  }
}
