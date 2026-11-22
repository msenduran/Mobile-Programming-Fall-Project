import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/data/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location istanbul;

  setUpAll(() {
    tz_data.initializeTimeZones();
    istanbul = tz.getLocation('Europe/Istanbul');
  });

  group('reminderTime', () {
    test('is 10:00 Istanbul time on the day before the due date', () {
      final when = reminderTime(DateTime.utc(2026, 11, 30), location: istanbul);

      expect(when.location, istanbul);
      expect(
        [when.year, when.month, when.day, when.hour, when.minute],
        [2026, 11, 29, 10, 0],
      );
      // Istanbul is UTC+3, so this is 07:00 UTC.
      expect(when.toUtc(), DateTime.utc(2026, 11, 29, 7));
    });

    test('ignores the time of day of the due date', () {
      final late = reminderTime(
        DateTime.utc(2026, 11, 30, 20, 59), // 23:59 in Istanbul
        location: istanbul,
      );

      expect([late.day, late.hour], [29, 10]);
    });

    test('goes back to the previous month and year', () {
      final when = reminderTime(DateTime.utc(2027, 1, 1), location: istanbul);

      expect([when.year, when.month, when.day], [2026, 12, 31]);
    });

    test('handles March 1st in a non-leap year', () {
      final when = reminderTime(DateTime.utc(2027, 3, 1), location: istanbul);

      expect([when.month, when.day], [2, 28]);
    });
  });

  group('notificationId', () {
    const billId = '3f2c9a54-8d1e-4b7a-9c3d-2e1f0a6b5c4d';

    test('is the same every time for the same bill', () {
      expect(notificationId(billId), notificationId(billId));
    });

    test('is different for different bills', () {
      final ids = {for (var i = 0; i < 1000; i++) notificationId('bill-$i')};
      expect(ids.length, 1000);
    });

    test('fits in a positive 32-bit int', () {
      for (final id in [billId, '', 'a', 'çok uzun bir fatura kimliği' * 20]) {
        final n = notificationId(id);
        expect(n, greaterThanOrEqualTo(0));
        expect(n, lessThanOrEqualTo(0x7fffffff));
      }
    });
  });
}
