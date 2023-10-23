import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/image_strings.dart';

class DashboardBanners extends StatelessWidget {
  const DashboardBanners({
    Key? key,
    required this.txtTheme,
  }) : super(key: key);

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: PCardBgColor),
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(child: Image(
                      image: AssetImage(moBookmark), height: 20.0,)),
                    Flexible(
                        child: Image(image: AssetImage(moBannerOne))),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text("Book a rider with just a click", style: txtTheme
                    .headline4, maxLines: 2, overflow: TextOverflow
                    .ellipsis,),
                Text("Easy, Piss", style: txtTheme.bodyText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius
                    .circular(10.0), color: PCardBgColor),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween,
                      children: const [
                        Flexible(child: Image(
                          image: AssetImage(moBookmark),
                          height: 20.0,)),
                        Flexible(child: Image(
                            image: AssetImage(moBannerTwo))),
                      ],
                    ),
                    Text("Get your parcel delivered",
                      style: txtTheme.headline4,
                      overflow: TextOverflow.ellipsis,),
                    Text("Fast, Secured", style: txtTheme.bodyText2,
                      overflow: TextOverflow.ellipsis,),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () {}, child: const Text("View All")),
              ),
            ],
          ),
        ),

      ],
    );
  }
}