import '../../domain/models/echo_set.dart';
import '../../core/result.dart';

/// Contract for submitting echo builds to the EVC backend.
abstract interface class IApiService {
  /// Submits echo stats and returns the scored result.
  ///
  /// [resonatorName] — the character name exactly as the backend expects it.
  /// [totalER] — total Energy Regen for the build.
  /// [echoStatsList] — 5-element list of per-echo stat maps.
  /// [team] — optional team name.
  Future<Result<EchoSet>> submit({
    required String resonatorName,
    required double totalER,
    required List<Map<String, double>> echoStatsList,
    String? team,
  });

  /// Builds the JSON payload without sending it (used by tests / debugging).
  Map<String, dynamic> buildPayload({
    required String resonatorName,
    required double totalER,
    required List<Map<String, double>> echoStatsList,
    String? team,
  });
}
