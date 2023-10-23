import 'package:flutter/material.dart';

import '../../../constants/texts_string.dart';
import 'delivery_fee_btn_widget.dart';

class DeliveryServiceFee {
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
                moDeliveryFeeTitle,
                style: Theme.of(context).textTheme.headline2,
              ),
              Text(
                moDeliveryFeeSubtitle,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(
                height: 10.0,
              ),
              DeliveryServiceFeeBtnWidget(
                onTap: () {
                  //Navigator.pop(context);
                  //Get.to(() => const ForgetPasswordMailScreen());
                },
                btnIcon: Icons.email_outlined,
                title: moExpress,
                subtitle: moExpressDays,
                price: "N5000",
              ),
              const SizedBox(
                height: 10.0,
              ),
              DeliveryServiceFeeBtnWidget(
                onTap: () {
                  //Navigator.pop(context);
                  //Get.to(() => const ForgetPasswordPhoneScreen());
                },
                btnIcon: Icons.mobile_friendly_outlined,
                title: moStandard,
                subtitle: moStandardDays,
                price: "N3700",
              ),
              const SizedBox(
                height: 10.0,
              ),
              DeliveryServiceFeeBtnWidget(
                onTap: () {
                  //Navigator.pop(context);
                  //Get.to(() => const ForgetPasswordMailScreen());
                },
                btnIcon: Icons.email_outlined,
                title: moNormal,
                subtitle: moNormalDays,
                price: "N2800",
              ),
            ],
          ),
        ),
      ),
    );
  }
}


