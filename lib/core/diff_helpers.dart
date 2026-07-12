/// Returns the set of stat keys that differ between [current] and [baseline].
Set<String> computeChangedStatKeys({
  required Map<String, double> current,
  required Map<String, double> baseline,
}) {
  final changed = <String>{};

  for (final entry in current.entries) {
    if (entry.value != 0.0) {
      final baselineValue = baseline[entry.key] ?? 0.0;
      if (entry.value != baselineValue) {
        changed.add(entry.key);
      }
    }
  }

  for (final entry in baseline.entries) {
    if (entry.value != 0.0) {
      final currentValue = current[entry.key] ?? 0.0;
      if (currentValue == 0.0) {
        changed.add(entry.key);
      }
    }
  }

  return changed;
}
