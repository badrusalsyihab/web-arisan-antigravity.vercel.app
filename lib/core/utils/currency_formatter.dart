import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../main.dart';

class CurrencyFormatter {
  static String formatRupiah(num number) {
    final locale = appLocale.value.languageCode;
    final format = NumberFormat.currency(
      locale: locale,
      symbol: locale == 'id' ? 'Rp ' : 'IDR ',
      decimalDigits: 0,
    );
    return format.format(number);
  }

  static String formatNumberWithDots(num number) {
    final locale = appLocale.value.languageCode;
    final format = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 0,
    );
    return format.format(number).trim();
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly) ?? 0;
    final formatted = CurrencyFormatter.formatNumberWithDots(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
