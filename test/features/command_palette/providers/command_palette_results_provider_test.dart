import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/domain/models/resonator.dart';
import 'package:evc/features/command_palette/providers/command_palette_provider.dart';
import 'package:evc/features/command_palette/providers/command_palette_results_provider.dart';
import 'package:evc/infrastructure/services/storage_service_impl.dart';

import '../../../test_helpers.dart';

/// Creates a [ProviderContainer] with mock resonators and a temp
/// [StorageServiceImpl] for recent-ID persistence.
Future<ProviderContainer> _createContainer({
  required List<Resonator> resonators,
  List<String> recentIds = const [],
}) async {
  final storage = StorageServiceImpl(
    customDirectory:
        '${Directory.systemTemp.path}/evc_results_test_${DateTime.now().millisecondsSinceEpoch}',
  );
  if (recentIds.isNotEmpty) {
    await storage.saveRecentResonatorIds(recentIds);
  }

  final mockResonatorService = MockResonatorService();
  when(() => mockResonatorService.resonators).thenReturn(resonators);

  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      resonatorServiceInterfaceProvider.overrideWith(
        (ref) => mockResonatorService,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late List<Resonator> testResonators;

  setUp(() {
    testResonators = [
      mockResonator(id: 'aalto-main-dps', name: 'Aalto (Main-DPS)'),
      mockResonator(id: 'shorekeeper', name: 'The Shorekeeper'),
      mockResonator(id: 'changli', name: 'Changli'),
      mockResonator(id: 'carlotta-main-dps', name: 'Carlotta (Main-DPS)'),
      mockResonator(id: 'rover-spectro', name: 'Rover (Spectro)'),
    ];
  });

  group('commandPaletteSearchResultsProvider', () {
    test('returns all resonators when query is empty', () async {
      final container = await _createContainer(resonators: testResonators);

      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results.length, 5);
    });

    test('filters by case-insensitive substring match', () async {
      final container = await _createContainer(resonators: testResonators);

      container.read(commandPaletteProvider.notifier).setSearch('shore');
      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results.length, 1);
      expect(results.first.id, 'shorekeeper');
    });

    test('matches partial substring without requiring exact match', () async {
      final container = await _createContainer(resonators: testResonators);

      container.read(commandPaletteProvider.notifier).setSearch('alto');
      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results.length, 1);
      expect(results.first.id, 'aalto-main-dps');
    });

    test('query with no matches returns empty list', () async {
      final container = await _createContainer(resonators: testResonators);

      container.read(commandPaletteProvider.notifier).setSearch('zzz');
      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results, isEmpty);
    });

    test('case-insensitive matching', () async {
      final container = await _createContainer(resonators: testResonators);

      container.read(commandPaletteProvider.notifier).setSearch('SHORE');
      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results.length, 1);
      expect(results.first.id, 'shorekeeper');
    });

    test('matches "the" for names starting with The', () async {
      final container = await _createContainer(resonators: testResonators);

      container.read(commandPaletteProvider.notifier).setSearch('the');
      final results = container.read(commandPaletteSearchResultsProvider);

      expect(results.length, 1);
      expect(results.first.id, 'shorekeeper');
    });
  });

  group('commandPaletteRecentResonatorsProvider', () {
    test('returns empty list when no recent IDs', () async {
      final container = await _createContainer(resonators: testResonators);

      final results = container.read(commandPaletteRecentResonatorsProvider);

      expect(results, isEmpty);
    });

    test('resolves recent IDs to Resonator objects in order', () async {
      final container = await _createContainer(
        resonators: testResonators,
        recentIds: ['changli', 'shorekeeper', 'aalto-main-dps'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final results = container.read(commandPaletteRecentResonatorsProvider);

      expect(results.length, 3);
      expect(results[0].id, 'changli');
      expect(results[1].id, 'shorekeeper');
      expect(results[2].id, 'aalto-main-dps');
    });

    test('skips IDs that no longer exist', () async {
      final container = await _createContainer(
        resonators: testResonators,
        recentIds: ['changli', 'deleted-resonator', 'shorekeeper'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final results = container.read(commandPaletteRecentResonatorsProvider);

      expect(results.length, 2);
      expect(results[0].id, 'changli');
      expect(results[1].id, 'shorekeeper');
    });

    test('returns empty when all IDs are non-existent', () async {
      final container = await _createContainer(
        resonators: testResonators,
        recentIds: ['ghost-1', 'ghost-2'],
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final results = container.read(commandPaletteRecentResonatorsProvider);

      expect(results, isEmpty);
    });
  });
}
