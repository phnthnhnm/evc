import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:evc/domain/models/echo_set.dart';

void main() {
  group('EchoSet.fromJson (_echoesFromJson)', () {
    test('null echoes produces empty list', () {
      final json = <String, dynamic>{
        'overallScore': 0.0,
        'overallTier': 'Unbuilt',
        'totalER': 100.0,
      };

      final echoSet = EchoSet.fromJson(json);
      expect(echoSet.echoes, isEmpty);
    });

    test('empty echoes array produces empty list', () {
      final json = <String, dynamic>{
        'echoes': <dynamic>[],
        'overallScore': 0.0,
      };

      final echoSet = EchoSet.fromJson(json);
      expect(echoSet.echoes, isEmpty);
    });

    test('single echo: stat keys get slot-1 suffix', () {
      final json = <String, dynamic>{
        'echoes': [
          {
            'stats': {'Crit Rate(%)': 6.3, 'ATK(%)': 8.6},
            'score': 3.5,
            'tier': 'S',
          },
        ],
      };

      final echoSet = EchoSet.fromJson(json);
      expect(echoSet.echoes, hasLength(1));
      final stats = echoSet.echoes[0].stats;
      expect(stats, contains('Crit Rate(%) 1'));
      expect(stats, contains('ATK(%) 1'));
      expect(stats['Crit Rate(%) 1'], 6.3);
    });

    test('three echoes: stat keys get correct slot suffixes', () {
      final json = <String, dynamic>{
        'echoes': [
          {
            'stats': {'Crit Rate(%)': 6.3},
          },
          {
            'stats': {'ATK(%)': 8.6},
          },
          {
            'stats': {'HP(%)': 10.0},
          },
        ],
      };

      final echoSet = EchoSet.fromJson(json);
      expect(echoSet.echoes, hasLength(3));
      expect(echoSet.echoes[0].stats, contains('Crit Rate(%) 1'));
      expect(echoSet.echoes[1].stats, contains('ATK(%) 2'));
      expect(echoSet.echoes[2].stats, contains('HP(%) 3'));
    });

    test(
      'old-format keys with suffixes: suffix replaced based on array position',
      () {
        // Simulate old data where keys have slot-3 suffixes but the echo
        // is now at array position 0 (slot 1).
        final json = <String, dynamic>{
          'echoes': [
            {
              'stats': {'Crit Rate(%) 3': 6.3, 'ATK(%) 3': 8.6},
            },
          ],
        };

        final echoSet = EchoSet.fromJson(json);
        final stats = echoSet.echoes[0].stats;
        // Suffix " 3" should be replaced with " 1" based on array position.
        expect(stats, contains('Crit Rate(%) 1'));
        expect(stats, contains('ATK(%) 1'));
        expect(stats, isNot(contains('Crit Rate(%) 3')));
      },
    );
  });

  group('EchoSet.toJson (_echoesToJson)', () {
    test('stat key suffixes are stripped', () {
      final json = <String, dynamic>{
        'echoes': [
          {
            'stats': {'Crit Rate(%) 1': 6.3, 'ATK(%) 2': 8.6},
            'score': 3.5,
            'tier': 'S',
          },
          {
            'stats': {'HP(%) 3': 10.0},
            'score': 2.0,
            'tier': 'A',
          },
        ],
        'overallScore': 42.0,
        'overallTier': 'S',
        'totalER': 130.0,
        'team': 'Team A',
      };

      final echoSet = EchoSet.fromJson(json);
      final serialized = echoSet.toJson();
      final encoded = jsonEncode(serialized);

      // Stat keys in the JSON output should have no slot suffixes.
      expect(encoded, contains('"Crit Rate(%)"'));
      expect(encoded, contains('"ATK(%)"'));
      expect(encoded, contains('"HP(%)"'));
      expect(encoded, isNot(contains('Crit Rate(%) 1')));
      expect(encoded, isNot(contains('ATK(%) 2')));
    });

    test('non-stat fields are preserved', () {
      final json = <String, dynamic>{
        'echoes': [
          {
            'stats': {'Crit Rate(%) 1': 6.3},
            'score': 3.5,
            'tier': 'S',
          },
        ],
        'overallScore': 42.0,
        'overallTier': 'S',
        'totalER': 130.0,
        'team': 'Team A',
      };

      final echoSet = EchoSet.fromJson(json);
      final serialized = echoSet.toJson();

      expect(serialized['overallScore'], 42.0);
      expect(serialized['overallTier'], 'S');
      expect(serialized['totalER'], 130.0);
      expect(serialized['team'], 'Team A');
    });
  });
}
