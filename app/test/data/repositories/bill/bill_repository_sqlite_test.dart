import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/data/repositories/bill/bill_repository.dart';
import 'package:ogrenci_evim/data/repositories/bill/bill_repository_sqlite.dart';
import 'package:ogrenci_evim/data/services/database/app_database.dart';
import 'package:ogrenci_evim/domain/models/bill.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Same setup as app_database_test.dart: desktop sqflite with a fresh
  // in-memory database for each test.
  setUpAll(() => databaseFactory = databaseFactoryFfiNoIsolate);

  final now = DateTime.utc(2026, 11, 17, 18);
  const members = ['ayse', 'mehmet', 'samet'];

  late AppDatabase appDatabase;
  late BillRepository repository;

  setUp(() async {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    repository = BillRepositorySqlite(appDatabase, clock: () => now);

    // Bills need a house and members because of the foreign keys.
    final db = await appDatabase.database;
    await db.insert('houses', {
      'id': 'h1',
      'name': 'Avcılar Evi',
      'invite_code': 'K7Q2XM',
      'created_at': 0,
    });
    for (final id in members) {
      await db.insert('members', {
        'id': id,
        'house_id': 'h1',
        'name': id,
        'created_at': 0,
      });
    }
  });

  tearDown(() async => (await appDatabase.database).close());

  Bill bill(
    String id, {
    int amountKurus = 10000,
    DateTime? dueDate,
    String? paidBy,
  }) => Bill(
    id: id,
    houseId: 'h1',
    title: 'Elektrik',
    category: BillCategory.electricity,
    amountKurus: amountKurus,
    dueDate: dueDate ?? DateTime.utc(2026, 11, 28),
    paidBy: paidBy,
    createdBy: 'ayse',
    createdAt: now,
  );

  group('addBill', () {
    test('creates one share per member that add up to the bill', () async {
      await repository.addBill(bill('b1', amountKurus: 10000), members);

      final shares = await repository.getShares('b1');
      expect(shares.map((s) => s.memberId), members);
      expect(shares.map((s) => s.amountKurus), [3334, 3333, 3333]);
      expect(shares.every((s) => !s.isPaid), isTrue);
    });

    test(
      'marks the payer\'s share as paid if the bill is already paid',
      () async {
        await repository.addBill(bill('b1', paidBy: 'mehmet'), members);

        final shares = await repository.getShares('b1');
        final paid = shares.where((s) => s.isPaid).map((s) => s.memberId);
        expect(paid, ['mehmet']);
      },
    );

    test('rejects an empty or repeated member list', () async {
      expect(() => repository.addBill(bill('b1'), []), throwsArgumentError);
      expect(
        () => repository.addBill(bill('b1'), ['ayse', 'ayse']),
        throwsArgumentError,
      );
      expect(await repository.getBills('h1'), isEmpty);
    });

    test('saves nothing if a share cannot be saved', () async {
      final add = repository.addBill(bill('b1'), ['ayse', 'no-such-member']);

      await expectLater(add, throwsA(isA<DatabaseException>()));
      expect(await repository.getBills('h1'), isEmpty);
      expect(await repository.getShares('b1'), isEmpty);
    });
  });

  test('getBills returns the bill due first at the top', () async {
    await repository.addBill(
      bill('later', dueDate: DateTime.utc(2026, 12, 5)),
      members,
    );
    await repository.addBill(
      bill('sooner', dueDate: DateTime.utc(2026, 11, 20)),
      members,
    );

    final bills = await repository.getBills('h1');
    expect(bills.map((b) => b.id), ['sooner', 'later']);
    expect(await repository.getBills('other-house'), isEmpty);
  });

  test('markBillPaid sets the payer and marks only their share', () async {
    await repository.addBill(bill('b1'), members);

    await repository.markBillPaid('b1', 'samet');

    final saved = (await repository.getBills('h1')).single;
    expect(saved.paidBy, 'samet');
    final shares = await repository.getShares('b1');
    final paid = shares.where((s) => s.isPaid).toList();
    expect(paid.single.memberId, 'samet');
    expect(paid.single.paidAt, now);
  });

  test('markSharePaid sets paid_at for one member only', () async {
    await repository.addBill(bill('b1'), members);
    await repository.markBillPaid('b1', 'ayse');

    await repository.markSharePaid('b1', 'mehmet');

    final shares = {
      for (final s in await repository.getShares('b1')) s.memberId: s,
    };
    expect(shares['mehmet']!.paidAt, now);
    expect(shares['samet']!.isPaid, isFalse);
  });

  test('deleteBill deletes the bill and its shares', () async {
    await repository.addBill(bill('b1'), members);
    await repository.addBill(bill('b2'), members);

    await repository.deleteBill('b1');

    expect((await repository.getBills('h1')).map((b) => b.id), ['b2']);
    expect(await repository.getShares('b1'), isEmpty);
    expect((await repository.getShares('b2')).length, 3);
  });
}
