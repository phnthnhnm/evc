import 'package:riverpod/riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../domain/models/resonator.dart';

final resonatorListProvider = Provider<List<Resonator>>((ref) {
  final service = ref.watch(resonatorServiceInterfaceProvider);
  return service.resonators;
});
