import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/colors.dart';
import '../../controllers/getXSwitchStateController.dart';


class RatingTabPage extends StatefulWidget {
  const RatingTabPage({Key? key}) : super(key: key);

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {

  bool isMore = false;
  int counter = 0;
  double rate = 0;
  double _total = 0;
  double _average = 0;
  List<double> ratings = [0.1, 0.3, 0.5, 0.7, 0.9];
  final _db = FirebaseFirestore.instance;
  final GetXSwitchState getXSwitchState = Get.find();

  void getCount()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("userID")!;
    await _db.collection("Users").doc(userID).collection("Ratings").get().then((value) {
      for (var element in value.docs) {
        rate = element.data()["rating"];
        setState(() {
          _total = _total + rate;
          counter = counter+1;
        });
      }
    });
    _average = _total/counter;
    if (kDebugMode) {
      print(_average);
      print(_total);
      print(counter);
    }
  }

  @override
  void initState() {
    getCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(
          "Total Average Reviews",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _average.toStringAsFixed(1),
                            style: TextStyle(fontSize: 35.0, color: isDark ? Colors.white : Colors.black),
                          ),
                          TextSpan(
                            text: "/5",
                            style: TextStyle(
                              fontSize: 24.0,
                              color: isDark ? Colors.white : PButtonColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RatingStars(
                      value: _average,
                      starCount: 5,
                      starSize: 20,
                      starColor: Colors.orange,
                      starOffColor: const Color(0xffe7e8ea),
                      animationDuration: const Duration(milliseconds: 1000),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      "$counter Reviews",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: isDark ? Colors.white : PButtonColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                                const SizedBox(width: 2.0),
                                const Icon(Icons.star, color: Colors.orange),
                                const SizedBox(width: 2.0),
                                LinearPercentIndicator(
                                  lineHeight: 6.0,
                                  // linearStrokeCap: LinearStrokeCap.roundAll,
                                  width: MediaQuery.of(context).size.width / 3.8,
                                  animation: true,
                                  animationDuration: 2500,
                                  percent: ratings[index],
                                  progressColor: Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }
}
