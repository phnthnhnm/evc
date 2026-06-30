import 'package:riverpod/riverpod.dart';

import '../../domain/models/echo_set.dart';
import '../../domain/models/resonator.dart';

/// Holds the active compare session data so it doesn't need to be serialized
/// in route parameters.
class CompareContext {
  final Resonator resonator;
  final EchoSet lastResult;
  final int echoIndex;

  const CompareContext({
    required this.resonator,
    required this.lastResult,
    required this.echoIndex,
  });
}

final compareContextProvider =
    NotifierProvider<CompareContextNotifier, CompareContext?>(
  CompareContextNotifier.new,
);

class CompareContextNotifier extends Notifier<CompareContext?> {
  @override
  CompareContext? build() => null;

  void set(CompareContext ctx) => state = ctx;
  void clear() => state = null;
}
