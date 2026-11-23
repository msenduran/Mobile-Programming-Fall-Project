import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ogrenci_evim/domain/models/bill.dart';
import 'package:ogrenci_evim/l10n/app_localizations.dart';
import 'package:ogrenci_evim/utils/format.dart';

void main() {
  group('formatKurus', () {
    test('formats Turkish lira in Turkish', () {
      expect(formatKurus(125050, 'tr'), '₺1.250,50');
    });

    test('formats Turkish lira in English', () {
      expect(formatKurus(125050, 'en'), '₺1,250.50');
    });

    test('always shows two decimals', () {
      expect(formatKurus(0, 'tr'), '₺0,00');
      expect(formatKurus(5, 'tr'), '₺0,05');
      expect(formatKurus(100, 'tr'), '₺1,00');
      expect(formatKurus(1999, 'tr'), '₺19,99');
    });

    test('groups large amounts', () {
      expect(formatKurus(123456789, 'tr'), '₺1.234.567,89');
    });
  });

  group('parseKurus', () {
    test('accepts comma or dot as the decimal separator', () {
      expect(parseKurus('1250,50'), 125050);
      expect(parseKurus('1250.50'), 125050);
    });

    test('accepts whole lira and one decimal', () {
      expect(parseKurus('1250'), 125000);
      expect(parseKurus('1250,5'), 125050);
      expect(parseKurus('0,05'), 5);
      expect(parseKurus('0'), 0);
    });

    test('accepts thousands separators', () {
      expect(parseKurus('1.250,50'), 125050);
      expect(parseKurus('1,250.50'), 125050);
      expect(parseKurus('1.250.000'), 125000000);
      expect(parseKurus('1.250.000,75'), 125000075);
    });

    test('ignores spaces and the lira sign', () {
      expect(parseKurus(' 1250,50 '), 125050);
      expect(parseKurus('₺1.250,50'), 125050);
    });

    test('reads back what formatKurus writes', () {
      for (final kurus in [0, 5, 99, 125050, 123456789]) {
        expect(parseKurus(formatKurus(kurus, 'tr')), kurus);
        expect(parseKurus(formatKurus(kurus, 'en')), kurus);
      }
    });

    test('rounds more than two decimals to the nearest kuruş', () {
      expect(parseKurus('10,004'), 1000);
      expect(parseKurus('10,005'), 1001);
      expect(parseKurus('10.009'), 1001);
      expect(parseKurus('9,999'), 1000);
      expect(parseKurus('0,001'), 0);
    });

    test('returns null for invalid input', () {
      for (final text in [
        '',
        '   ',
        'abc',
        '12a',
        '-50',
        '+50',
        ',',
        ',50',
        '50,',
        '1,2,3.4.5',
        '12.50.0',
        '1.25.000',
        '1,250,50.5,0',
        '₺',
      ]) {
        expect(parseKurus(text), isNull, reason: '"$text"');
      }
    });
  });

  group('formatDate', () {
    setUpAll(() async {
      await initializeDateFormatting();
    });

    test('shows day, short month and year', () {
      // Noon UTC is the same day in every time zone, so this works anywhere.
      final date = DateTime.utc(2026, 10, 28, 12);
      expect(formatDate(date, 'tr'), '28 Eki 2026');
      expect(formatDate(date, 'en'), '28 Oct 2026');
    });

    test('converts UTC to local time', () {
      // 22:00 UTC on 27 October is already 28 October in Istanbul (UTC+3).
      final date = DateTime.utc(2026, 10, 27, 22);
      final local = date.toLocal();
      expect(formatDate(date, 'tr'), '${local.day} Eki 2026');
    });
  });

  group('billCategoryName', () {
    test('gives a Turkish name for every category', () {
      final tr = lookupAppLocalizations(const Locale('tr'));
      expect(billCategoryName(BillCategory.rent, tr), 'Kira');
      expect(billCategoryName(BillCategory.electricity, tr), 'Elektrik');
      expect(billCategoryName(BillCategory.water, tr), 'Su');
      expect(billCategoryName(BillCategory.gas, tr), 'Doğalgaz');
      expect(billCategoryName(BillCategory.internet, tr), 'İnternet');
      expect(billCategoryName(BillCategory.other, tr), 'Diğer');
    });

    test('gives an English name for every category', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(billCategoryName(BillCategory.rent, en), 'Rent');
      expect(billCategoryName(BillCategory.electricity, en), 'Electricity');
      expect(billCategoryName(BillCategory.water, en), 'Water');
      expect(billCategoryName(BillCategory.gas, en), 'Gas');
      expect(billCategoryName(BillCategory.internet, en), 'Internet');
      expect(billCategoryName(BillCategory.other, en), 'Other');
    });
  });
}
