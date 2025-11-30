import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
    locale: 'es_PE',
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return NumberFormat('#,##0.00', 'es_PE').format(amount);
  }
}

