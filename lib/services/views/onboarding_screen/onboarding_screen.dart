import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:myoga/services/models/onboarding_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';
import '../../../main.dart';
import '../../../size_config.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/onboarding_data.dart';
import '../welcome_screen/welcome_screen.dart';
import 'onboarding_page_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
int currentPage = 0;

final PageController _pageController = PageController(initialPage: 0);

  AnimatedContainer dotIndicator(index){
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 5),
      duration: const Duration(milliseconds: 400),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: currentPage == index ? moAccentColor : PButtonColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Future setSeenObBoard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenOnboard', true);
  }

  @override
  void initState() {
    super.initState();
    setSeenObBoard();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height/100;
    return Scaffold(
      backgroundColor: moPrimaryColor,
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 23,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value){
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: onBoardingContent.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      SizedBox(height: height * 10,),
                      Text(
                        onBoardingContent[index].title,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.center,
                ),
                      SizedBox(height: height * 5,),
                      Container(
                        height: height * 40,
                        child: Image.asset(onBoardingContent[index].image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: height * 5,),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                        style: Theme.of(context).textTheme.headline4,
                        children: [
                          TextSpan(text: 'MY OGA, ', style: TextStyle(color: PButtonColor)),
                          TextSpan(text: 'SEND ME ', style: TextStyle(color: moAccentColor)),
                        ],
                      ),),
                      SizedBox(height: height * 3,),
                    ],
                  ),
            ),
          ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    currentPage == onBoardingContent.length - 1
                        ? OnBoardTextBtn(name: 'Get Started', onPress: () => Get.to(() => const WelcomeScreen()), bgColor: PButtonColor,)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OnBoardNavBtn(
                          name: "Skip",
                          onPress: () {
                            Get.to(() => const WelcomeScreen());
                          },
                        ),
                        Row(
                          children: List.generate(onBoardingContent.length,
                                  (index) => dotIndicator(index)
                          ),
                        ),
                        OnBoardNavBtn(
                          name: "Next",
                          onPress: () {
                            _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut,);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 5,),
          ],
      )),
    );
  }
}

class OnBoardTextBtn extends StatelessWidget {
  const OnBoardTextBtn({
    Key? key,
    required this.name,
    required this.onPress,
    required this.bgColor,
  }) : super(key: key);
  final String name;
  final VoidCallback onPress;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height/100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height:  height* 6.5,
        width: Get.width,
        child: TextButton(
            onPressed: onPress,
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
            ),
            child: Text(
              name,
              style: TextStyle(fontSize: 20, color: Colors.white),),
          ),
      ),
    );
  }
}

class OnBoardNavBtn extends StatelessWidget {
  const OnBoardNavBtn({
    Key? key,
    required this.name,
    required this.onPress,
  }) : super(key: key);
  final String name;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        splashColor: PButtonColor,
        borderRadius: BorderRadius.circular(10),
        onTap: onPress,
        child: Text(
          name,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}
