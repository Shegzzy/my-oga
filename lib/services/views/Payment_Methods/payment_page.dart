import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String amt;
   final String email;
  final VoidCallback onPressed;
  const PaymentPage({ Key? key, required this.amt, required this.email, required this.onPressed}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formkey = GlobalKey<FormState>();
  String? newAmt;
  String? newEmail;
  String pubKey = 'pk_test_51c4b33f9510df51a4822f59bbbd555cdc0f3748';
  final plugin = PaystackPlugin();
  String message = "";
  bool btnKey = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plugin.initialize(publicKey: pubKey);
    newAmt = widget.amt;
    newEmail = widget.email;
  }

  void makePayment () async {
    int? price = int.tryParse(newAmt??"")! * 100;
    Charge charge = Charge()
    ..amount = price
    ..reference = 'ref ${DateTime.now()}'
    ..email = newEmail
    ..currency = 'NGN';

    CheckoutResponse response = await plugin.checkout(
      context,
      charge: charge,
      method: CheckoutMethod.card,);

    if(response.status == true){
      setState((){
        btnKey = true;
      });
      message = "Payment was successful. Ref: ${response.reference}";
      Get.snackbar("Success", message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green);
      if(mounted){}
    } else {
      Get.snackbar("Error", response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey.withOpacity(0.1),
          colorText: Colors.red);
    }

  }

  @override
  Widget build(BuildContext context) {
    final  amount = TextEditingController(text: newAmt);
    final  email = TextEditingController( text: newEmail);
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 40.0,),
              TextFormField(
                controller: amount,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Please enter an amount";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  prefix: Text("NGN"),
                  hintText: '1000',
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0,),
              TextFormField(
                controller: email,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Please enter an email";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'myoga@gmail.com',
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0,),
              SizedBox(
                width: double.infinity,
                child:  btnKey == true ? ElevatedButton(
                  onPressed: widget.onPressed,
                  child: Text("PROCEED TO BOOKING".toUpperCase()),
                ) : ElevatedButton(
                  onPressed: () {
                   makePayment();
                  },
                  child: Text("Make Payment".toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
