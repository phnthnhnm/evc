import 'package:flutter_test/flutter_test.dart';

import 'package:evc/core/diff_helpers.dart';

void main() {
  group('computeChangedStatKeys', () {
    test('identical non-zero maps return empty set', () {
      final current = {'Crit Rate(%) 1': 6.3, 'Crit Damage(%) 1': 12.6};
      final baseline = {'Crit Rate(%) 1': 6.3, 'Crit Damage(%) 1': 12.6};

      expect(
        computeChangedStatKeys(current: current, baseline: baseline),
        isEmpty,
      );
    });

    test('non-zero value differs — key returned', () {
      final current = {'Crit Rate(%) 1': 7.5};
      final baseline = {'Crit Rate(%) 1': 6.3};

      expect(
        computeChangedStatKeys(current: current, baseline: baseline),
        {'Crit Rate(%) 1'},
      );
    });

    test('stat added (non-zero in current, absent in baseline) — key returned', () {
      final current = {'Crit Rate(%) 1': 6.3};
      final baseline = <String, double>{};

      expect(
        computeChangedStatKeys(current: current, baseline: baseline),
        {'Crit Rate(%) 1'},
      );
    });

    test('stat removed (non-zero in baseline, absent in current) — key returned', () {
      final current = <String, double>{};
      final baseline = {'Crit Rate(%) 1': 6.3};

      expect(
        computeChangedStatKeys(current: current, baseline: baseline),
        {'Crit Rate(%) 1'},
      );
    });

    test('mixed: some changed, identical, added, removed', () {
      final current = {
        'Crit Rate(%) 1': 7.5, // changed from 6.3
        'ATK(%) 1': 8.6, // unchanged
        'HP(%) 1': 10.0, // newly added
      };
      final baseline = {
        'Crit Rate(%) 1': 6.3,
        'ATK(%) 1': 8.6,
        'DEF(%) 1': 9.4, // removed (not in current)
      };

      final result = computeChangedStatKeys(current: current, baseline: baseline);

      expect(result, {'Crit Rate(%) 1', 'HP(%) 1', 'DEF(%) 1'});
      expect(result.length, 3);
    });
  });
}
