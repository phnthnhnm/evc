import 'package:riverpod/riverpod.dart';

import '../../../core/er_helpers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/enums/stat.dart';
import '../../../domain/models/echo_set.dart';
import '../../../domain/models/resonator.dart';
import 'echo_sets_provider.dart';

class ResonatorDetailState {
  final double totalER;
  final List<Map<String, double>> echoStats;
  final String selectedTeam;
  final bool loading;
  final EchoSet? lastResult;
  final String? error;
  final String? successMessage;
  final double erOffset;

  const ResonatorDetailState({
    this.totalER = 100.0,
    this.echoStats = const [],
    this.selectedTeam = 'Default',
    this.loading = false,
    this.lastResult,
    this.error,
    this.successMessage,
    this.erOffset = 0.0,
  });

  ResonatorDetailState copyWith({
    double? totalER,
    List<Map<String, double>>? echoStats,
    String? selectedTeam,
    bool? loading,
    EchoSet? lastResult,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    double? erOffset,
  }) {
    return ResonatorDetailState(
      totalER: totalER ?? this.totalER,
      echoStats: echoStats ?? this.echoStats,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      loading: loading ?? this.loading,
      lastResult: lastResult ?? this.lastResult,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      erOffset: erOffset ?? this.erOffset,
    );
  }
}

class ResonatorDetailNotifier extends Notifier<ResonatorDetailState> {
  ResonatorDetailNotifier(this.resonatorId);

  final String resonatorId;

  Resonator get resonator {
    final svc = ref.read(resonatorServiceInterfaceProvider);
    return svc.resonators.firstWhere((r) => r.id == resonatorId);
  }

  static double _round1(double v) => (v * 10).round() / 10.0;

  @override
  ResonatorDetailState build() {
    final echoSetsAsync = ref.watch(echoSetsProvider);
    final savedSet = switch (echoSetsAsync) {
      AsyncData(value: final echoSets) => echoSets[resonatorId],
      _ => null,
    };

    if (savedSet != null) {
      final savedEchoStats = List.generate(5, (i) {
        if (i < savedSet.echoes.length) {
          return Map<String, double>.from(savedSet.echoes[i].stats);
        }
        return <String, double>{};
      });
      final computedER = computeTotalERFromEchoes(savedEchoStats);
      final offset = _round1(savedSet.totalER - computedER);
      return ResonatorDetailState(
        erOffset: offset,
        lastResult: savedSet,
        selectedTeam: savedSet.team ?? 'Default',
        totalER: savedSet.totalER,
        echoStats: savedEchoStats,
      );
    }

    return ResonatorDetailState(
      echoStats: List.generate(5, (_) => <String, double>{}),
    );
  }

  void setTotalER(double value) {
    final computed = computeTotalERFromEchoes(state.echoStats);
    final offset = _round1(value - computed);
    state = state.copyWith(totalER: value, erOffset: offset);
  }

  void setTeam(String team) {
    state = state.copyWith(selectedTeam: team);
  }

  void setStatValue(int echoIndex, Stat stat, double value) {
    final key = '${stat.apiName} ${echoIndex + 1}';
    final newStats = state.echoStats
        .map((m) => Map<String, double>.from(m))
        .toList();
    if (value == 0.0) {
      newStats[echoIndex].remove(key);
    } else {
      newStats[echoIndex][key] = value;
    }

    final computed = computeTotalERFromEchoes(newStats);
    final newTotalER = _round1(computed + state.erOffset);

    state = state.copyWith(echoStats: newStats, totalER: newTotalER);
  }

  Future<void> submit() async {
    final overLimitIndices = <int>[];
    for (int i = 0; i < state.echoStats.length; i++) {
      if (state.echoStats[i].length > 5) overLimitIndices.add(i + 1);
    }
    if (overLimitIndices.isNotEmpty) {
      state = state.copyWith(
        error:
            'Error: Echo${overLimitIndices.length > 1 ? 'es' : ''} '
            '${overLimitIndices.join(', ')} have more than 5 stats. '
            'Please remove extra stats.',
        clearSuccess: true,
      );
      return;
    }

    state = state.copyWith(loading: true, clearError: true, clearSuccess: true);

    final cleanedEchoStats = state.echoStats
        .map(
          (stats) =>
              Map<String, double>.from(stats)..removeWhere((k, v) => v == 0.0),
        )
        .toList();

    final api = ref.read(apiServiceInterfaceProvider);
    final result = await api.submit(
      resonatorName: resonator.name,
      totalER: state.totalER,
      echoStatsList: cleanedEchoStats,
      team: state.selectedTeam,
    );

    switch (result) {
      case Ok(value: final echoSet):
        final storage = ref.read(storageServiceInterfaceProvider);
        await storage.saveEchoSet(resonatorId, echoSet);
        ref.invalidate(echoSetsProvider);
        state = state.copyWith(
          loading: false,
          lastResult: echoSet,
          selectedTeam: echoSet.team ?? state.selectedTeam,
          successMessage: 'Submitted and saved!',
        );
      case Err(message: final msg):
        state = state.copyWith(loading: false, error: msg, clearSuccess: true);
    }
  }

  void revertToDefaults() {
    state = ResonatorDetailState(
      echoStats: List.generate(5, (_) => <String, double>{}),
    );
  }

  Future<void> reset() async {
    state = ResonatorDetailState(
      echoStats: List.generate(5, (_) => <String, double>{}),
      successMessage: 'Resonator data deleted!',
    );
    final storage = ref.read(storageServiceInterfaceProvider);
    await storage.deleteEchoSet(resonatorId);
    ref.invalidate(echoSetsProvider);
  }

  void clearMessages() {
    state = state.copyWith(clearSuccess: true, clearError: true);
  }

  void refresh() {
    ref.invalidateSelf();
  }

  void applyCompareResult(EchoSet echoSet) {
    final newEchoStats = List.generate(5, (i) {
      if (i < echoSet.echoes.length) {
        return Map<String, double>.from(echoSet.echoes[i].stats);
      }
      return <String, double>{};
    });
    final computedER = computeTotalERFromEchoes(newEchoStats);
    final offset = _round1(echoSet.totalER - computedER);
    state = state.copyWith(
      erOffset: offset,
      lastResult: echoSet,
      totalER: echoSet.totalER,
      echoStats: newEchoStats,
    );
  }
}

final resonatorDetailProvider =
    NotifierProvider.family<
      ResonatorDetailNotifier,
      ResonatorDetailState,
      String
    >((id) => ResonatorDetailNotifier(id));
