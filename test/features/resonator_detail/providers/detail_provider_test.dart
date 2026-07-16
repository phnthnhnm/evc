import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/result.dart';
import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/features/resonator_detail/providers/detail_provider.dart';
import 'package:evc/core/providers/service_providers.dart';
import 'package:evc/features/resonator_detail/providers/echo_sets_provider.dart';

import '../../../test_helpers.dart';

const _resonatorId = 'test-id';
final _testResonator = mockResonator(id: _resonatorId, name: 'Test');

/// Holds a test setup with a container and all mock services.
final class _Setup {
  final ProviderContainer container;
  final MockResonatorService resonatorSvc;
  final MockApiService apiSvc;
  final MockStorageService storageSvc;

  _Setup({
    required this.container,
    required this.resonatorSvc,
    required this.apiSvc,
    required this.storageSvc,
  });
}

/// Creates a [ProviderContainer] set up for detail provider tests.
_Setup _createContainer({Map<String, EchoSet> echoSets = const {}}) {
  final resonatorSvc = MockResonatorService();
  final apiSvc = MockApiService();
  final storageSvc = MockStorageService();

  when(() => resonatorSvc.resonators).thenReturn([_testResonator]);

  // Build the container with ALL overrides at creation time.
  final container = ProviderContainer(
    overrides: [
      resonatorServiceInterfaceProvider.overrideWith((ref) => resonatorSvc),
      apiServiceInterfaceProvider.overrideWith((ref) => apiSvc),
      storageServiceInterfaceProvider.overrideWith((ref) => storageSvc),
      echoSetsProvider.overrideWith((ref) async => echoSets),
    ],
  );

  addTearDown(container.dispose);

  return _Setup(
    container: container,
    resonatorSvc: resonatorSvc,
    apiSvc: apiSvc,
    storageSvc: storageSvc,
  );
}

