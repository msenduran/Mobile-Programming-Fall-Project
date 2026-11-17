import 'package:sqflite/sqflite.dart';

import '../../../domain/models/bill.dart';
import '../../../domain/models/bill_share.dart';
import '../../../utils/money.dart';
import '../../services/database/app_database.dart';
import 'bill_repository.dart';

/// [BillRepository] that stores bills and shares in SQLite.
class BillRepositorySqlite implements BillRepository {
  /// [clock] is only given in tests, to control the time saved in `paid_at`.
  BillRepositorySqlite(this._appDatabase, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _appDatabase;
  final DateTime Function() _clock;

  int get _nowMillis => _clock().toUtc().millisecondsSinceEpoch;

  @override
  Future<void> addBill(Bill bill, List<String> memberIds) async {
    if (memberIds.isEmpty) {
      throw ArgumentError.value(memberIds, 'memberIds', 'must not be empty');
    }
    if (memberIds.toSet().length != memberIds.length) {
      throw ArgumentError.value(memberIds, 'memberIds', 'has duplicates');
    }

    final db = await _appDatabase.database;
    final amounts = splitEvenly(bill.amountKurus, memberIds.length);

    // A bill is never saved without its shares: if one insert fails,
    // nothing is saved.
    await db.transaction((txn) async {
      await txn.insert('bills', bill.toMap());
      for (var i = 0; i < memberIds.length; i++) {
        final share = BillShare(
          billId: bill.id,
          memberId: memberIds[i],
          amountKurus: amounts[i],
        );
        await txn.insert('bill_shares', share.toMap());
      }
      if (bill.paidBy != null) {
        await _markShareAsPaid(txn, bill.id, bill.paidBy!);
      }
    });
  }

  @override
  Future<List<Bill>> getBills(String houseId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'bills',
      where: 'house_id = ?',
      whereArgs: [houseId],
      orderBy: 'due_date, created_at',
    );
    return rows.map(Bill.fromMap).toList();
  }

  @override
  Future<List<BillShare>> getShares(String billId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'bill_shares',
      where: 'bill_id = ?',
      whereArgs: [billId],
      orderBy: 'rowid',
    );
    return rows.map(BillShare.fromMap).toList();
  }

  @override
  Future<void> markBillPaid(String billId, String memberId) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      await txn.update(
        'bills',
        {'paid_by': memberId},
        where: 'id = ?',
        whereArgs: [billId],
      );
      await _markShareAsPaid(txn, billId, memberId);
    });
  }

  @override
  Future<void> markSharePaid(String billId, String memberId) async {
    final db = await _appDatabase.database;
    await _markShareAsPaid(db, billId, memberId);
  }

  /// Sets `paid_at` of one share to now. A share that is already paid keeps
  /// its first payment time.
  Future<void> _markShareAsPaid(
    DatabaseExecutor db,
    String billId,
    String memberId,
  ) {
    return db.update(
      'bill_shares',
      {'paid_at': _nowMillis},
      where: 'bill_id = ? AND member_id = ? AND paid_at IS NULL',
      whereArgs: [billId, memberId],
    );
  }

  @override
  Future<void> deleteBill(String billId) async {
    final db = await _appDatabase.database;
    // Its shares are deleted by ON DELETE CASCADE (see app_database.dart).
    await db.delete('bills', where: 'id = ?', whereArgs: [billId]);
  }
}
