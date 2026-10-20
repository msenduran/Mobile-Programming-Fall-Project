import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/utils/money.dart';

void main() {
  group('splitEvenly', () {
    test('divides an even amount equally', () {
      expect(splitEvenly(900000, 3), [300000, 300000, 300000]);
    });

    test('gives leftover kuruş to the first shares', () {
      expect(splitEvenly(10000, 3), [3334, 3333, 3333]);
      expect(splitEvenly(10001, 4), [2501, 2500, 2500, 2500]);
    });

    test('shares always add up to the total', () {
      for (final count in [1, 2, 3, 4, 5, 6, 7]) {
        final shares = splitEvenly(123457, count);
        expect(shares.length, count);
        expect(shares.reduce((a, b) => a + b), 123457);
      }
    });

    test('rejects zero members', () {
      expect(() => splitEvenly(1000, 0), throwsArgumentError);
    });
  });
}
