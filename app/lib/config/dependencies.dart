import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/services/database/app_database.dart';

/// Every object the app shares through provider is registered here.
///
/// This is the only place that knows which repository implementation is used
/// (`_sqlite` now, `_firebase` in phase 2). See docs/architecture.md.
List<SingleChildWidget> get providers => [
  Provider<AppDatabase>(create: (_) => AppDatabase()),
  // Repositories go here, for example:
  // Provider<BillRepository>(
  //   create: (context) => BillRepositorySqlite(context.read<AppDatabase>()),
  // ),
];
