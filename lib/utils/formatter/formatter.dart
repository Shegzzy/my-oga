import 'dart:math';

import 'package:intl/intl.dart';

class MyOgaFormatter {
  // Currency formatter
  static String currencyFormatter(double amount){
    return NumberFormat.currency(locale: 'en_NGN', symbol: 'N ', decimalDigits: 0, customPattern: '¤#,##0.00',
    ).format(amount);
  }

  // Date formatter
  static String dateFormatter(DateTime? date){
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  }

  // Generates 5 random digits
  static String generateBookingNumber() {
    String randomDigits = Random().nextInt(100000).toString().padLeft(5, '0');
    String bookingNumber = 'MO${randomDigits}BN';
    return bookingNumber;
  }
}