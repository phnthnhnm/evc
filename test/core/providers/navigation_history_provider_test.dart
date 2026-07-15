import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/providers/navigation_history_provider.dart';

/// Creates a fresh [NavigationHistoryNotifier] for testing.
NavigationHistoryNotifier _createNotifier() {
  final container = ProviderContainer();
  // Container is needed to satisfy the Notifier contract, even though
  // NavigationHistoryNotifier has no dependencies.
  addTearDown(container.dispose);
  return container.read(navigationHistoryProvider.notifier);
}

void main() {
  group('NavigationHistoryNotifier', () {
    test('initial state: empty history, index -1, cannot navigate', () {
      final notifier = _createNotifier();
      final state = notifier.state;

      expect(state.history, isEmpty);
      expect(state.currentIndex, -1);
      expect(state.canGoBack, isFalse);
      expect(state.canGoForward, isFalse);
    });

    test('recordRoute adds first route', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');

      expect(notifier.state.history, ['/a']);
      expect(notifier.state.currentIndex, 0);
      expect(notifier.state.canGoBack, isFalse);
    });

    test('recordRoute appends to history', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');

      expect(notifier.state.history, ['/a', '/b']);
      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.canGoBack, isTrue);
      expect(notifier.state.canGoForward, isFalse);
    });

    test('duplicate recordRoute at current path is a no-op', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');
      notifier.recordRoute('/b'); // same as current

      expect(notifier.state.history, ['/a', '/b']);
      expect(notifier.state.currentIndex, 1);
    });

    test('truncates forward branch when navigating after going back', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');
      notifier.recordRoute('/c'); // ['/a', '/b', '/c'], index 2

      notifier.prepareBack(); // back to '/b', index 1
      notifier.onNavigationComplete();

      notifier.recordRoute('/d'); // new branch — should truncate '/c'

      expect(notifier.state.history, ['/a', '/b', '/d']);
      expect(notifier.state.currentIndex, 2);
    });

    test('prepareBack returns previous route and updates index', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');

      final path = notifier.prepareBack();
      expect(path, '/a');
      expect(notifier.state.currentIndex, 0);
    });

    test('prepareBack at start returns null', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');

      final path = notifier.prepareBack();
      expect(path, isNull);
      expect(notifier.state.currentIndex, 0);
    });

    test('prepareForward returns next route and updates index', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');
      notifier.prepareBack(); // index 0
      notifier.onNavigationComplete();

      final path = notifier.prepareForward();
      expect(path, '/b');
      expect(notifier.state.currentIndex, 1);
    });

    test('prepareForward at end returns null', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');

      final path = notifier.prepareForward();
      expect(path, isNull);
    });

    test('internalNavigation flag: recordRoute ignored after prepareBack before onNavigationComplete', () {
      final notifier = _createNotifier();
      notifier.recordRoute('/a');
      notifier.recordRoute('/b');

      notifier.prepareBack(); // _internalNavigation = true
      // Simulate a route change notification firing before onNavigationComplete
      notifier.recordRoute('/a'); // should be ignored

      expect(notifier.state.history, ['/a', '/b']);

      notifier.onNavigationComplete();
      notifier.recordRoute('/x'); // should work now

      // After going back to /a and then navigating to /x, the forward branch
      // (/b) should be truncated.
      expect(notifier.state.history, ['/a', '/x']);
    });
  });
}
