import 'package:flutter/material.dart';

import '../../../constants/image_strings.dart';
import '../../../constants/texts_string.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isDark ? Image(image: const AssetImage(moLoginImageDark), height: size.height * 0.2,) : Image(image: const AssetImage(moLoginImage), height: size.height * 0.2,),
        Text(moWelcomeBack, style: Theme.of(context).textTheme.headline1,),
        Text(moWelcomeBackTagline, style: Theme.of(context).textTheme.bodyText1,),
      ],
    );
  }
}
