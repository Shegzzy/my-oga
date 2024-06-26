import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:myoga/repositories/user_repository/user_repository.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dashboard/supportTypeModel.dart';
import '../../models/supportModel.dart';

class NewSupport extends StatefulWidget {
  const NewSupport({Key? key}) : super(key: key);

  @override
  State<NewSupport> createState() => _NewSupportState();
}

class _NewSupportState extends State<NewSupport> {

  final _formkey = GlobalKey<FormState>();

  UserRepository userRepository = Get.find();
  final _db = FirebaseFirestore.instance;
  late  TextEditingController _email = TextEditingController();
  late  TextEditingController _name = TextEditingController();
  final _message = TextEditingController();
  final _supportType = TextEditingController();
  final _subject = TextEditingController();
  String? _selectedSupportVal = "";
  bool submittingSupport = false;

  ///Retrieving Delivery Mode Details From Database
  // getTypes() async {
  //    await _db.collection("Settings").doc("supports").collection("types").get().then((value) {
  //      for (var element in value.docs) {
  //        setState(() {
  //          _supportTypeList.add(element.data()["name"]);
  //        });
  //       }
  //    });
  // }

  getController() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //Controllers
      _email = TextEditingController(text: prefs.getString("userEmail"));
      _name = TextEditingController(text: prefs.getString("userName"));
    });
  }

  Future<void> submitMessage() async {
    setState(() {
      submittingSupport = true;
    });
    try{
      final ticketNum = randomAlphaNumeric(7);
      final support = SupportModel(
        name: _name.text.trim(),
        subject: _subject.text.trim(),
        email: _email.text.trim(),
        type: _supportType.text.isEmpty ?  userRepository.supportTypeModel.first.name : _supportType.text.trim(),
        message: _message.text.trim(),
        status: "new",
        ticketNumber: ticketNum,
        dateCreated: DateTime.now().toString(),
        timeStamp: Timestamp.now(),
      );
      ///FirebaseDatabase.instance.ref().child('Booking Request').push();
      await _db.collection("supportTickets").add(support.toJson()).whenComplete(() => Get.snackbar(
          "Success", "Your message have been received",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green),
      ).catchError((error, stackTrace) {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: Colors.red);
      });
    } catch (e) {
      throw e.toString();
    } finally{
      setState(() {
        submittingSupport = false;
      });
    }
  }

  @override
  void initState() {
    getController();
    //getTypes();
    super.initState();
    for(var support in userRepository.supportTypeModel){
      print(support.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text("Support Tickets", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formkey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10.0),
                        DropdownButtonFormField<String>(
                          disabledHint: const Text('Select type of support'),
                          value: userRepository.supportTypeModel.isNotEmpty ? userRepository.supportTypeModel.first.name : null,
                          items: userRepository.supportTypeModel
                              .map((e) => DropdownMenuItem<String>(
                            value: e.name,
                            child: Text(e.name ?? ''),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedSupportVal = val!;
                              _supportType.text = _selectedSupportVal!;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                          ),
                          decoration: const InputDecoration(
                            labelText: "Support Type",
                            prefixIcon: Icon(
                              Icons.announcement,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10.0),
                        TextFormField(
                          decoration: const InputDecoration(
                              label: Text("Name"),
                              prefixIcon: Icon(Icons.person_outline_outlined)),
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "Please enter your full name";
                            }
                            return null;
                          },
                          controller: _name,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          decoration: const InputDecoration(
                              label: Text("Email"),
                              prefixIcon: Icon(Icons.email)),
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "Please enter email";
                            }
                            return null;
                          },
                          controller: _email,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          decoration: const InputDecoration(
                              label: Text("Subject"),
                              prefixIcon: Icon(Icons.inbox)),
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "Please enter subject";
                            }
                            return null;
                          },
                          controller: _subject,
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: _message,
                          decoration: const InputDecoration(
                            label: Text("Enter message here"),
                            border: OutlineInputBorder(),
                          ),
                          minLines: 6, // any number you need (It works as the rows for the textarea)
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: submittingSupport ? null : ()  async{
                              if(_formkey.currentState!.validate()){
                                await submitMessage();
                                _message.clear();
                              }
                            },
                            child: submittingSupport ? const Center(child: CircularProgressIndicator(),) : Text("Submit".toUpperCase()),
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
