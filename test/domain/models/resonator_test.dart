import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  group('Resonator', () {
    test('effectiveTeams returns data as-is when it includes Default', () {
      final resonator = mockResonator(teams: ['Default', 'Team A', 'Team B']);
      expect(resonator.effectiveTeams, ['Default', 'Team A', 'Team B']);
    });

    test('effectiveTeams does not inject Default when data has none', () {
      final resonator = mockResonator(teams: ['Team A', 'Team B']);
      expect(resonator.effectiveTeams, ['Team A', 'Team B']);
      expect(resonator.effectiveTeams, isNot(contains('Default')));
    });

    test('effectiveTeams is just [Default] when teams is empty', () {
      final resonator = mockResonator(teams: []);
      expect(resonator.effectiveTeams, ['Default']);
    });

    test('resolveTeam returns the team when it is a valid option', () {
      final resonator = mockResonator(teams: ['Default', 'Team A']);
      expect(resonator.resolveTeam('Team A'), 'Team A');
    });

    test('resolveTeam returns the first team for null', () {
      final resonator = mockResonator(teams: ['Default', 'Team A']);
      expect(resonator.resolveTeam(null), 'Default');
    });

    test('resolveTeam falls back to first team for a stale team name', () {
      final resonator = mockResonator(teams: ['Team A', 'Team B']);
      expect(resonator.resolveTeam('Default'), 'Team A');
    });

    test('apiTeamName returns the mapped raw name when present', () {
      final resonator = mockResonator(
        teams: ['Default', 'Low-Reqs'],
        teamApiNames: {'Low-Reqs': 'Low-Reqs: '},
      );
      expect(resonator.apiTeamName('Low-Reqs'), 'Low-Reqs: ');
      expect(resonator.apiTeamName('Default'), 'Default');
    });

    test('apiTeamName returns the team unchanged when no mapping exists', () {
      final resonator = mockResonator(teams: ['Default', 'Team A']);
      expect(resonator.apiTeamName('Team A'), 'Team A');
    });
  });

  group('erTargetForTeam', () {
    test('returns {min, max} when teamER has valid entry with both keys', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120.0, 'max': 140.0},
      });

      final result = resonator.erTargetForTeam('Team A');
      expect(result, {'min': 120.0, 'max': 140.0});
    });

    test('returns null when team is not in teamER', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120.0, 'max': 140.0},
      });

      expect(resonator.erTargetForTeam('Team B'), isNull);
    });

    test('returns null when teamER is null', () {
      final resonator = mockResonatorWithTeamER();

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when entry is not a Map', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': 'not a map',
      });

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when min is missing', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'max': 140.0},
      });

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when max is missing', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120.0},
      });

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('handles integer values by casting to double', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120, 'max': 140},
      });

      final result = resonator.erTargetForTeam('Team A');
      expect(result!['min'], 120.0);
      expect(result['max'], 140.0);
      expect(result['min'], isA<double>());
      expect(result['max'], isA<double>());
    });
  });

  group('erNotNeededForTeam', () {
    test('returns true when entry is empty Map {} (ER explicitly not needed)', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': <String, dynamic>{},
      });

      expect(resonator.erNotNeededForTeam('Team A'), isTrue);
    });

    test('returns false when entry has both min and max', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120.0, 'max': 140.0},
      });

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });

    test('returns false when team is not in teamER', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': {'min': 120.0, 'max': 140.0},
      });

      expect(resonator.erNotNeededForTeam('Team B'), isFalse);
    });

    test('returns false when teamER is null', () {
      final resonator = mockResonatorWithTeamER();

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });

    test('returns false when entry is not a Map', () {
      final resonator = mockResonatorWithTeamER(teamER: {
        'Team A': 'not a map',
      });

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });
  });
}
