import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Creates a new unique id for a database row.
///
/// We use UUID strings instead of SQLite AUTOINCREMENT so the same ids can be
/// used in Firebase later. See docs/architecture.md.
String newId() => _uuid.v4();
