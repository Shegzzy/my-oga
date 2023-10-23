import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/image_strings.dart';
import '../../../../repositories/authentication_repository/authentication_repository.dart';
import '../../Profile/profile_screen.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return AppBar(
      title: isDark ? const Image(image: AssetImage(moLoginImageDark), height: 40.2,) : const Image(image: AssetImage(moLoginImage), height: 40.0,),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black.withOpacity(0.1) : Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15.0, top: 5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),),
          child: IconButton(onPressed: () {
            Get.to(() => const ProfileScreen());
          }, icon: const Icon(Icons.menu)),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(55.0);
}
