import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database and creates / migrates its tables.
///
/// When you add a table or column: bump [_version], add the change to
/// [_onCreate] for new installs, and add a migration step to [_onUpgrade]
/// for apps that already have an older version installed.
class AppDatabase {
  static const _fileName = 'ogrenci_evim.db';
  static const _version = 1;

  Database? _database;

  /// The database is opened the first time it is needed.
  Future<Database> get database async {
    return _database ??= await openDatabase(
      join(await getDatabasesPath(), _fileName),
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // SQLite doesn't enforce foreign keys unless this is turned on.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // CREATE TABLE statements go here (houses, members, bills, ...).
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration steps go here, for example:
    // if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
  }
}
