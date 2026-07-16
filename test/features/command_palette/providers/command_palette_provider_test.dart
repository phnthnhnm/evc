import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/features/command_palette/providers/command_palette_provider.dart';
import 'package:evc/infrastructure/services/storage_service_impl.dart';

/// Creates a [ProviderContainer] with a [StorageServiceImpl] pointed at a
/// temp directory so recent-ID persistence can be tested.
Future<ProviderContainer> _createContainer() async {
  final storage = StorageServiceImpl(
    customDirectory:
        '${Directory.systemTemp.path}/evc_test_${DateTime.now().millisecondsSinceEpoch}',
  );
  final container = ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('CommandPaletteState', () {
    test('default values', () {
      const state = CommandPaletteState();

      expect(state.isOpen, isFalse);
      expect(state.searchQuery, '');
      expect(state.recentResonatorIds, isEmpty);
      expect(state.highlightedIndex, 0);
    });

    test('copyWith overrides individual fields', () {
      const state = CommandPaletteState();
      final copy = state.copyWith(
        isOpen: true,
        searchQuery: 'shore',
        highlightedIndex: 3,
      );

      expect(copy.isOpen, isTrue);
      expect(copy.searchQuery, 'shore');
      expect(copy.highlightedIndex, 3);
    });

    test('copyWith preserves unchanged fields', () {
      const state = CommandPaletteState(recentResonatorIds: ['a', 'b']);
      final copy = state.copyWith(isOpen: true);

      expect(copy.recentResonatorIds, ['a', 'b']);
      expect(copy.searchQuery, '');
    });

    test('equality: same values are ==', () {
      const a = CommandPaletteState(
        isOpen: true,
        searchQuery: 'test',
        recentResonatorIds: ['x', 'y'],
        highlightedIndex: 2,
      );
      const b = CommandPaletteState(
        isOpen: true,
        searchQuery: 'test',
        recentResonatorIds: ['x', 'y'],
        highlightedIndex: 2,
      );

      expect(a, equals(b));
    });

    test('equality: different values are not ==', () {
      const a = CommandPaletteState(isOpen: true);
      const b = CommandPaletteState(isOpen: false);

      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = CommandPaletteState(recentResonatorIds: ['a', 'b']);
      const b = CommandPaletteState(recentResonatorIds: ['a', 'b']);

      expect(a.hashCode, b.hashCode);
    });
  });

  group('CommandPaletteNotifier', () {
    test('initial state: closed, empty search, empty recent', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      expect(notifier.state.isOpen, isFalse);
      expect(notifier.state.searchQuery, '');
      expect(notifier.state.highlightedIndex, 0);
    });

    test('initial state loads recent IDs from storage', () async {
      // Pre-populate the storage with some recent IDs.
      final storage = StorageServiceImpl(
        customDirectory:
            '${Directory.systemTemp.path}/evc_test_preload_${DateTime.now().millisecondsSinceEpoch}',
      );
      await storage.saveRecentResonatorIds(['a', 'b', 'c']);
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      // Give the FutureProvider time to resolve and the notifier to rebuild.
      await Future.delayed(const Duration(milliseconds: 100));
      final state = container.read(commandPaletteProvider);
      expect(state.recentResonatorIds, ['a', 'b', 'c']);
    });

    test('open sets isOpen=true and resets search + highlight', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.setSearch('test');
      notifier.moveHighlight(1, 10);
      notifier.open();

      expect(notifier.state.isOpen, isTrue);
      expect(notifier.state.searchQuery, '');
      expect(notifier.state.highlightedIndex, 0);
    });

    test('close sets isOpen=false', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.open();
      notifier.close();

      expect(notifier.state.isOpen, isFalse);
    });

    test('toggle opens when closed and closes when open', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      expect(notifier.isOpen, isFalse);
      notifier.toggle();
      expect(notifier.isOpen, isTrue);
      notifier.toggle();
      expect(notifier.isOpen, isFalse);
    });

    test('setSearch updates query and resets highlight', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.moveHighlight(1, 10);
      notifier.setSearch('shore');

      expect(notifier.state.searchQuery, 'shore');
      expect(notifier.state.highlightedIndex, 0);
    });

    test('moveHighlight wraps around at top', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.moveHighlight(-1, 5);
      expect(notifier.state.highlightedIndex, 4);
    });

    test('moveHighlight wraps around at bottom', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.moveHighlight(1, 5); // 1
      notifier.moveHighlight(1, 5); // 2
      notifier.moveHighlight(1, 5); // 3
      notifier.moveHighlight(1, 5); // 4
      expect(notifier.state.highlightedIndex, 4);
      notifier.moveHighlight(1, 5); // wraps to 0
      expect(notifier.state.highlightedIndex, 0);
    });

    test('moveHighlight with empty results sets index to 0', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.moveHighlight(1, 0);
      expect(notifier.state.highlightedIndex, 0);
    });

    test('selectResonator prepends to recent list', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.selectResonator('c');
      notifier.selectResonator('b');
      notifier.selectResonator('a');

      expect(notifier.state.recentResonatorIds, ['a', 'b', 'c']);
    });

    test('selectResonator deduplicates existing ID', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.selectResonator('a');
      notifier.selectResonator('b');
      notifier.selectResonator('c');
      notifier.selectResonator('b');

      expect(notifier.state.recentResonatorIds, ['b', 'c', 'a']);
    });

    test('selectResonator closes the palette', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.open();
      notifier.selectResonator('a');

      expect(notifier.state.isOpen, isFalse);
    });

    test('selectResonator caps at maxRecent (20)', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      for (var i = 0; i < 25; i++) {
        notifier.selectResonator('$i');
      }

      expect(notifier.state.recentResonatorIds.length, 20);
      expect(notifier.state.recentResonatorIds.first, '24');
      expect(notifier.state.recentResonatorIds.last, '5');
    });

    test('selectResonator persists to storage service', () async {
      final storage = StorageServiceImpl(
        customDirectory:
            '${Directory.systemTemp.path}/evc_test_persist_${DateTime.now().millisecondsSinceEpoch}',
      );
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(commandPaletteProvider.notifier);
      notifier.selectResonator('x');
      notifier.selectResonator('y');

      // Wait for async save to complete.
      await Future.delayed(const Duration(milliseconds: 100));

      final stored = await storage.loadRecentResonatorIds();
      expect(stored, ['y', 'x']);
    });

    test('recordNavigation adds to recent without closing palette', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      notifier.recordNavigation('a');
      expect(notifier.state.recentResonatorIds, ['a']);
      expect(notifier.state.isOpen, isFalse); // still closed

      notifier.open();
      notifier.recordNavigation('b');
      expect(notifier.state.recentResonatorIds, ['b', 'a']);
      expect(notifier.state.isOpen, isTrue); // still open
    });

    test('isOpen getter reflects state', () async {
      final container = await _createContainer();
      final notifier = container.read(commandPaletteProvider.notifier);

      expect(notifier.isOpen, isFalse);
      notifier.open();
      expect(notifier.isOpen, isTrue);
      notifier.close();
      expect(notifier.isOpen, isFalse);
    });
  });
}
