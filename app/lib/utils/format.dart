import 'package:intl/intl.dart';

import '../domain/models/bill.dart';
import '../l10n/app_localizations.dart';

/// Formats an amount in kuruş as Turkish lira for the given [locale].
///
/// `formatKurus(125050, 'tr')` returns `₺1.250,50` and
/// `formatKurus(125050, 'en')` returns `₺1,250.50`.
String formatKurus(int kurus, String locale) {
  final format = NumberFormat.currency(
    locale: locale,
    symbol: '₺',
    decimalDigits: 2,
  );
  return format.format(kurus / 100);
}

/// Reads an amount the user typed and returns it in kuruş, or null if the
/// text is not a valid amount.
///
/// Both `,` and `.` are accepted as the decimal separator, so `"1250,50"` and
/// `"1250.50"` both return `125050`. Rules:
///
/// * One separator is the decimal separator: `"1250,5"` → `125050`.
/// * When both `,` and `.` are used, the last one is the decimal separator and
///   the other one groups thousands: `"1.250,50"` and `"1,250.50"` → `125050`.
/// * The same separator used more than once groups thousands:
///   `"1.250.000"` → `125000000`.
/// * More than two decimals are rounded to the nearest kuruş (half up):
///   `"10,005"` → `1001`.
/// * Spaces and a `₺` sign are ignored.
/// * Empty text, letters, negative numbers and misplaced separators give null.
///
/// Only integers are used, so there are no floating-point rounding errors.
int? parseKurus(String text) {
  final cleaned = text.replaceAll(RegExp(r'\s'), '').replaceAll('₺', '');
  if (!RegExp(r'^[0-9.,]+$').hasMatch(cleaned)) return null;

  final lastComma = cleaned.lastIndexOf(',');
  final lastDot = cleaned.lastIndexOf('.');

  String? decimalSeparator;
  String? groupSeparator;
  if (lastComma >= 0 && lastDot >= 0) {
    decimalSeparator = lastComma > lastDot ? ',' : '.';
    groupSeparator = lastComma > lastDot ? '.' : ',';
  } else if (lastComma >= 0 || lastDot >= 0) {
    final separator = lastComma >= 0 ? ',' : '.';
    if (separator.allMatches(cleaned).length == 1) {
      decimalSeparator = separator;
    } else {
      groupSeparator = separator;
    }
  }

  var wholePart = cleaned;
  var fractionPart = '';
  if (decimalSeparator != null) {
    final index = cleaned.lastIndexOf(decimalSeparator);
    wholePart = cleaned.substring(0, index);
    fractionPart = cleaned.substring(index + 1);
    // Digits are required on both sides: "12," and ",5" are not amounts.
    if (wholePart.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(fractionPart)) {
      return null;
    }
  }

  if (groupSeparator != null) {
    // Thousands groups must be exactly 3 digits: "1.250" but not "12.50.0".
    final grouped = RegExp(
      '^[0-9]{1,3}(${RegExp.escape(groupSeparator)}[0-9]{3})+\$',
    );
    if (!grouped.hasMatch(wholePart)) return null;
    wholePart = wholePart.replaceAll(groupSeparator, '');
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(wholePart)) return null;

  final lira = int.tryParse(wholePart);
  if (lira == null) return null;

  // Pad to at least 3 digits: 2 for kuruş and 1 to decide the rounding.
  final digits = fractionPart.padRight(3, '0');
  var kurus = int.parse(digits.substring(0, 2));
  if (int.parse(digits[2]) >= 5) kurus += 1;

  return lira * 100 + kurus;
}

/// Formats a date stored in UTC as a short date in the user's local time,
/// e.g. `28 Eki 2026` in Turkish or `28 Oct 2026` in English.
///
/// Date names for the locale must be loaded first. In the app,
/// `GlobalMaterialLocalizations.delegate` does this; in tests, call
/// `initializeDateFormatting()` from `package:intl/date_symbol_data_local.dart`.
String formatDate(DateTime utc, String locale) =>
    DateFormat('d MMM y', locale).format(utc.toLocal());

/// The name of [category] in the user's language, e.g. `Elektrik` for
/// [BillCategory.electricity] in Turkish.
///
/// The names are in `app_tr.arb` and `app_en.arb`. The switch has no
/// `default`, so adding a new category without a name is a compile error.
String billCategoryName(BillCategory category, AppLocalizations l10n) =>
    switch (category) {
      BillCategory.rent => l10n.categoryRent,
      BillCategory.electricity => l10n.categoryElectricity,
      BillCategory.water => l10n.categoryWater,
      BillCategory.gas => l10n.categoryGas,
      BillCategory.internet => l10n.categoryInternet,
      BillCategory.other => l10n.categoryOther,
    };
