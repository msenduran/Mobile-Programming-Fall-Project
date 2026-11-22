/// Money that one member owes to another, calculated from bills and shares.
///
/// Debts are not stored in the database; they are calculated again every time
/// with `calculateDebts` so they always match the bills.
class Debt {
  const Debt({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountKurus,
  });

  /// The member who has to pay.
  final String fromMemberId;

  /// The member who will get the money.
  final String toMemberId;

  /// Always greater than zero, in kuruş.
  final int amountKurus;

  @override
  bool operator ==(Object other) =>
      other is Debt &&
      other.fromMemberId == fromMemberId &&
      other.toMemberId == toMemberId &&
      other.amountKurus == amountKurus;

  @override
  int get hashCode => Object.hash(fromMemberId, toMemberId, amountKurus);

  @override
  String toString() => 'Debt($fromMemberId -> $toMemberId: $amountKurus)';
}
