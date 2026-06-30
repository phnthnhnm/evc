import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/enums/stat.dart';
import '../../../domain/models/echo.dart';
import '../../../domain/models/echo_set.dart';
import '../../../domain/models/resonator.dart';

class CompareState {
  final Map<String, double> newEchoStats;
  final bool submitted;
  final bool loading;
  final Echo? newEchoResult;
  final EchoSet? newEchoSet;
  final bool showReplaceButton;
  final double enteredTotalER;

  const CompareState({
    this.newEchoStats = const {},
    this.submitted = false,
    this.loading = false,
    this.newEchoResult,
    this.newEchoSet,
    this.showReplaceButton = false,
    this.enteredTotalER = 100.0,
  });

  CompareState copyWith({
    Map<String, double>? newEchoStats,
    bool? submitted,
    bool? loading,
    Echo? newEchoResult,
    EchoSet? newEchoSet,
    bool? showReplaceButton,
    double? enteredTotalER,
  }) {
    return CompareState(
      newEchoStats: newEchoStats ?? this.newEchoStats,
      submitted: submitted ?? this.submitted,
      loading: loading ?? this.loading,
      newEchoResult: newEchoResult ?? this.newEchoResult,
      newEchoSet: newEchoSet ?? this.newEchoSet,
      showReplaceButton: showReplaceButton ?? this.showReplaceButton,
      enteredTotalER: enteredTotalER ?? this.enteredTotalER,
    );
  }
}

class CompareNotifier extends Notifier<CompareState> {
  String? _resonatorId;
  int? _echoIndex;

  String get resonatorId => _resonatorId!;
  int get echoIndex => _echoIndex!;

  static final _digitPattern = RegExp(r' \d+$');

  void init({required String resonatorId, required int echoIndex}) {
    _resonatorId = resonatorId;
    _echoIndex = echoIndex;
    state = const CompareState();
  }

  Resonator get _resonator {
    final svc = ref.read(resonatorServiceInterfaceProvider);
    return svc.resonators.firstWhere((r) => r.id == resonatorId);
  }

  @override
  CompareState build() => const CompareState();

  void setTotalER(double value) {
    state = state.copyWith(enteredTotalER: value);
  }

  void setStatValue(Stat stat, double value) {
    final key = '${stat.apiName} 1';
    final newStats = Map<String, double>.from(state.newEchoStats);
    if (value == 0.0) {
      newStats.remove(key);
    } else {
      newStats[key] = value;
    }
    state = state.copyWith(newEchoStats: newStats);
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
