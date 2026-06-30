import 'package:evc/domain/enums/stat.dart';
import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/domain/models/echo.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/domain/models/resonator.dart';

/// Creates a mock resonator for testing.
Resonator mockResonator({
  String id = 'test-resonator',
  String name = 'Test Resonator',
  int stars = 5,
  Attribute attribute = Attribute.fusion,
  Weapon weapon = Weapon.sword,
  List<String> teams = const [],
}) {
  return Resonator(
    id: id,
    name: name,
    stars: stars,
    attribute: attribute,
    weapon: weapon,
    iconAsset: 'assets/resonator_icons/test.webp',
    portraitAsset: 'assets/resonator_portraits/test.webp',
    usableStats: Stat.all,
    teams: teams,
  );
}

/// Creates a mock echo set for testing.
EchoSet mockEchoSet({
  double overallScore = 85.5,
  String overallTier = 'Well Built',
  double totalER = 120.0,
  String? team,
}) {
  return EchoSet(
    echoes: List.generate(
      5,
      (i) => Echo(
        stats: {
          'Crit Rate(%) ${i + 1}': 7.5,
          'Crit Damage(%) ${i + 1}': 15.0,
        },
        score: 20.0 + i,
        tier: 'Well Built',
      ),
    ),
    overallScore: overallScore,
    overallTier: overallTier,
    totalER: totalER,
    team: team,
  );
}

/// Creates a sample JSON map for a resonator.
Map<String, dynamic> mockResonatorJson() => {
      'id': 'test-resonator',
      'name': 'Test',
      'stars': 5,
      'attribute': 'fusion',
      'weapon': 'sword',
      'iconAsset': 'assets/resonator_icons/test.webp',
      'portraitAsset': 'assets/resonator_portraits/test.webp',
      'usableStats': ['critRate', 'critDamage', 'atkPercent'],
      'teams': ['Team A'],
    };
