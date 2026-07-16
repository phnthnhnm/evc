import 'package:riverpod/riverpod.dart';

import '../../../domain/models/resonator.dart';
import '../../resonator_detail/providers/echo_sets_provider.dart';
import '../../resonator_list/providers/resonator_list_provider.dart';
import 'command_palette_provider.dart';

/// Resolves [CommandPaletteState.recentResonatorIds] into [Resonator] objects,
/// preserving order and skipping IDs that no longer exist.
///
/// Each resonator is enriched with its saved echo set so the UI can display
/// tier and score.
final commandPaletteRecentResonatorsProvider = Provider<List<Resonator>>((ref) {
  final state = ref.watch(commandPaletteProvider);
  final allResonators = ref.watch(resonatorListProvider);
  final echoSets = ref.watch(echoSetsProvider).value ?? {};

  if (state.recentResonatorIds.isEmpty) return [];

  final lookup = <String, Resonator>{};
  for (final r in allResonators) {
    lookup[r.id] = r;
  }

  return state.recentResonatorIds
      .map((id) => lookup[id])
      .whereType<Resonator>()
      .map((r) => r.copyWith(savedEchoSet: echoSets[r.id]))
      .toList();
});

/// Filters resonators by [CommandPaletteState.searchQuery] using
/// case-insensitive substring matching.
///
/// When the query is empty, returns all resonators (for the "All" section).
///
/// Each resonator is enriched with its saved echo set so the UI can display
/// tier and score.
final commandPaletteSearchResultsProvider = Provider<List<Resonator>>((ref) {
  final state = ref.watch(commandPaletteProvider);
  final allResonators = ref.watch(resonatorListProvider);
  final echoSets = ref.watch(echoSetsProvider).value ?? {};

  final query = state.searchQuery.toLowerCase().trim();
  if (query.isEmpty) {
    return allResonators
        .map((r) => r.copyWith(savedEchoSet: echoSets[r.id]))
        .toList();
  }

  return allResonators
      .where((r) => r.name.toLowerCase().contains(query))
      .map((r) => r.copyWith(savedEchoSet: echoSets[r.id]))
      .toList();
});
