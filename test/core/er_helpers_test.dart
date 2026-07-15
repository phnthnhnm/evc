import 'package:flutter_test/flutter_test.dart';

import 'package:evc/core/er_helpers.dart';
import 'package:evc/domain/enums/stat.dart';

void main() {
  final erKey = Stat.erPercent.apiName; // 'ER(%)'

  group('extractERStat', () {
    test('returns value when ER key exists for the slot', () {
      final stats = <String, double>{'$erKey 1': 10.8, '$erKey 3': 5.2};

      expect(extractERStat(stats, 1), 10.8);
      expect(extractERStat(stats, 3), 5.2);
    });

    test('returns 0.0 when ER key is absent', () {
      final stats = <String, double>{'Crit Rate(%) 2': 6.3};

      expect(extractERStat(stats, 2), 0.0);
    });

    test('distinguishes different slot numbers', () {
      final stats = <String, double>{'$erKey 1': 10.0, '$erKey 2': 20.0};

      expect(extractERStat(stats, 1), 10.0);
      expect(extractERStat(stats, 2), 20.0);
    });
  });

  group('computeTotalERFromEchoes', () {
    test('sums all 5 echo ER values plus base 100, rounds to 1 dp', () {
      final echoes = [
        {'$erKey 1': 10.8},
        {'$erKey 2': 0.0},
        {'$erKey 3': 5.4},
        {'$erKey 4': 8.1},
        {'$erKey 5': 6.6},
      ];

      // 100 + 10.8 + 0.0 + 5.4 + 8.1 + 6.6 = 130.9
      expect(computeTotalERFromEchoes(echoes), 130.9);
    });

    test('returns 100.0 when no echo has ER stat', () {
      final echoes = List.generate(5, (_) => <String, double>{});

      expect(computeTotalERFromEchoes(echoes), 100.0);
    });

    test('treats missing ER as 0.0', () {
      final echoes = [
        {'$erKey 1': 12.3},
        <String, double>{}, // no ER key at all
        <String, double>{},
        <String, double>{},
        <String, double>{},
      ];

      // 100 + 12.3 = 112.3
      expect(computeTotalERFromEchoes(echoes), 112.3);
    });

    test('rounds to one decimal place', () {
      final echoes = [
        {'$erKey 1': 10.05},
        <String, double>{},
        <String, double>{},
        <String, double>{},
        <String, double>{},
      ];

      // 100 + 10.05 = 110.05 → rounds to 110.1
      expect(computeTotalERFromEchoes(echoes), 110.1);
    });

    test('empty list returns 100.0', () {
      expect(computeTotalERFromEchoes([]), 100.0);
    });
  });
}
