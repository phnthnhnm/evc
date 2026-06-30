import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  group('Resonator', () {
    test('effectiveTeams always includes Default as first', () {
      final resonator = mockResonator(teams: ['Team A', 'Team B']);
      expect(resonator.effectiveTeams[0], 'Default');
      expect(resonator.effectiveTeams, contains('Team A'));
      expect(resonator.effectiveTeams, contains('Team B'));
    });

    test('effectiveTeams filters duplicate Default from teams', () {
      final resonator = mockResonator(teams: ['Default', 'Team A']);
      final teams = resonator.effectiveTeams;
      expect(teams.where((t) => t == 'Default').length, 1);
    });

    test('effectiveTeams is just [Default] when teams is empty', () {
      final resonator = mockResonator(teams: []);
      expect(resonator.effectiveTeams, ['Default']);
    });
  });
}