ResonatorDetailNotifier _notifier(ProviderContainer container) {
  return container.read(resonatorDetailProvider(_resonatorId).notifier);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_testResonator);
    registerFallbackValue(mockEcho());
    registerFallbackValue(mockEchoSet());
    registerFallbackValue('');
  });

  group('build() — fresh state', () {
    test('no saved data: defaults with empty echo stats', () {
      final setup = _createContainer();

      final notifier = _notifier(setup.container);
      final state = notifier.state;

      expect(state.totalER, 100.0);
      expect(state.echoStats, hasLength(5));
      expect(state.echoStats.every((m) => m.isEmpty), isTrue);
      expect(state.erOffset, 0.0);
      expect(state.lastResult, isNull);
      expect(state.selectedTeam, 'Default');
    });
  });

  group('build() — hydration', () {
    test('saved EchoSet hydrates state', () async {
      final savedEchoes = List.generate(5, (i) {
        return mockEcho(
          stats: i == 2 ? {'${Stat.erPercent.apiName} ${i + 1}': 10.8} : {},
          score: 3.0 + i,
          tier: 'S',
        );
      });
      final savedSet = mockEchoSet(
        echoes: savedEchoes,
        overallScore: 42.0,
        overallTier: 'S',
        totalER: 130.0,
        team: 'Team A',
      );

      final setup = _createContainer(echoSets: {_resonatorId: savedSet});

      // Wait for the FutureProvider to resolve before building the notifier.
      await setup.container.read(echoSetsProvider.future);

      final notifier = _notifier(setup.container);
      final state = notifier.state;

      // Hydrated from saved data.
      expect(state.totalER, 130.0);
      expect(state.lastResult, isNotNull);
      expect(state.lastResult!.team, 'Team A');
      expect(state.selectedTeam, 'Team A');
      // erOffset = savedTotalER - computedFromEchoes
      // computed = 100 + 10.8 = 110.8, offset = 130.0 - 110.8 = 19.2
      expect(state.erOffset, 19.2);
      // echo index 2 should have the ER stat.
      expect(state.echoStats[2]['${Stat.erPercent.apiName} 3'], 10.8);
    });
  });

  group('setStatValue', () {
    test('sets a non-zero stat on the correct echo with correct key', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setStatValue(0, Stat.critRate, 6.3);

      expect(notifier.state.echoStats[0]['${Stat.critRate.apiName} 1'], 6.3);
    });

    test('removes key when value is 0.0', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setStatValue(0, Stat.critRate, 6.3);
      notifier.setStatValue(0, Stat.critRate, 0.0);

      expect(
        notifier.state.echoStats[0],
        isNot(contains('${Stat.critRate.apiName} 1')),
      );
    });

    test('multiple stats on same echo accumulate', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setStatValue(0, Stat.critRate, 6.3);
      notifier.setStatValue(0, Stat.critDamage, 12.6);

      expect(notifier.state.echoStats[0]['${Stat.critRate.apiName} 1'], 6.3);
      expect(notifier.state.echoStats[0]['${Stat.critDamage.apiName} 1'], 12.6);
    });

    test('non-ER stat preserves erOffset', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      // Set initial offset by setting totalER manually.
      notifier.setTotalER(120.0); // offset = 120 - 100 = 20
      notifier.setStatValue(1, Stat.critRate, 6.3);

      // totalER should still be 120 (computed = 100, offset = 20)
      expect(notifier.state.totalER, 120.0);
      expect(notifier.state.erOffset, 20.0);
    });

    test('ER stat recalculates totalER while preserving erOffset', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setTotalER(120.0); // offset = 20
      notifier.setStatValue(0, Stat.erPercent, 10.8);

      // computed = 100 + 10.8 = 110.8, totalER = 110.8 + 20 = 130.8
      expect(notifier.state.totalER, 130.8);
      expect(notifier.state.erOffset, 20.0);
    });
  });

  group('setTotalER', () {
    test('updates totalER and recalculates erOffset', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setTotalER(125.0);

      // computed = 100 (no ER stats), offset = 125 - 100 = 25
      expect(notifier.state.totalER, 125.0);
      expect(notifier.state.erOffset, 25.0);
    });
  });

  group('submit — validation', () {
    test('rejects when one echo has >5 stats, does not call API', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      // Add 6 stats to echo 0.
      final statsToSet = [
        Stat.critRate,
        Stat.critDamage,
        Stat.atkPercent,
        Stat.hpPercent,
        Stat.flatAtk,
        Stat.flatHp,
      ];
      for (final stat in statsToSet) {
        notifier.setStatValue(0, stat, 6.0);
      }

      notifier.submit();

      // Should have an error about echoes with >5 stats.
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error!, contains('Echo 1'));
      expect(notifier.state.error!, contains('more than 5 stats'));
      // API should not have been called.
      verifyNever(
        () => setup.apiSvc.submit(
          resonatorName: any(named: 'resonatorName'),
          totalER: any(named: 'totalER'),
          echoStatsList: any(named: 'echoStatsList'),
          team: any(named: 'team'),
        ),
      );
    });

    test('rejects multiple over-limit echoes with plural message', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      final statsToSet = [
        Stat.critRate,
        Stat.critDamage,
        Stat.atkPercent,
        Stat.hpPercent,
        Stat.flatAtk,
        Stat.flatHp,
      ];
      for (final stat in statsToSet) {
        notifier.setStatValue(0, stat, 6.0);
        notifier.setStatValue(2, stat, 6.0);
      }

      notifier.submit();

      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error!, contains('Echoes'));
      expect(notifier.state.error!, contains('1, 3'));
      verifyNever(
        () => setup.apiSvc.submit(
          resonatorName: any(named: 'resonatorName'),
          totalER: any(named: 'totalER'),
          echoStatsList: any(named: 'echoStatsList'),
          team: any(named: 'team'),
        ),
      );
    });
  });

  group('submit — success', () {
    test('calls API, saves result, invalidates echoSets, sets state', () async {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setStatValue(0, Stat.critRate, 6.3);

      final returnedEchoSet = mockEchoSet(
        echoes: [
          mockEcho(stats: {'${Stat.critRate.apiName} 1': 6.3}),
        ],
        totalER: 100.0,
        team: 'Team A',
      );
      when(
        () => setup.apiSvc.submit(
          resonatorName: any(named: 'resonatorName'),
          totalER: any(named: 'totalER'),
          echoStatsList: any(named: 'echoStatsList'),
          team: any(named: 'team'),
        ),
      ).thenAnswer((_) async => Ok(returnedEchoSet));

      when(
        () => setup.storageSvc.saveEchoSet(any(), any()),
      ).thenAnswer((_) async => const Ok(null));

      await notifier.submit();

      // Verify API was called.
      verify(
        () => setup.apiSvc.submit(
          resonatorName: 'Test',
          totalER: 100.0,
          echoStatsList: any(named: 'echoStatsList'),
          team: 'Default',
        ),
      ).called(1);

      // Verify storage saved.
      verify(() => setup.storageSvc.saveEchoSet(_resonatorId, any())).called(1);

      // State should reflect success.
      expect(notifier.state.loading, isFalse);
      expect(notifier.state.lastResult, isNotNull);
      expect(notifier.state.successMessage, contains('Submitted'));
      expect(notifier.state.error, isNull);
      expect(notifier.state.selectedTeam, 'Team A');
    });
  });

  group('submit — failure', () {
    test('sets error, does not save', () async {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      when(
        () => setup.apiSvc.submit(
          resonatorName: any(named: 'resonatorName'),
          totalER: any(named: 'totalER'),
          echoStatsList: any(named: 'echoStatsList'),
          team: any(named: 'team'),
        ),
      ).thenAnswer((_) async => const Err('Server error'));

      await notifier.submit();

      expect(notifier.state.loading, isFalse);
      expect(notifier.state.error, 'Server error');
      expect(notifier.state.lastResult, isNull);

      // saveEchoSet should NOT be called.
      verifyNever(() => setup.storageSvc.saveEchoSet(any(), any()));
    });
  });

  group('revertToDefaults', () {
    test('resets all state to defaults', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.setStatValue(0, Stat.critRate, 6.3);
      notifier.setTotalER(120.0);
      notifier.revertToDefaults();

      expect(notifier.state.totalER, 100.0);
      expect(notifier.state.echoStats.every((m) => m.isEmpty), isTrue);
      expect(notifier.state.erOffset, 0.0);
      expect(notifier.state.lastResult, isNull);
    });
  });
}
