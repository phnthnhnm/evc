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

  group('erTargetForTeam', () {
    test('returns {min, max} when teamER has valid entry with both keys', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120.0, 'max': 140.0},
        },
      );

      final result = resonator.erTargetForTeam('Team A');
      expect(result, {'min': 120.0, 'max': 140.0});
    });

    test('returns null when team is not in teamER', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120.0, 'max': 140.0},
        },
      );

      expect(resonator.erTargetForTeam('Team B'), isNull);
    });

    test('returns null when teamER is null', () {
      final resonator = mockResonatorWithTeamER();

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when entry is not a Map', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {'Team A': 'not a map'},
      );

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when min is missing', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'max': 140.0},
        },
      );

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('returns null when max is missing', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120.0},
        },
      );

      expect(resonator.erTargetForTeam('Team A'), isNull);
    });

    test('handles integer values by casting to double', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120, 'max': 140},
        },
      );

      final result = resonator.erTargetForTeam('Team A');
      expect(result!['min'], 120.0);
      expect(result['max'], 140.0);
      expect(result['min'], isA<double>());
      expect(result['max'], isA<double>());
    });
  });

  group('erNotNeededForTeam', () {
    test(
      'returns true when entry is empty Map {} (ER explicitly not needed)',
      () {
        final resonator = mockResonatorWithTeamER(
          teamER: {'Team A': <String, dynamic>{}},
        );

        expect(resonator.erNotNeededForTeam('Team A'), isTrue);
      },
    );

    test('returns false when entry has both min and max', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120.0, 'max': 140.0},
        },
      );

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });

    test('returns false when team is not in teamER', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {
          'Team A': {'min': 120.0, 'max': 140.0},
        },
      );

      expect(resonator.erNotNeededForTeam('Team B'), isFalse);
    });

    test('returns false when teamER is null', () {
      final resonator = mockResonatorWithTeamER();

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });

    test('returns false when entry is not a Map', () {
      final resonator = mockResonatorWithTeamER(
        teamER: {'Team A': 'not a map'},
      );

      expect(resonator.erNotNeededForTeam('Team A'), isFalse);
    });
  });
}
