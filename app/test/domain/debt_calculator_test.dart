import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/domain/debt_calculator.dart';
import 'package:ogrenci_evim/domain/models/bill.dart';
import 'package:ogrenci_evim/domain/models/bill_share.dart';
import 'package:ogrenci_evim/domain/models/debt.dart';

// Members used in the tests: Ayşe, Mehmet and Zeynep.
const ayse = 'ayse';
const mehmet = 'mehmet';
const zeynep = 'zeynep';

Bill bill(String id, {String? paidBy, int amountKurus = 0}) => Bill(
  id: id,
  houseId: 'h1',
  title: id,
  category: BillCategory.other,
  amountKurus: amountKurus,
  dueDate: DateTime.utc(2026, 11, 30),
  paidBy: paidBy,
  createdBy: ayse,
  createdAt: DateTime.utc(2026, 11, 1),
);

BillShare share(
  String billId,
  String memberId,
  int amountKurus, {
  bool paid = false,
}) => BillShare(
  billId: billId,
  memberId: memberId,
  amountKurus: amountKurus,
  paidAt: paid ? DateTime.utc(2026, 11, 20) : null,
);

Debt debt(String from, String to, int amountKurus) =>
    Debt(fromMemberId: from, toMemberId: to, amountKurus: amountKurus);

void main() {
  test('no bills means no debts', () {
    expect(calculateDebts([], []), isEmpty);
  });

  test('a bill nobody has paid yet creates no debts', () {
    final bills = [bill('rent')];
    final shares = [share('rent', ayse, 500000), share('rent', mehmet, 500000)];

    expect(calculateDebts(bills, shares), isEmpty);
  });

  test('when one member pays, the others owe their shares to them', () {
    final bills = [bill('electricity', paidBy: ayse)];
    final shares = [
      share('electricity', ayse, 30000),
      share('electricity', mehmet, 30000),
      share('electricity', zeynep, 30000),
    ];

    expect(calculateDebts(bills, shares), [
      debt(mehmet, ayse, 30000),
      debt(zeynep, ayse, 30000),
    ]);
  });

  test('debts to the same payer from several bills are added up', () {
    final bills = [bill('water', paidBy: ayse), bill('gas', paidBy: ayse)];
    final shares = [
      share('water', ayse, 5000),
      share('water', mehmet, 5000),
      share('gas', ayse, 20000),
      share('gas', mehmet, 20000),
    ];

    expect(calculateDebts(bills, shares), [debt(mehmet, ayse, 25000)]);
  });

  test('debts between two members cancel out', () {
    // Mehmet owes Ayşe 100 TL, Ayşe owes Mehmet 30 TL -> Mehmet owes 70 TL.
    final bills = [
      bill('rent', paidBy: ayse),
      bill('internet', paidBy: mehmet),
    ];
    final shares = [
      share('rent', ayse, 10000),
      share('rent', mehmet, 10000),
      share('internet', ayse, 3000),
      share('internet', mehmet, 3000),
    ];

    expect(calculateDebts(bills, shares), [debt(mehmet, ayse, 7000)]);
  });

  test('the debt changes direction when the other side is larger', () {
    final bills = [
      bill('rent', paidBy: ayse),
      bill('internet', paidBy: mehmet),
    ];
    final shares = [
      share('rent', mehmet, 3000),
      share('internet', ayse, 10000),
    ];

    expect(calculateDebts(bills, shares), [debt(ayse, mehmet, 7000)]);
  });

  test('equal debts in both directions leave nothing', () {
    final bills = [bill('water', paidBy: ayse), bill('gas', paidBy: mehmet)];
    final shares = [share('water', mehmet, 5000), share('gas', ayse, 5000)];

    expect(calculateDebts(bills, shares), isEmpty);
  });

  test('paid shares are not debts any more', () {
    final bills = [bill('electricity', paidBy: ayse)];
    final shares = [
      share('electricity', ayse, 30000),
      share('electricity', mehmet, 30000, paid: true),
      share('electricity', zeynep, 30000),
    ];

    expect(calculateDebts(bills, shares), [debt(zeynep, ayse, 30000)]);
  });

  test('everything paid means no debts', () {
    final bills = [bill('rent', paidBy: ayse), bill('gas', paidBy: mehmet)];
    final shares = [
      share('rent', ayse, 500000),
      share('rent', mehmet, 500000, paid: true),
      share('gas', ayse, 20000, paid: true),
      share('gas', mehmet, 20000),
    ];

    expect(calculateDebts(bills, shares), isEmpty);
  });

  test('shares of bills that are not in the list are ignored', () {
    final bills = [bill('rent', paidBy: ayse)];
    final shares = [share('other-house-bill', mehmet, 9999)];

    expect(calculateDebts(bills, shares), isEmpty);
  });

  test('result is sorted by amount, largest first', () {
    final bills = [bill('rent', paidBy: zeynep), bill('gas', paidBy: ayse)];
    final shares = [share('gas', mehmet, 1000), share('rent', ayse, 50000)];

    expect(calculateDebts(bills, shares), [
      debt(ayse, zeynep, 50000),
      debt(mehmet, ayse, 1000),
    ]);
  });
}
