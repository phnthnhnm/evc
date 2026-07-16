import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'package:evc/core/result.dart';
import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/features/compare/providers/compare_provider.dart';

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

_Setup _createContainer() {
  final resonatorSvc = MockResonatorService();
  final apiSvc = MockApiService();
  final storageSvc = MockStorageService();

  when(() => resonatorSvc.resonators).thenReturn([_testResonator]);

  final container = createTestContainer(
    resonatorService: resonatorSvc,
    apiService: apiSvc,
    storageService: storageSvc,
  );

  addTearDown(container.dispose);

  return _Setup(
    container: container,
    resonatorSvc: resonatorSvc,
    apiSvc: apiSvc,
    storageSvc: storageSvc,
  );
}

CompareNotifier _notifier(ProviderContainer container) {
  return container.read(compareProvider.notifier);
}

/// Creates a 5-echo [EchoSet] where echo at [echoIndex] has the given stats.
EchoSet _makeLastResult({
  int echoIndex = 2,
  Map<String, double> echoStats = const {},
  double totalER = 130.0,
  String team = 'Team A',
}) {
  return mockEchoSet(
    echoes: List.generate(5, (i) {
      if (i == echoIndex) return mockEcho(stats: echoStats);
      return mockEcho(stats: {'Crit Rate(%) ${i + 1}': 6.0 + i});
    }),
    totalER: totalER,
    team: team,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_testResonator);
    registerFallbackValue(mockEcho());
    registerFallbackValue(mockEchoSet());
    registerFallbackValue('');
  });

  group('init', () {
    test('baseline stats remapped from actual slot to slot-1 format', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      final lastResult = _makeLastResult(
        echoIndex: 2,
        echoStats: {
          '${Stat.critRate.apiName} 3': 8.1,
          '${Stat.atkPercent.apiName} 3': 7.0,
        },
        totalER: 130.0,
      );

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 2,
        previousTotalER: 130.0,
        oldEchoER: 0.0,
        lastResult: lastResult,
      );

      // Baseline keys should use slot-1 suffix.
      final baseline = notifier.state.baselineStats!;
      expect(baseline, contains('${Stat.critRate.apiName} 1'));
      expect(baseline, contains('${Stat.atkPercent.apiName} 1'));
      expect(baseline['${Stat.critRate.apiName} 1'], 8.1);
      // Original slot-3 keys should not be present.
      expect(baseline, isNot(contains('${Stat.critRate.apiName} 3')));
    });

    test(
      '_adjustedBaseER = previousTotalER - oldEchoER, enteredTotalER matches',
      () {
        final setup = _createContainer();
        final notifier = _notifier(setup.container);

        final lastResult = _makeLastResult(
          echoIndex: 0,
          echoStats: {'${Stat.erPercent.apiName} 1': 10.8},
          totalER: 120.0,
        );

        notifier.init(
          resonatorId: _resonatorId,
          echoIndex: 0,
          previousTotalER: 120.0,
          oldEchoER: 10.8,
          lastResult: lastResult,
        );

        // _adjustedBaseER = 120.0 - 10.8 = 109.2 (base 100 + other 4 echoes)
        // enteredTotalER should be 109.2
        expect(notifier.state.enteredTotalER, 109.2);
      },
    );

    test('second init call with different params overwrites state', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      final lastResult1 = _makeLastResult(
        echoIndex: 0,
        echoStats: {'${Stat.critRate.apiName} 1': 6.3},
        totalER: 110.0,
      );

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 0,
        previousTotalER: 110.0,
        oldEchoER: 0.0,
        lastResult: lastResult1,
      );

      expect(notifier.state.baselineStats!['${Stat.critRate.apiName} 1'], 6.3);

      // Second init with different echo index and stats.
      final lastResult2 = _makeLastResult(
        echoIndex: 3,
        echoStats: {'${Stat.hpPercent.apiName} 4': 10.0},
        totalER: 105.0,
      );

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 3,
        previousTotalER: 105.0,
        oldEchoER: 5.0,
        lastResult: lastResult2,
      );

      // Baseline should now have the new echo's stats.
      expect(
        notifier.state.baselineStats,
        contains('${Stat.hpPercent.apiName} 1'),
      );
      expect(notifier.state.enteredTotalER, 100.0); // 105 - 5 = 100
    });
  });

  group('setStatValue', () {
    test('adds stat with slot-1 key, removes when 0.0', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 0,
        previousTotalER: 100.0,
        oldEchoER: 0.0,
        lastResult: _makeLastResult(),
      );

      notifier.setStatValue(Stat.critRate, 6.3);
      expect(notifier.state.newEchoStats['${Stat.critRate.apiName} 1'], 6.3);

      notifier.setStatValue(Stat.critRate, 0.0);
      expect(
        notifier.state.newEchoStats,
        isNot(contains('${Stat.critRate.apiName} 1')),
      );
    });

    test('ER stat recalculates totalER preserving offset', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 0,
        previousTotalER: 120.0,
        oldEchoER: 0.0,
        lastResult: _makeLastResult(),
      );

      // _adjustedBaseER = 120.0 - 0.0 = 120.0
      // Set a manual offset via totalER.
      notifier.setTotalER(130.0); // offset = 130 - (120 + 0) = 10

      // Add ER stat.
      notifier.setStatValue(Stat.erPercent, 10.8);
      // computed = _adjustedBaseER + extractERStat(newStats, 1) = 120.0 + 10.8 = 130.8
      // totalER = 130.8 + 10.0 = 140.8
      expect(notifier.state.enteredTotalER, 140.8);
    });
  });

  group('setTotalER', () {
    test('manual totalER entry recalculates erOffset', () {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 0,
        previousTotalER: 115.0,
        oldEchoER: 0.0,
        lastResult: _makeLastResult(),
      );

      // _adjustedBaseER = 115.0, enteredTotalER = 115.0
      notifier.setTotalER(120.0);
      // offset = 120 - (115 + 0) = 5
      expect(notifier.state.enteredTotalER, 120.0);
      expect(notifier.state.erOffset, 5.0);
    });
  });

  group('submit', () {
    test(
      'reconstructs full echo set and remaps slot-1 keys to actual slot',
      () async {
        final setup = _createContainer();
        final notifier = _notifier(setup.container);

        // Replace echo at slot 3 (index 2).
        final lastResult = _makeLastResult(
          echoIndex: 2,
          echoStats: {'${Stat.critRate.apiName} 3': 8.1},
          totalER: 130.0,
        );

        notifier.init(
          resonatorId: _resonatorId,
          echoIndex: 2,
          previousTotalER: 130.0,
          oldEchoER: 0.0,
          lastResult: lastResult,
        );

        // Set new stats in slot-1 format.
        notifier.setStatValue(Stat.critRate, 9.5);
        notifier.setStatValue(Stat.critDamage, 15.0);

        final returnedEchoSet = mockEchoSet(
          echoes: List.generate(5, (i) => mockEcho(score: 3.0 + i)),
          totalER: 130.0,
        );

        when(
          () => setup.apiSvc.submit(
            resonatorName: any(named: 'resonatorName'),
            totalER: any(named: 'totalER'),
            echoStatsList: any(named: 'echoStatsList'),
            team: any(named: 'team'),
          ),
        ).thenAnswer((_) async => Ok(returnedEchoSet));

        await notifier.submit(lastResult);

        // Verify API was called with correct resonator name and team.
        verify(
          () => setup.apiSvc.submit(
            resonatorName: 'Test',
            totalER: any(named: 'totalER'),
            echoStatsList: any(named: 'echoStatsList'),
            team: 'Team A',
          ),
        ).called(1);
      },
    );

    test(
      'on success: sets newEchoResult, newEchoSet, showReplaceButton',
      () async {
        final setup = _createContainer();
        final notifier = _notifier(setup.container);

        final lastResult = _makeLastResult();

        notifier.init(
          resonatorId: _resonatorId,
          echoIndex: 0,
          previousTotalER: 100.0,
          oldEchoER: 0.0,
          lastResult: lastResult,
        );

        final returnedEcho = mockEcho(
          stats: {'Crit Rate(%) 1': 9.5},
          tier: 'SS',
        );
        final returnedEchoSet = mockEchoSet(
          echoes: [returnedEcho, ...List.generate(4, (_) => mockEcho())],
          overallScore: 45.0,
          overallTier: 'SS',
        );

        when(
          () => setup.apiSvc.submit(
            resonatorName: any(named: 'resonatorName'),
            totalER: any(named: 'totalER'),
            echoStatsList: any(named: 'echoStatsList'),
            team: any(named: 'team'),
          ),
        ).thenAnswer((_) async => Ok(returnedEchoSet));

        await notifier.submit(lastResult);

        expect(notifier.state.loading, isFalse);
        expect(notifier.state.newEchoResult, isNotNull);
        expect(notifier.state.newEchoResult!.tier, 'SS');
        expect(notifier.state.newEchoSet, isNotNull);
        expect(notifier.state.showReplaceButton, isTrue);
      },
    );

    test('on error: sets Error echo, showReplaceButton false', () async {
      final setup = _createContainer();
      final notifier = _notifier(setup.container);

      final lastResult = _makeLastResult();

      notifier.init(
        resonatorId: _resonatorId,
        echoIndex: 0,
        previousTotalER: 100.0,
        oldEchoER: 0.0,
        lastResult: lastResult,
      );

      when(
        () => setup.apiSvc.submit(
          resonatorName: any(named: 'resonatorName'),
          totalER: any(named: 'totalER'),
          echoStatsList: any(named: 'echoStatsList'),
          team: any(named: 'team'),
        ),
      ).thenAnswer((_) async => const Err('API down'));

      await notifier.submit(lastResult);

      expect(notifier.state.loading, isFalse);
      expect(notifier.state.newEchoResult, isNotNull);
      expect(notifier.state.newEchoResult!.tier, 'Error');
      expect(notifier.state.newEchoSet, isNull);
      expect(notifier.state.showReplaceButton, isFalse);
    });
  });

  group('replaceOldEchoWithNew', () {
    test(
      'replaces echo at correct index, saves via storage, returns updated set',
      () async {
        final setup = _createContainer();
        final notifier = _notifier(setup.container);

        final oldEcho = mockEcho(stats: {'Crit Rate(%) 1': 6.3}, tier: 'A');
        final lastResult = mockEchoSet(
          echoes: [oldEcho, ...List.generate(4, (_) => mockEcho())],
          overallScore: 35.0,
          overallTier: 'A',
          totalER: 120.0,
          team: 'Team A',
        );

        notifier.init(
          resonatorId: _resonatorId,
          echoIndex: 0,
          previousTotalER: 120.0,
          oldEchoER: 0.0,
          lastResult: lastResult,
        );

        // Simulate a successful submit result.
        final newEcho = mockEcho(stats: {'Crit Rate(%) 1': 9.5}, tier: 'SS');
        final newEchoSet = mockEchoSet(
          echoes: [newEcho, ...List.generate(4, (_) => mockEcho())],
          overallScore: 45.0,
          overallTier: 'SS',
        );

        // Manually set the submit result state.
        when(
          () => setup.apiSvc.submit(
            resonatorName: any(named: 'resonatorName'),
            totalER: any(named: 'totalER'),
            echoStatsList: any(named: 'echoStatsList'),
            team: any(named: 'team'),
          ),
        ).thenAnswer((_) async => Ok(newEchoSet));

        await notifier.submit(lastResult);

        when(
          () => setup.storageSvc.saveEchoSet(any(), any()),
        ).thenAnswer((_) async => const Ok(null));

        notifier.setTotalER(125.0);
        final result = await notifier.replaceOldEchoWithNew(lastResult);

        // Verify storage saved with the correct resonator ID.
        verify(
          () => setup.storageSvc.saveEchoSet(_resonatorId, any()),
        ).called(1);

        // The returned EchoSet should have the new echo at index 0.
        expect(result.echoes[0].tier, 'SS');
        expect(result.overallScore, 45.0);
        expect(result.overallTier, 'SS');
        // team and totalER should come from the entered values.
        expect(result.team, 'Team A');
        expect(result.totalER, 125.0);
      },
    );
  });
}
