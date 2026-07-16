import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
