// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Öğrenci Evim';

  @override
  String get tabBills => 'Bills';

  @override
  String get tabBalances => 'Balances';

  @override
  String get tabChat => 'Chat';

  @override
  String get billsEmptyTitle => 'No bills yet';

  @override
  String get billsEmptyMessage =>
      'Rent and bills will be listed here: amount, due date and who paid.';

  @override
  String get balancesEmptyTitle => 'No debts';

  @override
  String get balancesEmptyMessage => 'Who owes whom will be shown here.';

  @override
  String get chatEmptyTitle => 'House chat';

  @override
  String get chatEmptyMessage =>
      'You will be able to message your housemates here.';
}
