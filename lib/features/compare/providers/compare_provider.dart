import 'package:riverpod/riverpod.dart';

import '../../../core/er_helpers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/enums/stat.dart';
import '../../../domain/models/echo.dart';
import '../../../domain/models/echo_set.dart';
import '../../../domain/models/resonator.dart';

class CompareState {
  final Map<String, double> newEchoStats;
  final Map<String, double>? baselineStats;
  final bool submitted;
  final bool loading;
  final Echo? newEchoResult;
  final EchoSet? newEchoSet;
  final bool showReplaceButton;
  final double enteredTotalER;
  final double erOffset;

  const CompareState({
    this.newEchoStats = const {},
    this.baselineStats,
    this.submitted = false,
    this.loading = false,
    this.newEchoResult,
    this.newEchoSet,
    this.showReplaceButton = false,
    this.enteredTotalER = 100.0,
    this.erOffset = 0.0,
  });

  /// The set of stat keys (slot-1 format) that the user has actively set
  /// to a non-zero value that differs from the original echo's stats.
  Set<String> get changedStats {
    if (baselineStats == null) return const {};
    final changed = <String>{};
    for (final entry in newEchoStats.entries) {
      if (entry.value != 0.0) {
        final baselineValue = baselineStats![entry.key] ?? 0.0;
        if (entry.value != baselineValue) {
          changed.add(entry.key);
        }
      }
    }
    return changed;
  }

  CompareState copyWith({
    Map<String, double>? newEchoStats,
    Map<String, double>? baselineStats,
    bool? submitted,
    bool? loading,
    Echo? newEchoResult,
    EchoSet? newEchoSet,
    bool? showReplaceButton,
    double? enteredTotalER,
    double? erOffset,
  }) {
    return CompareState(
      newEchoStats: newEchoStats ?? this.newEchoStats,
      baselineStats: baselineStats ?? this.baselineStats,
      submitted: submitted ?? this.submitted,
      loading: loading ?? this.loading,
      newEchoResult: newEchoResult ?? this.newEchoResult,
      newEchoSet: newEchoSet ?? this.newEchoSet,
      showReplaceButton: showReplaceButton ?? this.showReplaceButton,
      enteredTotalER: enteredTotalER ?? this.enteredTotalER,
      erOffset: erOffset ?? this.erOffset,
    );
  }
}

class CompareNotifier extends Notifier<CompareState> {
  String? _resonatorId;
  int? _echoIndex;

  double? _adjustedBaseER;

  String get resonatorId => _resonatorId!;
  int get echoIndex => _echoIndex!;

  static final _digitPattern = RegExp(r' \d+$');
  static double _round1(double v) => (v * 10).round() / 10.0;

  void init({
    required String resonatorId,
    required int echoIndex,
    required double previousTotalER,
    required double oldEchoER,
    required EchoSet lastResult,
  }) {
    _resonatorId = resonatorId;
    _echoIndex = echoIndex;
    _adjustedBaseER = previousTotalER - oldEchoER;

    // Remap the original echo's stat keys from the actual slot number to
    // slot-1 format so the diff against newEchoStats is key-compatible.
    final baseline = <String, double>{};
    if (echoIndex < lastResult.echoes.length) {
      for (final entry in lastResult.echoes[echoIndex].stats.entries) {
        final remappedKey = entry.key.replaceAll(_digitPattern, ' 1');
        baseline[remappedKey] = entry.value;
      }
    }

    state = CompareState(
      enteredTotalER: _adjustedBaseER!,
      baselineStats: baseline,
    );
  }

  Resonator get _resonator {
    final svc = ref.read(resonatorServiceInterfaceProvider);
    return svc.resonators.firstWhere((r) => r.id == resonatorId);
  }

  @override
  CompareState build() => const CompareState();

  void setTotalER(double value) {
    final computed =
        (_adjustedBaseER ?? 0) + extractERStat(state.newEchoStats, 1);
    final offset = _round1(value - computed);
    state = state.copyWith(enteredTotalER: value, erOffset: offset);
  }

  void setStatValue(Stat stat, double value) {
    final key = '${stat.apiName} 1';
    final newStats = Map<String, double>.from(state.newEchoStats);
    if (value == 0.0) {
      newStats.remove(key);
    } else {
      newStats[key] = value;
    }

    final computed = (_adjustedBaseER ?? 0) + extractERStat(newStats, 1);
    final newTotalER = _round1(computed + state.erOffset);

    state = state.copyWith(newEchoStats: newStats, enteredTotalER: newTotalER);
  }

  Future<void> submit(EchoSet lastResult) async {
    state = state.copyWith(submitted: true, loading: true);

    final echoStatsList = List.generate(5, (i) {
      if (i < lastResult.echoes.length) {
        return Map<String, double>.from(lastResult.echoes[i].stats);
      }
      return <String, double>{};
    });

    final remappedStats = <String, double>{};
    state.newEchoStats.forEach((key, value) {
      final statName = key.replaceAll(_digitPattern, '');
      remappedStats['$statName ${echoIndex + 1}'] = value;
    });
    echoStatsList[echoIndex] = remappedStats;

    final api = ref.read(apiServiceInterfaceProvider);
    final result = await api.submit(
      resonatorName: _resonator.name,
      totalER: state.enteredTotalER,
      echoStatsList: echoStatsList,
      team: lastResult.team,
    );

    switch (result) {
      case Ok(value: final echoSet):
        final echo = echoSet.echoes[echoIndex];
        state = state.copyWith(
          loading: false,
          newEchoResult: echo,
          newEchoSet: echoSet,
          showReplaceButton: true,
        );
      case Err():
        state = state.copyWith(
          loading: false,
          newEchoResult: Echo(stats: remappedStats, score: 0.0, tier: 'Error'),
          newEchoSet: null,
          showReplaceButton: false,
        );
    }
  }

  Future<EchoSet> replaceOldEchoWithNew(EchoSet lastResult) async {
    final updatedEchoes = List<Echo>.from(lastResult.echoes);
    if (echoIndex < updatedEchoes.length && state.newEchoResult != null) {
      updatedEchoes[echoIndex] = state.newEchoResult!;
    }
    final updatedEchoSet = EchoSet(
      echoes: updatedEchoes,
      overallScore: state.newEchoSet?.overallScore ?? 0.0,
      overallTier: state.newEchoSet?.overallTier ?? 'Unbuilt',
      team: lastResult.team,
      totalER: state.enteredTotalER,
    );

    final storage = ref.read(storageServiceInterfaceProvider);
    await storage.saveEchoSet(resonatorId, updatedEchoSet);
    return updatedEchoSet;
  }
}

final compareProvider = NotifierProvider<CompareNotifier, CompareState>(
  CompareNotifier.new,
);
