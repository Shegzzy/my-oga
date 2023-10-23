import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../models/dashboard/categories_model.dart';

class DashboardCategories extends StatelessWidget {
  const DashboardCategories({
    Key? key,
    required this.txtTheme,
  }) : super(key: key);

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    final list = DashboardCategoriesModel.list;
    return SizedBox(
      height: 45.0,
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          onTap: list[index].onPress,
          child: SizedBox(
            width: 170.0,
            height: 45.0,
            child: Row(
              children: [
                Container(
                  width: 45.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: PDarkColor
                  ),
                  child: Center(
                    child: Text(list[index].title,
                      style: txtTheme.headline6?.apply(
                          color: Colors.white),),
                  ),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(list[index].heading, style: txtTheme.headline6,
                        overflow: TextOverflow.ellipsis,),
                      Text(list[index].subheading, style: txtTheme.bodyText2,
                        overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}