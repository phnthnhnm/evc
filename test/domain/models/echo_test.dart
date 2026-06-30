import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/models/echo.dart';

void main() {
  group('Echo', () {
    test('defaults are correct', () {
      const echo = Echo();
      expect(echo.stats, isEmpty);
      expect(echo.score, 0.0);
      expect(echo.tier, 'Unbuilt');
    });

    test('JSON round-trip preserves data', () {
      final echo = Echo(
        stats: {'Crit Rate(%) 1': 7.5, 'Crit Damage(%) 1': 15.0},
        score: 22.5,
        tier: 'Well Built',
      );

      final json = echo.toJson();
      final restored = Echo.fromJson(json);

      expect(restored.stats, echo.stats);
      expect(restored.score, echo.score);
      expect(restored.tier, echo.tier);
    });

    test('fromJson handles missing fields with defaults', () {
      final echo = Echo.fromJson({});
      expect(echo.stats, isEmpty);
      expect(echo.score, 0.0);
      expect(echo.tier, 'Unbuilt');
    });

    test('copyWith preserves unchanged fields', () {
      final echo = Echo(stats: {'a': 1.0}, score: 10.0, tier: 'Decent');
      final copy = echo.copyWith(score: 20.0);

      expect(copy.stats, {'a': 1.0});
      expect(copy.score, 20.0);
      expect(copy.tier, 'Decent');
    });
  });
}
