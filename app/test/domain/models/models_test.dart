import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/domain/models/bill.dart';
import 'package:ogrenci_evim/domain/models/bill_share.dart';
import 'package:ogrenci_evim/domain/models/house.dart';
import 'package:ogrenci_evim/domain/models/member.dart';

// Each model must come back unchanged after toMap -> fromMap, otherwise data
// would change when it goes through the database.
void main() {
  final createdAt = DateTime.utc(2026, 10, 20, 12, 30);

  test('House survives a database round trip', () {
    final house = House(
      id: 'h1',
      name: 'Avcılar Evi',
      inviteCode: 'K7Q2XM',
      createdAt: createdAt,
    );
    final copy = House.fromMap(house.toMap());

    expect(copy.toMap(), house.toMap());
    expect(copy.createdAt, createdAt);
  });

  test('Member survives a database round trip', () {
    final member = Member(
      id: 'm1',
      houseId: 'h1',
      name: 'Ayşe',
      createdAt: createdAt,
    );

    expect(Member.fromMap(member.toMap()).toMap(), member.toMap());
  });

  test('Bill stores category by name and keeps an unpaid bill unpaid', () {
    final bill = Bill(
      id: 'b1',
      houseId: 'h1',
      title: 'Ekim elektrik',
      category: BillCategory.electricity,
      amountKurus: 125050,
      dueDate: DateTime.utc(2026, 10, 28),
      createdBy: 'm1',
      createdAt: createdAt,
    );
    final map = bill.toMap();
    final copy = Bill.fromMap(map);

    expect(map['category'], 'electricity');
    expect(map['paid_by'], isNull);
    expect(copy.category, BillCategory.electricity);
    expect(copy.isPaid, isFalse);
    expect(copy.toMap(), map);
  });

  test('BillShare keeps paidAt null or set', () {
    const unpaid = BillShare(billId: 'b1', memberId: 'm2', amountKurus: 41684);
    final paid = BillShare(
      billId: 'b1',
      memberId: 'm3',
      amountKurus: 41683,
      paidAt: createdAt,
    );

    expect(BillShare.fromMap(unpaid.toMap()).isPaid, isFalse);
    expect(BillShare.fromMap(paid.toMap()).paidAt, createdAt);
  });
}
