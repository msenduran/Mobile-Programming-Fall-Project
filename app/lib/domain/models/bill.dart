/// What a bill is for. Stored in the database by its [name], e.g. `'rent'`.
enum BillCategory { rent, electricity, water, gas, internet, other }

/// A rent payment or utility bill of a house.
///
/// The amount is split between members as [BillShare]s. [paidBy] is the
/// member who paid the whole bill to the landlord or the company; until they
/// do, it is null. The other members then owe their share to [paidBy].
class Bill {
  const Bill({
    required this.id,
    required this.houseId,
    required this.title,
    required this.category,
    required this.amountKurus,
    required this.dueDate,
    required this.createdBy,
    required this.createdAt,
    this.paidBy,
  });

  final String id;
  final String houseId;
  final String title;
  final BillCategory category;

  /// Total amount in kuruş: 1250.50 TL is stored as 125050.
  final int amountKurus;
  final DateTime dueDate;
  final String? paidBy;
  final String createdBy;
  final DateTime createdAt;

  bool get isPaid => paidBy != null;

  /// Converts the bill to a row of the `bills` table.
  Map<String, Object?> toMap() => {
    'id': id,
    'house_id': houseId,
    'title': title,
    'category': category.name,
    'amount_kurus': amountKurus,
    'due_date': dueDate.millisecondsSinceEpoch,
    'paid_by': paidBy,
    'created_by': createdBy,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  /// Creates a bill from a row of the `bills` table.
  factory Bill.fromMap(Map<String, Object?> map) => Bill(
    id: map['id'] as String,
    houseId: map['house_id'] as String,
    title: map['title'] as String,
    category: BillCategory.values.byName(map['category'] as String),
    amountKurus: map['amount_kurus'] as int,
    dueDate: DateTime.fromMillisecondsSinceEpoch(
      map['due_date'] as int,
      isUtc: true,
    ),
    paidBy: map['paid_by'] as String?,
    createdBy: map['created_by'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      map['created_at'] as int,
      isUtc: true,
    ),
  );
}
