import '../../../domain/models/house.dart';
import '../../../domain/models/member.dart';

/// Houses and their members.
///
/// Screens and ViewModels use this abstract class. The SQLite version is
/// [HouseRepositorySqlite]; a Firebase version will be added in phase 2.
abstract class HouseRepository {
  /// Creates a house with a new invite code and makes [memberName] its first
  /// member. Returns the house and that member.
  Future<(House, Member)> createHouse(String houseName, String memberName);

  /// Adds [memberName] to the house with [inviteCode].
  ///
  /// The code is not case sensitive and spaces are ignored. Throws
  /// [InviteCodeNotFoundException] if no house has this code.
  Future<Member> joinHouse(String inviteCode, String memberName);

  /// Returns the house with [houseId], or `null` if it doesn't exist.
  Future<House?> getHouse(String houseId);

  /// Returns the members of the house, oldest first.
  Future<List<Member>> getMembers(String houseId);
}

/// Thrown by [HouseRepository.joinHouse] when the invite code is wrong.
class InviteCodeNotFoundException implements Exception {
  const InviteCodeNotFoundException(this.inviteCode);

  final String inviteCode;

  @override
  String toString() => 'No house with invite code "$inviteCode"';
}
