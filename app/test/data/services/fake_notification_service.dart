import 'package:ogrenci_evim/data/services/notification_service.dart';
import 'package:ogrenci_evim/domain/models/bill.dart';

/// A [NotificationService] that only remembers what it was asked to do, so
/// tests can run without the notification plugin.
class FakeNotificationService implements NotificationService {
  /// Ids of the bills whose reminder is scheduled right now.
  final scheduled = <String>{};

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> scheduleBillReminder(Bill bill) async {
    if (!bill.isPaid) scheduled.add(bill.id);
  }

  @override
  Future<void> cancelBillReminder(String billId) async {
    scheduled.remove(billId);
  }
}
