import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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

  final List _supportTypeList = ["Feedback", "Complaints", "Help/Recommendation", "Select type"];
  String _selectedTypeVal = "Select type";
  final _db = FirebaseFirestore.instance;
  late  TextEditingController _email, _name;
  final _message = TextEditingController();
  final _supportType = TextEditingController();
  final _subject = TextEditingController();
  final _paymentMethodList = ["Cash on Delivery", "Wallet", "Card"];
  String? _selectedPaymentVal = "";

  ///Retrieving Delivery Mode Details From Database
  getTypes() async {
     await _db.collection("Settings").doc("supports").collection("types").get().then((value) {
       for (var element in value.docs) {
         setState(() {
           _supportTypeList.add(element.data()["name"]);
         });
        }
     });
  }

  getController() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //Controllers
      _email = TextEditingController(text: prefs.getString("userEmail"));
      _name = TextEditingController(text: prefs.getString("userName"));
    });
  }

  submitMessage() async {
    final ticketNum = randomAlphaNumeric(7);
    final support = SupportModel(
      name: _name.text.trim(),
      subject: _subject.text.trim(),
      email: _email.text.trim(),
      type: _supportType.text.trim(),
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
  }

  @override
  void initState() {
    getController();
    //getTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text("Support Tickets", style: Theme.of(context).textTheme.headline4),
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
                        TextFormField(
                          decoration: const InputDecoration(
                              label: Text("Support Type"),
                              prefixIcon: Icon(Icons.announcement)),
                          validator: (value){
                            if(value == null || value.isEmpty)
                            {
                              return "A support type, example Feedback, Complaint";
                            }
                            return null;
                          },
                          controller: _supportType,
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
                            onPressed: ()  {
                              if(_formkey.currentState!.validate()){
                                submitMessage();
                              }
                            },
                            child: Text("Submit".toUpperCase()),
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
