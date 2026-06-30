import 'package:riverpod/riverpod.dart';

import '../../core/interfaces/api_service.dart';
import '../../core/interfaces/resonator_service.dart';
import '../../core/interfaces/storage_service.dart';
import '../../domain/repositories/echo_repository.dart';
import '../../infrastructure/services/api_service_impl.dart';
import '../../infrastructure/services/resonator_service_impl.dart';
import '../../infrastructure/services/storage_service_impl.dart';

// ---------------------------------------------------------------------------
// Concrete implementations
// ---------------------------------------------------------------------------

final resonatorServiceProvider = Provider<ResonatorServiceImpl>(
  (ref) => ResonatorServiceImpl(),
);

final storageServiceProvider = Provider<StorageServiceImpl>(
  (ref) => StorageServiceImpl(),
);

final apiServiceProvider = Provider<ApiServiceImpl>(
  (ref) => const ApiServiceImpl(),
);

// ---------------------------------------------------------------------------
// Interface-typed providers (for test overrides)
// ---------------------------------------------------------------------------

final resonatorServiceInterfaceProvider = Provider<IResonatorService>(
  (ref) => ref.watch(resonatorServiceProvider),
);

final storageServiceInterfaceProvider = Provider<IStorageService>(
  (ref) => ref.watch(storageServiceProvider),
);

final apiServiceInterfaceProvider = Provider<IApiService>(
  (ref) => ref.watch(apiServiceProvider),
);

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final echoRepositoryProvider = Provider<EchoRepository>(
  (ref) => EchoRepository(
    apiService: ref.watch(apiServiceInterfaceProvider),
    storageService: ref.watch(storageServiceInterfaceProvider),
  ),
);
