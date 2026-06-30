import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/enums/stat.dart';
import '../../../domain/models/echo_set.dart';
import '../../../domain/models/resonator.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ResonatorDetailState {
  final double totalER;
  final List<Map<String, double>> echoStats;
  final String selectedTeam;
  final bool loading;
  final EchoSet? lastResult;
  final String? error;
  final String? successMessage;

  const ResonatorDetailState({
    this.totalER = 100.0,
    this.echoStats = const [],
    this.selectedTeam = 'Default',
    this.loading = false,
    this.lastResult,
    this.error,
    this.successMessage,
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
  }) {
    return ResonatorDetailState(
      totalER: totalER ?? this.totalER,
      echoStats: echoStats ?? this.echoStats,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      loading: loading ?? this.loading,
      lastResult: lastResult ?? this.lastResult,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier (per-resonator, keyed by ID)
// ---------------------------------------------------------------------------

class ResonatorDetailNotifier extends Notifier<ResonatorDetailState> {
  ResonatorDetailNotifier(this.resonatorId);

  final String resonatorId;

  Resonator get resonator {
    final svc = ref.read(resonatorServiceInterfaceProvider);
    return svc.resonators.firstWhere((r) => r.id == resonatorId);
  }

  @override
  ResonatorDetailState build() {
    _loadSaved();
    return ResonatorDetailState(
      echoStats: List.generate(5, (_) => <String, double>{}),
    );
  }

  Future<void> _loadSaved() async {
    final storage = ref.read(storageServiceInterfaceProvider);
    final result = await storage.loadEchoSet(resonatorId);
    switch (result) {
      case Ok(value: final echoSet?):
        state = state.copyWith(
          lastResult: echoSet,
          selectedTeam: echoSet.team ?? 'Default',
          totalER: echoSet.totalER,
          echoStats: List.generate(
            5,
            (i) {
              if (i < echoSet.echoes.length) {
                return Map<String, double>.from(echoSet.echoes[i].stats);
              }
              return <String, double>{};
            },
          ),
        );
      case _:
        break;
    }
  }

  void setTotalER(double value) {
    state = state.copyWith(totalER: value);
  }

  void setTeam(String team) {
    state = state.copyWith(selectedTeam: team);
  }

  void setStatValue(int echoIndex, Stat stat, double value) {
    final key = '${stat.apiName} ${echoIndex + 1}';
    final newStats =
        state.echoStats.map((m) => Map<String, double>.from(m)).toList();
    if (value == 0.0) {
      newStats[echoIndex].remove(key);
    } else {
      newStats[echoIndex][key] = value;
    }
    state = state.copyWith(echoStats: newStats);
  }

  Future<void> submit() async {
    final overLimitIndices = <int>[];
    for (int i = 0; i < state.echoStats.length; i++) {
      if (state.echoStats[i].length > 5) overLimitIndices.add(i + 1);
    }
    if (overLimitIndices.isNotEmpty) {
      state = state.copyWith(
        error: 'Error: Echo${overLimitIndices.length > 1 ? 'es' : ''} '
            '${overLimitIndices.join(', ')} have more than 5 stats. '
            'Please remove extra stats.',
      );
      return;
    }

    state = state.copyWith(loading: true, error: null, clearError: true);

    final cleanedEchoStats = state.echoStats
        .map((stats) =>
            Map<String, double>.from(stats)..removeWhere((k, v) => v == 0.0))
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
        state = state.copyWith(
          loading: false,
          lastResult: echoSet,
          selectedTeam: echoSet.team ?? state.selectedTeam,
          successMessage: 'Submitted and saved!',
        );
      case Err(message: final msg):
        state = state.copyWith(loading: false, error: msg);
    }
  }

  Future<void> reset() async {
    state = ResonatorDetailState(
      echoStats: List.generate(5, (_) => <String, double>{}),
      successMessage: 'Resonator data deleted!',
    );
    final storage = ref.read(storageServiceInterfaceProvider);
    await storage.deleteEchoSet(resonatorId);
  }

  void applyCompareResult(EchoSet echoSet) {
    state = state.copyWith(
      lastResult: echoSet,
      totalER: echoSet.totalER,
      echoStats: List.generate(
        5,
        (i) {
          if (i < echoSet.echoes.length) {
            return Map<String, double>.from(echoSet.echoes[i].stats);
          }
          return <String, double>{};
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider family
// ---------------------------------------------------------------------------

final resonatorDetailProvider =
    NotifierProvider.family<ResonatorDetailNotifier, ResonatorDetailState, String>(
  (id) => ResonatorDetailNotifier(id),
);
