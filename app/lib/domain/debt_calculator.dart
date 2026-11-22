import 'models/bill.dart';
import 'models/bill_share.dart';
import 'models/debt.dart';

/// Calculates who owes whom in a house.
///
/// Rules:
/// - Only bills that someone has paid ([Bill.paidBy] is set) create debts.
/// - Every unpaid share of another member is a debt to the payer. The payer's
///   own share is not a debt.
/// - Debts between the same two members cancel out: if A owes B 100 TL and
///   B owes A 30 TL, the result is a single debt "A owes B 70 TL".
///
/// This is a pure function: it does not read the database, so it is easy to
/// test. The result is sorted by amount, largest first.
///
/// Member ids must not contain `|` (UUIDs never do).
List<Debt> calculateDebts(List<Bill> bills, List<BillShare> shares) {
  // Who paid each bill, only for bills that are paid.
  final payerOfBill = <String, String>{
    for (final bill in bills)
      if (bill.paidBy != null) bill.id: bill.paidBy!,
  };

  // Net balance between two members. The key is the two ids in alphabetical
  // order, e.g. 'a|b'. A positive value means the first member owes the
  // second one; a negative value means the second owes the first.
  final netBetween = <String, int>{};

  for (final share in shares) {
    final payer = payerOfBill[share.billId];
    if (payer == null) continue; // bill not paid yet, or not in [bills]
    if (share.isPaid) continue; // member already gave their share
    if (share.memberId == payer) continue; // nobody owes themselves

    final debtor = share.memberId;
    if (debtor.compareTo(payer) < 0) {
      final key = '$debtor|$payer';
      netBetween[key] = (netBetween[key] ?? 0) + share.amountKurus;
    } else {
      final key = '$payer|$debtor';
      netBetween[key] = (netBetween[key] ?? 0) - share.amountKurus;
    }
  }

  final debts = <Debt>[];
  netBetween.forEach((key, amount) {
    if (amount == 0) return; // they cancelled out completely
    final [first, second] = key.split('|');
    debts.add(
      amount > 0
          ? Debt(fromMemberId: first, toMemberId: second, amountKurus: amount)
          : Debt(fromMemberId: second, toMemberId: first, amountKurus: -amount),
    );
  });

  // Largest debt first; equal amounts by member id so the order never changes.
  debts.sort((a, b) {
    final byAmount = b.amountKurus.compareTo(a.amountKurus);
    if (byAmount != 0) return byAmount;
    final byFrom = a.fromMemberId.compareTo(b.fromMemberId);
    if (byFrom != 0) return byFrom;
    return a.toMemberId.compareTo(b.toMemberId);
  });
  return debts;
}
