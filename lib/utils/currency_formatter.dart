import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatCurrency.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
