import '../../domain/models/resonator.dart';
import '../../core/result.dart';

/// Contract for loading and accessing resonator definitions.
abstract interface class IResonatorService {
  /// The loaded list of all resonators. Must call [load] first.
  List<Resonator> get resonators;

  /// Whether [load] has completed.
  bool get isLoaded;

  /// Load resonator definitions from the bundled JSON asset.
  Future<Result<void>> load();
}
