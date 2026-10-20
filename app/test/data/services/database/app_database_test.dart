import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/data/services/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Tests run on the computer, not on Android, so we use the desktop
  // (FFI) version of sqflite with a fresh in-memory database for each test.
  setUpAll(() => databaseFactory = databaseFactoryFfiNoIsolate);

  late Database db;

  setUp(() async {
    db = await AppDatabase(path: inMemoryDatabasePath).database;
    await db.insert('houses', {
      'id': 'h1',
      'name': 'Avcılar Evi',
      'invite_code': 'K7Q2XM',
      'created_at': 0,
    });
    for (final id in ['m1', 'm2']) {
      await db.insert('members', {
        'id': id,
        'house_id': 'h1',
        'name': id,
        'created_at': 0,
      });
    }
    await db.insert('bills', {
      'id': 'b1',
      'house_id': 'h1',
      'title': 'Kira',
      'category': 'rent',
      'amount_kurus': 1000000,
      'due_date': 0,
      'created_by': 'm1',
      'created_at': 0,
    });
    for (final id in ['m1', 'm2']) {
      await db.insert('bill_shares', {
        'bill_id': 'b1',
        'member_id': id,
        'amount_kurus': 500000,
      });
    }
  });

  tearDown(() => db.close());

  Future<int> count(String table) async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'))!;

  test('creates all tables', () async {
    expect(await count('houses'), 1);
    expect(await count('members'), 2);
    expect(await count('bills'), 1);
    expect(await count('bill_shares'), 2);
  });

  test('deleting a house deletes its members, bills and shares', () async {
    await db.delete('houses', where: 'id = ?', whereArgs: ['h1']);

    expect(await count('members'), 0);
    expect(await count('bills'), 0);
    expect(await count('bill_shares'), 0);
  });

  test('a bill cannot belong to a house that does not exist', () async {
    final insert = db.insert('bills', {
      'id': 'b2',
      'house_id': 'no-such-house',
      'title': 'Su',
      'category': 'water',
      'amount_kurus': 30000,
      'due_date': 0,
      'created_by': 'm1',
      'created_at': 0,
    });

    await expectLater(insert, throwsA(isA<DatabaseException>()));
  });

  test('a member has only one share per bill', () async {
    final insert = db.insert('bill_shares', {
      'bill_id': 'b1',
      'member_id': 'm1',
      'amount_kurus': 1,
    });

    await expectLater(insert, throwsA(isA<DatabaseException>()));
  });

  test('invite codes are unique', () async {
    final insert = db.insert('houses', {
      'id': 'h2',
      'name': 'Başka Ev',
      'invite_code': 'K7Q2XM',
      'created_at': 0,
    });

    await expectLater(insert, throwsA(isA<DatabaseException>()));
  });
}
