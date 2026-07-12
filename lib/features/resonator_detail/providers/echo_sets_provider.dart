import 'dart:async';

import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/result.dart';
import '../../../domain/models/echo_set.dart';

final echoSetsProvider = FutureProvider<Map<String, EchoSet>>((ref) async {
  ref.keepAlive();

  final storage = ref.watch(storageServiceInterfaceProvider);
  final resonatorService = ref.watch(resonatorServiceInterfaceProvider);

  final ids = resonatorService.resonators.map((r) => r.id).toList();

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
