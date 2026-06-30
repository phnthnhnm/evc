import '../../domain/models/echo_set.dart';
import '../../domain/models/resonator.dart';
import '../../core/result.dart';

/// Contract for persisting and loading echo set data.
abstract interface class IStorageService {
  /// Set the resonator definitions needed for stat sanitization on load.
  void setResonators(List<Resonator> resonators);

  /// Load the saved echo set for a given resonator, or `null`.
  Future<Result<EchoSet?>> loadEchoSet(String resonatorId);

  /// Save (create or update) the echo set for a resonator.
  Future<Result<void>> saveEchoSet(String resonatorId, EchoSet echoSet);

  /// Delete the echo set for a resonator.
  Future<Result<void>> deleteEchoSet(String resonatorId);

  /// Export all data (echo sets + settings) as a JSON string.
  Future<Result<String>> backupAllData();

  /// Import data from a previously exported JSON string.
  Future<Result<void>> restoreAllData(String inputJson);

  /// Delete all data and settings.
  Future<Result<void>> resetAllData();
}
