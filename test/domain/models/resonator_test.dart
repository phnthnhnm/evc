import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/models/resonator.dart';

import '../../test_helpers.dart';

void main() {
  group('Resonator', () {
    test('JSON round-trip preserves data', () {
      final resonator = mockResonator();
      final json = resonator.toJson();
      final restored = Resonator.fromJson(json);

      expect(restored.id, resonator.id);
      expect(restored.name, resonator.name);
      expect(restored.stars, resonator.stars);
      expect(restored.attribute, resonator.attribute);
      expect(restored.weapon, resonator.weapon);
      expect(restored.usableStats, resonator.usableStats);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'minimal',
        'name': 'Minimal',
        'attribute': 'spectro',
        'weapon': 'rectifier',
        'iconAsset': '',
        'portraitAsset': '',
        'usableStats': [],
      };

      final resonator = Resonator.fromJson(json);
      expect(resonator.stars, 5); // default
      expect(resonator.teams, isEmpty);
      expect(resonator.savedEchoSet, isNull);
    });

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

    test('fromJson deserializes savedEchoSet correctly', () {
      final json = mockResonatorJson();
      json['savedEchoSet'] = {
        'echoes': [
          {
            'stats': {'Crit Rate(%) 1': 7.5},
            'score': 10.0,
            'tier': 'Decent',
          },
        ],
        'overallScore': 75.0,
        'overallTier': 'Well Built',
        'totalER': 120.0,
        'team': 'My Team',
      };

      final resonator = Resonator.fromJson(json);
      expect(resonator.savedEchoSet, isNotNull);
      expect(resonator.savedEchoSet!.overallScore, 75.0);
      expect(resonator.savedEchoSet!.team, 'My Team');
    });
  });
}
