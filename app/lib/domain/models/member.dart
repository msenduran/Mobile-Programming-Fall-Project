/// A student living in a house.
///
/// In phase 1 all members live on one phone and we switch between them in
/// settings. In phase 2 a member is linked to a Firebase user.
class Member {
  const Member({
    required this.id,
    required this.houseId,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String houseId;
  final String name;
  final DateTime createdAt;

  /// Converts the member to a row of the `members` table.
  Map<String, Object?> toMap() => {
    'id': id,
    'house_id': houseId,
    'name': name,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  /// Creates a member from a row of the `members` table.
  factory Member.fromMap(Map<String, Object?> map) => Member(
    id: map['id'] as String,
    houseId: map['house_id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      map['created_at'] as int,
      isUtc: true,
    ),
  );
}
