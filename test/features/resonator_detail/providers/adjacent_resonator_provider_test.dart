import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/features/resonator_detail/providers/adjacent_resonator_provider.dart';
import 'package:evc/features/resonator_list/providers/filter_sort_provider.dart';

import '../../../test_helpers.dart';

/// Overrides [filteredResonatorsProvider] and returns a container ready
/// to read [adjacentResonatorsProvider].
ProviderContainer _createContainer(List<String> filteredIds) {
  final container = ProviderContainer(
    overrides: [
      filteredResonatorsProvider.overrideWith(
        (ref) =>
            filteredIds.map((id) => mockResonator(id: id, name: id)).toList(),
      ),
    ],
  );

  addTearDown(container.dispose);
  return container;
}

void main() {
  group('adjacentResonatorsProvider', () {
    test('first resonator: no previous, has next', () {
      final container = _createContainer(['a', 'b', 'c']);
      final adjacent = container.read(adjacentResonatorsProvider('a'));

      expect(adjacent.previousId, isNull);
      expect(adjacent.nextId, 'b');
    });

    test('middle resonator: has both previous and next', () {
      final container = _createContainer(['a', 'b', 'c']);
      final adjacent = container.read(adjacentResonatorsProvider('b'));

      expect(adjacent.previousId, 'a');
      expect(adjacent.nextId, 'c');
    });

    test('last resonator: has previous, no next', () {
      final container = _createContainer(['a', 'b', 'c']);
      final adjacent = container.read(adjacentResonatorsProvider('c'));

      expect(adjacent.previousId, 'b');
      expect(adjacent.nextId, isNull);
    });

    test('single resonator: no previous or next', () {
      final container = _createContainer(['only']);
      final adjacent = container.read(adjacentResonatorsProvider('only'));

      expect(adjacent.previousId, isNull);
      expect(adjacent.nextId, isNull);
    });

    test('resonator not in filtered list: both null', () {
      final container = _createContainer(['a', 'b', 'c']);
      final adjacent = container.read(adjacentResonatorsProvider('x'));

      expect(adjacent.previousId, isNull);
      expect(adjacent.nextId, isNull);
    });

    test('empty filtered list: both null', () {
      final container = _createContainer([]);
      final adjacent = container.read(adjacentResonatorsProvider('a'));

      expect(adjacent.previousId, isNull);
      expect(adjacent.nextId, isNull);
    });

    test('respects current filter/sort order', () {
      // The order in the filtered list is what matters, not resonator IDs.
      final container = _createContainer(['z', 'a', 'm']);
      final adjacent = container.read(adjacentResonatorsProvider('a'));

      // 'a' is at index 1, so previous='z', next='m'
      expect(adjacent.previousId, 'z');
      expect(adjacent.nextId, 'm');
    });
  });
}
