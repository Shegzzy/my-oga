import 'package:flutter/material.dart';

import '../../models/onboarding_model.dart';

class OnBoardingPageWidget extends StatelessWidget {
  const OnBoardingPageWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final OnBoardingModel model;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(25.0),
      alignment: Alignment.center,
      color: model.bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image(image: AssetImage(model.image), height: size.height * 0.4,),
          Text(model.title, style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
          SizedBox(height: 50.0,)
        ],
      ),
    );
  }
}