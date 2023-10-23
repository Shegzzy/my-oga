import 'package:flutter/material.dart';
import 'package:myoga/constants/colors.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: moSecondarColor,
      child: Container(
        margin: const EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(width: 6.0,),
              SizedBox(width: 20, height: 20, child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black), strokeWidth: 2,)),
              const SizedBox(width: 8.0,),
              Text(message, style: const TextStyle(color: Colors.black, fontSize: 12),),
            ],
          ),
        ),
      ),
    );
  }
}
