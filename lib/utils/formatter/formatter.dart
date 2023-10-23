import 'package:intl/intl.dart';

class MyOgaFormatter {
  static String currencyFormatter(double amount){
    return NumberFormat.currency(locale: 'en_NGN', symbol: '₦ ', decimalDigits: 0).format(amount);
  }
}