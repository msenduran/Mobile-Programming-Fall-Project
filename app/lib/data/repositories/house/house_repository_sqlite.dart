import 'package:sqflite/sqflite.dart';

import '../../../domain/models/house.dart';
import '../../../domain/models/member.dart';
import '../../../utils/id.dart';
import '../../../utils/invite_code.dart';
import '../../services/database/app_database.dart';
import 'house_repository.dart';

/// [HouseRepository] that stores houses and members in SQLite.
class HouseRepositorySqlite implements HouseRepository {
  /// [newCode] is only given in tests, to control which invite codes are made.
  HouseRepositorySqlite(this._appDatabase, {String Function()? newCode})
    : _newCode = newCode ?? newInviteCode;

  final AppDatabase _appDatabase;
  final String Function() _newCode;

  @override
  Future<(House, Member)> createHouse(
    String houseName,
    String memberName,
  ) async {
    final db = await _appDatabase.database;
    final now = DateTime.now().toUtc();

    // The house and its first member are saved together: if one insert
    // fails, neither is saved.
    return db.transaction((txn) async {
      final house = House(
        id: newId(),
        name: houseName.trim(),
        inviteCode: await _unusedInviteCode(txn),
        createdAt: now,
      );
      final member = Member(
        id: newId(),
        houseId: house.id,
        name: memberName.trim(),
        createdAt: now,
      );
      await txn.insert('houses', house.toMap());
      await txn.insert('members', member.toMap());
      return (house, member);
    });
  }

  /// Makes invite codes until one is not used by another house.
  ///
  /// With 32^6 (about 1 billion) possible codes a clash is very unlikely,
  /// but the `invite_code` column is UNIQUE, so we check instead of hoping.
  Future<String> _unusedInviteCode(Transaction txn) async {
    while (true) {
      final code = _newCode();
      final rows = await txn.query(
        'houses',
        columns: ['id'],
        where: 'invite_code = ?',
        whereArgs: [code],
      );
      if (rows.isEmpty) return code;
    }
  }

  @override
  Future<Member> joinHouse(String inviteCode, String memberName) async {
    final db = await _appDatabase.database;
    final code = normalizeInviteCode(inviteCode);

    final rows = await db.query(
      'houses',
      columns: ['id'],
      where: 'invite_code = ?',
      whereArgs: [code],
    );
    if (rows.isEmpty) throw InviteCodeNotFoundException(code);

    final member = Member(
      id: newId(),
      houseId: rows.first['id'] as String,
      name: memberName.trim(),
      createdAt: DateTime.now().toUtc(),
    );
    await db.insert('members', member.toMap());
    return member;
  }

  @override
  Future<House?> getHouse(String houseId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'houses',
      where: 'id = ?',
      whereArgs: [houseId],
    );
    return rows.isEmpty ? null : House.fromMap(rows.first);
  }

  @override
  Future<List<Member>> getMembers(String houseId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'members',
      where: 'house_id = ?',
      whereArgs: [houseId],
      orderBy: 'created_at, rowid',
    );
    return rows.map(Member.fromMap).toList();
  }
}
