import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../constants/texts_string.dart';
import '../Forget_Password_Mail/forget_password_mail.dart';
import '../Forget_password_Phone/forget_password_phone.dart';
import 'forget_password_btn_widget.dart';

class ForgetPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moForgetPasswordTitle,
                style: Theme.of(context).textTheme.headline2,
              ),
              Text(
                moForgetPasswordSubtitle,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(
                height: 10.0,
              ),
              ForgetPasswordBtnWidget(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const ForgetPasswordMailScreen());
                },
                btnIcon: Icons.email_outlined,
                title: moEmail,
                subtitle: moResetViaEmail,
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
