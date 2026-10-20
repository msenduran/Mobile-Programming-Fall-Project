// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Öğrenci Evim';

  @override
  String get tabBills => 'Faturalar';

  @override
  String get tabBalances => 'Borçlar';

  @override
  String get tabChat => 'Sohbet';

  @override
  String get billsEmptyTitle => 'Henüz fatura yok';

  @override
  String get billsEmptyMessage =>
      'Kira ve faturalar burada listelenecek: tutarı, son ödeme tarihi ve kimin ödediği.';

  @override
  String get balancesEmptyTitle => 'Borç yok';

  @override
  String get balancesEmptyMessage =>
      'Kimin kime ne kadar borcu olduğu burada görünecek.';

  @override
  String get chatEmptyTitle => 'Ev sohbeti';

  @override
  String get chatEmptyMessage => 'Ev arkadaşlarınla burada yazışabileceksin.';
}
