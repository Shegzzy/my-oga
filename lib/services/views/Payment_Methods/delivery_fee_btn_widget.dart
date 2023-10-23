import 'package:flutter/material.dart';

class DeliveryServiceFeeBtnWidget extends StatelessWidget {
  const DeliveryServiceFeeBtnWidget({
    required this.btnIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.price,

    Key? key,
  }) : super(key: key);

  final IconData btnIcon;
  final String title, subtitle, price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey.shade200
        ),
        child: Row(
          children: [
            Icon(btnIcon, size: 60.0,),
            const SizedBox(width: 10.0,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headline5,),
                Text(subtitle, style: Theme.of(context).textTheme.bodyText2,),
                Text(price, style: Theme.of(context).textTheme.headline6,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}