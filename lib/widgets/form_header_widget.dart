import 'package:flutter/material.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({Key? key,
    this.imageColor,
    this.imageHeight = 0.2,
    this.heightBetween,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.image,
    required this.title,
    required this.subtitle,
    this.textAlign,
  }) : super(key: key);

  final String image, title, subtitle;
  final Color? imageColor;
  final double imageHeight;
  final double? heightBetween;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Image(
          image: AssetImage(image), height: size.height * 0.2,),
        Text(title, style: Theme
            .of(context)
            .textTheme
            .headline1,),
        Text(subtitle, textAlign: textAlign, style: Theme
            .of(context)
            .textTheme
            .bodyText1,),
      ],
    );
  }
}