import 'dart:async';

import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/models/echo_set.dart';

/// Loads all saved echo sets concurrently.
///
/// Returns a [Map] of resonator ID → [EchoSet].
final echoSetsProvider = FutureProvider<Map<String, EchoSet>>((ref) async {
  final storage = ref.watch(storageServiceInterfaceProvider);
  final resonatorService = ref.watch(resonatorServiceInterfaceProvider);

  final ids = resonatorService.resonators.map((r) => r.id).toList();

  // Load concurrently instead of sequentially.
  final results = await Future.wait(
    ids.map((id) async {
      final result = await storage.loadEchoSet(id);
      return switch (result) {
        Ok(value: final echoSet?) => MapEntry(id, echoSet),
        _ => null,
      };
    }),
  );

  return {
    for (final entry in results.whereType<MapEntry<String, EchoSet>>())
      entry.key: entry.value,
  };
});
