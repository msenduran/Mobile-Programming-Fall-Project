/// A shared student house. Other students join it with [inviteCode].
class House {
  const House({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;

  /// Converts the house to a row of the `houses` table.
  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'invite_code': inviteCode,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  /// Creates a house from a row of the `houses` table.
  factory House.fromMap(Map<String, Object?> map) => House(
    id: map['id'] as String,
    name: map['name'] as String,
    inviteCode: map['invite_code'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      map['created_at'] as int,
      isUtc: true,
    ),
  );
}
