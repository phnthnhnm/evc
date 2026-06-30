import 'package:flutter_test/flutter_test.dart';
import 'package:evc/domain/models/echo.dart';
import 'package:evc/domain/models/echo_set.dart';

void main() {
  group('EchoSet', () {
    test('defaults are correct', () {
      const echoSet = EchoSet();
      expect(echoSet.echoes, isEmpty);
      expect(echoSet.overallScore, 0.0);
      expect(echoSet.overallTier, 'Unbuilt');
      expect(echoSet.totalER, 100.0);
      expect(echoSet.team, isNull);
    });

    test('JSON round-trip preserves data', () {
      final echoSet = EchoSet(
        echoes: [
          Echo(stats: {'a': 1.0}, score: 10.0, tier: 'Decent'),
        ],
        overallScore: 85.5,
        overallTier: 'Well Built',
        totalER: 120.0,
        team: 'Test Team',
      );

      final json = echoSet.toJson();
      final restored = EchoSet.fromJson(json);

      expect(restored.echoes.length, 1);
      expect(restored.overallScore, 85.5);
      expect(restored.overallTier, 'Well Built');
      expect(restored.totalER, 120.0);
      expect(restored.team, 'Test Team');
    });

    test('fromLegacyJson migrates totEr → totalER', () {
      final json = {
        'echoes': [],
        'overallScore': 50.0,
        'overallTier': 'Decent',
        'totEr': 110.0,
      };

      final echoSet = EchoSet.fromLegacyJson(json);
      expect(echoSet.totalER, 110.0);
    });

    test('fromLegacyJson migrates energyBuff → team', () {
      final json = {
        'echoes': [],
        'overallScore': 50.0,
        'overallTier': 'Decent',
        'energyBuff': 'Legacy Team',
      };

      final echoSet = EchoSet.fromLegacyJson(json);
      expect(echoSet.team, 'Legacy Team');
    });

    test('fromLegacyJson handles both legacy keys', () {
      final json = {
        'echoes': [],
        'overallScore': 50.0,
        'overallTier': 'Decent',
        'totEr': 115.0,
        'energyBuff': 'Old Team',
      };

      final echoSet = EchoSet.fromLegacyJson(json);
      expect(echoSet.totalER, 115.0);
      expect(echoSet.team, 'Old Team');
    });

    test('fromJson uses canonical keys', () {
      final json = {
        'echoes': [],
        'overallScore': 90.0,
        'overallTier': 'Extreme',
        'totalER': 130.0,
        'team': 'Canonical Team',
      };

      final echoSet = EchoSet.fromJson(json);
      expect(echoSet.overallScore, 90.0);
      expect(echoSet.overallTier, 'Extreme');
      expect(echoSet.totalER, 130.0);
      expect(echoSet.team, 'Canonical Team');
    });

    test('copyWith preserves unchanged fields', () {
      final echoSet = EchoSet(
        overallScore: 50.0,
        overallTier: 'Decent',
        totalER: 100.0,
      );
      final copy = echoSet.copyWith(overallScore: 75.0);

      expect(copy.overallScore, 75.0);
      expect(copy.overallTier, 'Decent');
      expect(copy.totalER, 100.0);
    });
  });
}
