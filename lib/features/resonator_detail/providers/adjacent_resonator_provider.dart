import 'package:riverpod/riverpod.dart';

import '../../resonator_list/providers/filter_sort_provider.dart';

class AdjacentResonators {
  final String? previousId;
  final String? nextId;

  const AdjacentResonators({this.previousId, this.nextId});
}

final adjacentResonatorsProvider = Provider.family<AdjacentResonators, String>((
  ref,
  resonatorId,
) {
  final filtered = ref.watch(filteredResonatorsProvider);
  if (filtered.isEmpty) return const AdjacentResonators();

  final index = filtered.indexWhere((r) => r.id == resonatorId);
  if (index == -1) return const AdjacentResonators();

  return AdjacentResonators(
    previousId: index > 0 ? filtered[index - 1].id : null,
    nextId: index < filtered.length - 1 ? filtered[index + 1].id : null,
  );
});
