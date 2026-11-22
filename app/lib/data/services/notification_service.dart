import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/bill.dart';
import '../../l10n/app_localizations.dart';

/// Reminds members one day before a bill is due, with a local notification.
///
/// Wraps the `flutter_local_notifications` plugin so the rest of the app
/// doesn't use it directly. [BillRepositorySqlite] calls this service when a
/// bill is added, paid or deleted.
class NotificationService {
  static const _channelId = 'bill_reminders';

  /// All our users live in Turkey, and Turkey has one time zone without
  /// daylight saving time, so we don't need to ask the phone for its zone.
  static const _timeZone = 'Europe/Istanbul';

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Must be called once in `main()` before scheduling anything.
  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timeZone));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Shows the "allow notifications" dialog on Android 13 and newer.
  /// Older versions allow notifications without asking.
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Schedules the reminder of [bill] for 10:00 one day before its due date.
  ///
  /// Nothing is scheduled if the bill is already paid or that time has
  /// already passed. Scheduling the same bill again replaces the old one.
  Future<void> scheduleBillReminder(Bill bill) async {
    if (bill.isPaid) return;

    final when = reminderTime(bill.dueDate, location: tz.local);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;

    final texts = _texts();
    await _plugin.zonedSchedule(
      id: notificationId(bill.id),
      title: texts.billReminderTitle(bill.title),
      body: texts.billReminderBody,
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          texts.billReminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // Inexact: Android may show it a few minutes late, but we don't need
      // the "alarms & reminders" permission that exact alarms require.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels the reminder of the bill, if there is one.
  Future<void> cancelBillReminder(String billId) =>
      _plugin.cancel(id: notificationId(billId));

  /// Notification texts in the phone's language (Turkish if we don't have it).
  AppLocalizations _texts() {
    final locale = PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    return lookupAppLocalizations(supported ? locale : const Locale('tr'));
  }
}

/// 10:00 on the day before [dueDate], in [location].
///
/// Only the calendar day of [dueDate] in [location] is used, not its time.
tz.TZDateTime reminderTime(DateTime dueDate, {required tz.Location location}) {
  final due = tz.TZDateTime.from(dueDate, location);
  // Day - 1 also works on the 1st of a month: DateTime rolls back to the
  // last day of the previous month.
  return tz.TZDateTime(location, due.year, due.month, due.day - 1, 10);
}

/// The plugin needs an `int` id, but our bill ids are UUID strings.
///
/// This turns the bill id into a number that is always the same for the same
/// bill (FNV-1a hash), so we can cancel the reminder later. `String.hashCode`
/// is not used because Dart doesn't promise it stays the same between runs.
int notificationId(String billId) {
  var hash = 0x811c9dc5;
  for (final unit in billId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  // Android ids are 32-bit signed ints; keep it positive.
  return hash & 0x7fffffff;
}
