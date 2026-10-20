/// The part of a [Bill] that one member has to pay.
///
/// [paidAt] is set when the member has given their share to the person who
/// paid the bill. While it is null, the member still owes this amount.
class BillShare {
  const BillShare({
    required this.billId,
    required this.memberId,
    required this.amountKurus,
    this.paidAt,
  });

  final String billId;
  final String memberId;

  /// This member's part of the bill in kuruş.
  final int amountKurus;
  final DateTime? paidAt;

  bool get isPaid => paidAt != null;

  /// Converts the share to a row of the `bill_shares` table.
  Map<String, Object?> toMap() => {
    'bill_id': billId,
    'member_id': memberId,
    'amount_kurus': amountKurus,
    'paid_at': paidAt?.millisecondsSinceEpoch,
  };

  /// Creates a share from a row of the `bill_shares` table.
  factory BillShare.fromMap(Map<String, Object?> map) {
    final paidAt = map['paid_at'] as int?;
    return BillShare(
      billId: map['bill_id'] as String,
      memberId: map['member_id'] as String,
      amountKurus: map['amount_kurus'] as int,
      paidAt: paidAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(paidAt, isUtc: true),
    );
  }
}
