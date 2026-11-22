import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/bill/bill_repository.dart';
import '../data/repositories/bill/bill_repository_sqlite.dart';
import '../data/repositories/house/house_repository.dart';
import '../data/repositories/house/house_repository_sqlite.dart';
import '../data/services/database/app_database.dart';
import '../data/services/notification_service.dart';
import '../data/services/preferences_service.dart';

/// Every object the app shares through provider is registered here.
///
/// This is the only place that knows which repository implementation is used
/// (`_sqlite` now, `_firebase` in phase 2). See docs/architecture.md.
///
/// [notificationService] is created in `main()` because it has to be
/// initialized before the app starts.
List<SingleChildWidget> providers(NotificationService notificationService) => [
  Provider<AppDatabase>(create: (_) => AppDatabase()),
  Provider<NotificationService>.value(value: notificationService),
  Provider<PreferencesService>(create: (_) => PreferencesService()),
  Provider<HouseRepository>(
    create: (context) => HouseRepositorySqlite(context.read<AppDatabase>()),
  ),
  Provider<BillRepository>(
    create: (context) => BillRepositorySqlite(
      context.read<AppDatabase>(),
      context.read<NotificationService>(),
    ),
  ),
];
