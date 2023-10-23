import 'package:flutter/material.dart';

class DashboardSearchBox extends StatelessWidget {
  const DashboardSearchBox({
    Key? key,
    required this.txtTheme,
  }) : super(key: key);

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(width: 4.0))),
      padding: const EdgeInsets.symmetric(
          horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Search", style: txtTheme.headline2?.apply(
              color: Colors.grey.withOpacity(0.5))),
          const Icon(Icons.mic, size: 25.0,)
        ],
      ),
    );
  }
}