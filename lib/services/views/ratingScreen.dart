import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingScreen extends StatefulWidget {
  final String driverID;
  final String bookingID;
  const RatingScreen({Key? key, required this.driverID, required this.bookingID}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {

  double ratingValue = 0.0;
  String? rider;
  final _db = FirebaseFirestore.instance;
  bool isLoading = false;

  void saveRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString("userName");
    final userEmail = prefs.getString("userEmail");
    final userPic = prefs.getString("userPic");

      final data = {
        "name": userName,
        "email": userEmail,
        "photo": userPic,
        "rating": ratingValue,
        "rated": 'true',
        "booking ID": widget.bookingID,
        "dateCreated": DateTime.now().toString(),
        "timeStamp": Timestamp.now(),
      };

      final ratedData = {
        "Rated": '1'
      };

    try{
      setState(() {
        isLoading = true;
      });

      QuerySnapshot querySnapshot = await _db.collection('Bookings').where('Booking Number', isEqualTo: widget.bookingID).get();
      if(querySnapshot.docs.isNotEmpty){
        DocumentReference documentReference = querySnapshot.docs.first.reference;

        await documentReference.update(ratedData);
      }
      await _db.collection('Drivers').doc(rider).collection('Ratings').add(data).whenComplete(() {
        // print("Rating submitted successfully");

        Get.snackbar(
          "Success", "Rating Submitted.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green,
        );
        Navigator.pop(context);
      }
      ).catchError((error, stackTrace) {
          Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });
    } catch (e){
      Get.snackbar(
        "Error",
        "Something went wrong. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    rider = widget.driverID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rate Service",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80.0,
            ),
            RatingBar.builder(
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState((){
                    ratingValue = rating;
                  });
                  if (kDebugMode) {
                    print(rating);
                  }
                },
              initialRating: 0.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              unratedColor: Colors.grey,
              itemSize: 50.0,
              updateOnDrag: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              children: [
                Expanded(
                  child: ratingValue == 0.0
                      ? OutlinedButton(
                    onPressed: (){
                      Get.snackbar(
                        "Oh Yeah", "You need to select a rating amount", snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.white,
                        colorText: Colors.red,
                      );
                    },
                    style: Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style,
                    child: Text("Rate Your Rider".toUpperCase()),
                  )
                      : OutlinedButton(
                    onPressed: isLoading ? null : (){
                      saveRating();
                    },
                    style: Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style,
                    child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(),) : Text("Submit Rating".toUpperCase()),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
