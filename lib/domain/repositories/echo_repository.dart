import '../../core/interfaces/api_service.dart';
import '../../core/interfaces/storage_service.dart';
import '../../core/result.dart';
import '../models/echo_set.dart';

/// Coordinates API submission and local storage persistence.
final class EchoRepository {
  const EchoRepository({
    required this.apiService,
    required this.storageService,
  });

  final IApiService apiService;
  final IStorageService storageService;

  /// Submits echo stats to the backend, and on success saves the result
  /// locally for the given resonator.
  Future<Result<EchoSet>> submitAndSave({
    required String resonatorId,
    required String resonatorName,
    required double totalER,
    required List<Map<String, double>> echoStatsList,
    String? team,
  }) async {
    final result = await apiService.submit(
      resonatorName: resonatorName,
      totalER: totalER,
      echoStatsList: echoStatsList,
      team: team,
    );

    switch (result) {
      case Ok(value: final echoSet):
        final saveResult = await storageService.saveEchoSet(
          resonatorId,
          echoSet,
        );
        switch (saveResult) {
          case Ok():
            return Ok(echoSet);
          case Err(message: final m, cause: final c):
            return Err(m, cause: c);
        }
      case Err():
        return result;
    }
  }

  /// Loads a previously saved echo set for a resonator.
  Future<Result<EchoSet?>> load(String resonatorId) {
    return storageService.loadEchoSet(resonatorId);
  }

  /// Deletes a saved echo set for a resonator.
  Future<Result<void>> delete(String resonatorId) {
    return storageService.deleteEchoSet(resonatorId);
  }
}
