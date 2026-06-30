import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the [SharedPreferences] instance.
///
/// Must be overridden in [main] before [runApp] with the pre-initialized
/// instance to avoid async-in-constructor issues.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'SharedPreferences must be overridden before runApp()',
  ),
);
