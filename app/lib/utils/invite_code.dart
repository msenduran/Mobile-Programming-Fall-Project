import 'dart:math';

/// Characters used in invite codes: uppercase letters and digits without the
/// look-alikes 0/O and 1/I, so a code read aloud or typed by hand is not
/// mistaken for another.
const inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Length of an invite code, e.g. `K7Q2XM`.
const inviteCodeLength = 6;

/// Creates a random invite code like `K7Q2XM`.
///
/// [random] is only given in tests, to get the same code every time.
String newInviteCode([Random? random]) {
  final rng = random ?? Random.secure();
  return String.fromCharCodes([
    for (var i = 0; i < inviteCodeLength; i++)
      inviteCodeAlphabet.codeUnitAt(rng.nextInt(inviteCodeAlphabet.length)),
  ]);
}

/// Cleans up a code the user typed: removes spaces and makes it uppercase,
/// so ` k7q2xm ` matches `K7Q2XM`.
String normalizeInviteCode(String input) =>
    input.replaceAll(RegExp(r'\s'), '').toUpperCase();
