import 'package:riverpod/riverpod.dart';

import '../../../core/providers/shared_preferences_provider.dart';

/// Controls the "show score on card" toggle.
///
/// Persisted via [SharedPreferences].
final showScoreOnCardProvider = NotifierProvider<ShowScoreOnCard, bool>(
  ShowScoreOnCard.new,
);

class ShowScoreOnCard extends Notifier<bool> {
  static const _key = 'showScoreOnCard';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, value);
  }
}
