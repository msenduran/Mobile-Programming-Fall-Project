import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database and creates / migrates its tables.
///
/// When you add a table or column: bump [_version], add the change to
/// [_onCreate] for new installs, and add a migration step to [_onUpgrade]
/// for apps that already have an older version installed.
class AppDatabase {
  /// [path] is only given in tests, to use an in-memory database.
  AppDatabase({this.path});

  static const _fileName = 'ogrenci_evim.db';
  static const _version = 1;

  final String? path;
  Database? _database;

  /// The database is opened the first time it is needed.
  Future<Database> get database async {
    return _database ??= await openDatabase(
      path ?? join(await getDatabasesPath(), _fileName),
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

  // Column rules (see docs/architecture.md): ids are UUID strings, money is
  // INTEGER kuruş, dates are INTEGER UTC milliseconds since epoch.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE houses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        invite_code TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        house_id TEXT NOT NULL REFERENCES houses (id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // paid_by is NULL until someone pays the whole bill.
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        house_id TEXT NOT NULL REFERENCES houses (id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount_kurus INTEGER NOT NULL CHECK (amount_kurus > 0),
        due_date INTEGER NOT NULL,
        paid_by TEXT REFERENCES members (id),
        created_by TEXT NOT NULL REFERENCES members (id),
        created_at INTEGER NOT NULL
      )
    ''');

    // One row per member per bill. paid_at is NULL while the member still
    // owes their share.
    await db.execute('''
      CREATE TABLE bill_shares (
        bill_id TEXT NOT NULL REFERENCES bills (id) ON DELETE CASCADE,
        member_id TEXT NOT NULL REFERENCES members (id),
        amount_kurus INTEGER NOT NULL CHECK (amount_kurus >= 0),
        paid_at INTEGER,
        PRIMARY KEY (bill_id, member_id)
      )
    ''');

    // Most queries ask for "everything in this house".
    await db.execute('CREATE INDEX members_house_id ON members (house_id)');
    await db.execute('CREATE INDEX bills_house_id ON bills (house_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration steps go here, for example:
    // if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
  }
}
