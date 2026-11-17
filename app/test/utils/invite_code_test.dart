import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/utils/invite_code.dart';

void main() {
  group('newInviteCode', () {
    test('is 6 characters from the allowed alphabet', () {
      for (var i = 0; i < 200; i++) {
        final code = newInviteCode();
        expect(code.length, inviteCodeLength);
        for (final char in code.split('')) {
          expect(inviteCodeAlphabet, contains(char));
        }
      }
    });

    test('never uses look-alike characters', () {
      for (final char in ['0', 'O', '1', 'I']) {
        expect(inviteCodeAlphabet, isNot(contains(char)));
      }
    });

    test('is the same for the same random seed', () {
      expect(newInviteCode(Random(42)), newInviteCode(Random(42)));
    });
  });

  group('normalizeInviteCode', () {
    test('makes the code uppercase and removes spaces', () {
      expect(normalizeInviteCode(' k7q 2xm '), 'K7Q2XM');
    });
  });
}
